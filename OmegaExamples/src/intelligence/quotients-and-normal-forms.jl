### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 777634ae-555b-4ed6-a41e-f3d3741c9cc3
begin
    import Pkg
    # Set to `true` to run against your local Omega.jl checkout instead of
    # installing the published `complete-probmods` branch.
    use_local_omega = true
    if use_local_omega
        Pkg.activate(Base.current_project())
    else
        Pkg.activate(mktempdir())
        repo = "https://github.com/zenna/Omega.jl"
        rev = "complete-probmods"
        Pkg.add([
            Pkg.PackageSpec(url=repo, rev=rev),
            Pkg.PackageSpec(url=repo, rev=rev, subdir="OmegaCore"),
            Pkg.PackageSpec(url=repo, rev=rev, subdir="InferenceBase"),
            Pkg.PackageSpec(url=repo, rev=rev, subdir="SoftPredicates"),
            Pkg.PackageSpec(url=repo, rev=rev, subdir="connectors/OmegaDistributions"),
            Pkg.PackageSpec(url=repo, rev=rev, subdir="connectors/OmegaSoftPredicates"),
            Pkg.PackageSpec(url=repo, rev=rev, subdir="OmegaMH"),
            Pkg.PackageSpec(url=repo, rev=rev, subdir="ReplicaExchange"),
            Pkg.PackageSpec(url=repo, rev=rev, subdir="OmegaExamples"),
        ])
    end
    using Omega, Distributions, OmegaExamples, UnicodePlots
end

# ╔═╡ 63530b43-d29b-4776-8ee7-566fd999b26f
md"""
# 3. Quotients and normal forms

Chapter 2 started from one generator, the adjacent swap, and derived a quotient:
every ordering of the same flips collapses to one head count. We chose that
generator by hand. This chapter treats the choice as an inference problem. Given
a small library of candidate generators, which one should a learner use for a
given task?

Each candidate generator groups sequences into orbits, and we label each orbit
by a *canonical form*: one fixed member chosen to stand for the whole orbit. A
candidate is useful for a task when the task's answer is constant on each orbit,
because a decoder can then read the answer from the canonical form. Among the
candidates that pass this test, we prefer the one with the fewest orbits,
because its decoder has fewer cases to handle.

Choosing what to ignore is only half the story. The chapter ends by asking how
to describe the chosen quotient so that the task becomes simple to compute. A
description in which the task needs only a few cheap, ideally linear, operations
is what the paper calls a *normal form*.
"""

# ╔═╡ 26c6cbd7-df24-4e41-8793-38895dc7f3b4
md"""
## The model and the two tasks

We reuse the coin model from Chapter 1 and the two tasks from Chapter 2: the
posterior probability that the coin is fair, and the longest run of heads.
"""

# ╔═╡ 4e8373bb-4723-47ed-95fa-d188b915b231
is_fair_prior = 0.5

# ╔═╡ 1563d89a-1d16-4fef-b696-abddba416e66
fair_weight = 0.5

# ╔═╡ 008c38cc-75d3-4574-8709-059e765db921
trick_weight = 0.85

# ╔═╡ 79c9a71e-e998-4bcd-b326-6f431dd1b017
is_fair_coin = @~ Bernoulli(is_fair_prior)

# ╔═╡ 55940074-579b-49fe-b045-4467b5b810e7
coin_flip(i, ω) =
    (i ~ Bernoulli(is_fair_coin(ω) ? fair_weight : trick_weight))(ω)

# ╔═╡ 804a80bc-4172-4605-8ad8-16c386a046c4
flip_sequence(n) = Variable(ω -> [coin_flip(i, ω) for i in 1:n])

# ╔═╡ 47ec24ed-160e-4611-8aec-75a9ebcb104f
show_sequence(sequence) = join(ifelse.(sequence, "H", "T"))

# ╔═╡ 84f6bd01-7fee-438a-904a-1c64ff8d2a60
function is_fair_posterior(sequence)
    likelihood(weight) = prod(flip ? weight : 1 - weight for flip in sequence)
    fair_mass = is_fair_prior * likelihood(fair_weight)
    trick_mass = (1 - is_fair_prior) * likelihood(trick_weight)
    fair_mass / (fair_mass + trick_mass)
end

# ╔═╡ 07f654f7-17c2-4d5b-99a7-9baddd457acb
function longest_head_run(sequence)
    longest = 0
    current = 0
    for s in sequence
        current = s ? current + 1 : 0
        longest = max(longest, current)
    end
    longest
end

# ╔═╡ a8675295-f529-4bf0-8f42-b192cdecda2d
function swap_adjacent(sequence, i)
    swapped = copy(sequence)
    swapped[i], swapped[i + 1] = swapped[i + 1], swapped[i]
    swapped
end

# ╔═╡ 2472053a-0d8d-4593-8222-b177b8d2a9bf
all_boolean_sequences(n) = [
    [isone((mask >> i) & 1) for i in 0:n-1]
    for mask in 0:(2^n - 1)
]

# ╔═╡ 25ed950d-4fca-4963-a645-0ef856144b40
md"""
## A library of candidate generators

Each candidate below returns the *neighbours* of a sequence: the sequences
reachable by one application of one of its generators.

- `identity` has no generators, so every sequence is its own orbit.
- `reversal` reverses the whole sequence.
- `rotation` moves the last flip to the front, a cyclic shift.
- `permutation` uses the adjacent swaps from Chapter 2, which generate every
  reordering.
"""

# ╔═╡ fe73a987-3c36-48c1-9e6f-12b751f1a4d7
generator_library = [
    :identity    => sequence -> Vector{Bool}[],
    :reversal    => sequence -> [reverse(sequence)],
    :rotation    => sequence -> [circshift(sequence, 1)],
    :permutation => sequence -> [swap_adjacent(sequence, i) for i in 1:length(sequence)-1],
]

# ╔═╡ 15f5a223-eff5-4e66-8626-d5a191573a0c
md"""
`orbit` generalises `permutation_orbit` from Chapter 2. It takes any neighbour
function, repeatedly applies it, and collects every sequence it reaches. The
canonical form is the alphabetically first member of the orbit, writing `H`
before `T`. Any fixed choice of representative would work; what matters is that
every member of an orbit maps to the same one.
"""

# ╔═╡ 2b52fe16-b9d2-4010-9cea-4f7074bf0dea
function orbit(neighbours, sequence)
    seen = Set([sequence])
    frontier = [sequence]
    while !isempty(frontier)
        current = popfirst!(frontier)
        for candidate in neighbours(current)
            if candidate ∉ seen
                push!(seen, candidate)
                push!(frontier, candidate)
            end
        end
    end
    sort(collect(seen), by = show_sequence)
end

# ╔═╡ 74199ea0-f7b5-4059-963b-866f8185318e
canonical_form(neighbours, sequence) = first(orbit(neighbours, sequence))

# ╔═╡ f9377259-a93c-4f88-8af9-2cd775939c76
seed_sequence = [true, true, false, true]  # HHTH

# ╔═╡ 15e750a2-166a-46ba-8f8b-0471a0f36c05
[
    (generator = name,
     orbit = show_sequence.(orbit(neighbours, seed_sequence)),
     canonical_form = show_sequence(canonical_form(neighbours, seed_sequence)))
    for (name, neighbours) in generator_library
]

# ╔═╡ 91109597-b673-4740-995a-d5d03ef86be7
md"""
For `HHTH`, `identity` leaves the sequence alone and `reversal` pairs it with
`HTHH`. `rotation` and `permutation` both reach all four sequences with three
heads, so they share the canonical form `HHHT`.

The two differ on other seeds. Try `[true, true, false, false]` and then
`[true, false, true, false]`. Permutation puts `HHTT` and `HTHT` in the same
orbit; rotation keeps them apart, because no cyclic shift turns one into the
other.
"""

# ╔═╡ fbafa95e-ce32-4e3e-9a07-fb7ca983df21
md"""
## How coarse is each quotient?

The quotient of a candidate is its set of orbits. The next cells group every
sequence of a given length by its canonical form and count the groups.
"""

# ╔═╡ ad7f460f-c5cc-4df7-9798-11d93eb2fb7c
sequence_length = 4

# ╔═╡ 95200c8d-d2c2-4f41-9097-fc2f1342c6d3
function quotient_classes(neighbours, n)
    classes = Dict{Vector{Bool}, Vector{Vector{Bool}}}()
    for sequence in all_boolean_sequences(n)
        push!(get!(classes, canonical_form(neighbours, sequence), Vector{Bool}[]), sequence)
    end
    classes
end

# ╔═╡ 58ac9fa7-7bad-4f61-98f0-0372e1d8d76c
class_count(neighbours, n) = length(quotient_classes(neighbours, n))

# ╔═╡ 807c44ba-05e7-495c-938d-e66f2d1314f2
[(generator = name, classes = class_count(neighbours, sequence_length))
 for (name, neighbours) in generator_library]

# ╔═╡ 6abab60c-d885-49d0-8d36-23c827d852c0
md"""
For four flips, you should see 16, 10, 6 and 5 classes for each generator, respectively. `identity` keeps all 16
sequences apart. `reversal` pairs each sequence with its mirror image and leaves
the four palindromes alone, giving 4 + 12/2 = 10. `rotation` gives 6 classes,
and `permutation` gives the five head counts from Chapter 2.

Fewer classes means a smaller table for the decoder. Try `sequence_length = 5`
and predict the counts first: 32 sequences, 8 of them palindromes.
"""

# ╔═╡ 2b9d24a8-5257-4204-9724-9b4bca2db59a
md"""
## Task sufficiency

A quotient is *sufficient* for a task ``T`` when ``T`` is constant on every
class. Then a decoder ``D`` exists with ``T = D\circ q``, where ``q`` maps a
sequence to its canonical form, exactly as in Chapters 1 and 2.

The fair-coin posterior returns floating-point numbers. Two orderings of the
same flips can give values that differ in the last digit, so `same_answer`
compares floats approximately.
"""

# ╔═╡ 6f381e96-3846-441f-b34a-3216026533a0
same_answer(a, b) = a isa AbstractFloat ? isapprox(a, b) : a == b

# ╔═╡ 02fe4a07-f226-48e7-9594-b2c32addab1d
function is_task_sufficient(neighbours, task, n)
    for class in values(quotient_classes(neighbours, n))
        reference = task(first(class))
        for s in class
            same_answer(task(s), reference) || return false
        end
    end
    true
end

# ╔═╡ 365c19b4-cabc-40f2-b191-a6a31d502227
sufficiency_table = [
    (generator = name,
     classes = class_count(neighbours, sequence_length),
     fair_posterior = is_task_sufficient(neighbours, is_fair_posterior, sequence_length),
     longest_head_run = is_task_sufficient(neighbours, longest_head_run, sequence_length))
    for (name, neighbours) in generator_library
]

# ╔═╡ 867f0d38-df3e-4825-a847-f59572065347
md"""
Every candidate preserves the fair-coin posterior, because each one only
reorders flips and the posterior depends only on the head count. Only `identity`
and `reversal` preserve the longest head run. `rotation` fails because it can
join two runs: it turns `HHTH` into `HHHT`, changing the longest run from 2 to 3.

Reading down each task column, the coarsest sufficient quotient is
`permutation` for the posterior and `reversal` for the longest run.
"""

# ╔═╡ d7dfd51d-218a-4326-85e2-9de1cbfc3634
md"""
## Inferring the quotient from examples

So far we checked sufficiency against every sequence, using the task function
itself. A learner usually sees only a few examples: sequences paired with their
answers. It has to infer a quotient from those.

A candidate is *consistent* with the examples when no two examples share a
canonical form but have different answers. If two examples do, no decoder of
that quotient can reproduce both answers.
"""

# ╔═╡ 0e9a36a7-a185-48cd-b309-24ab49e6151b
function is_consistent(neighbours, examples)
    answers = Dict{Vector{Bool}, Any}()
    for (sequence, answer) in examples
        key = canonical_form(neighbours, sequence)
        if haskey(answers, key)
            same_answer(answers[key], answer) || return false
        else
            answers[key] = answer
        end
    end
    true
end

# ╔═╡ 0cd57e79-6c4a-4c36-9498-366e07fbab93
md"""
### A simplicity prior

The prior prefers candidates with fewer classes. Each candidate gets weight
``c^{-\lambda}``, where ``c`` is its number of classes and ``\lambda`` is
`simplicity_strength`. Setting it to 0 gives a uniform prior.

This preference is a modelling choice for this example. What we care
about is how costly the task is to compute in each representation; the number of
classes is one simple stand-in for that cost. The prior is a cost on
representations written as a probability.
"""

# ╔═╡ a567e1ff-c303-4370-99ef-3801cef3db69
simplicity_strength = 1.0

# ╔═╡ 34f0e3de-4837-49a6-9f42-a580684b2979
prior = let
    weights = [class_count(neighbours, sequence_length)^(-simplicity_strength)
               for (_, neighbours) in generator_library]
    weights / sum(weights)
end

# ╔═╡ ad646840-497a-4dac-a370-fb065a3a5567
[(generator = name, prior_probability = p)
 for ((name, _), p) in zip(generator_library, prior)]

# ╔═╡ 17b812d5-91c2-4ca2-b86e-22f80d640de2
md"""
The model draws one candidate from this prior. `quotient_posterior`
conditions that draw on consistency with the examples, so it keeps only
candidates whose quotient could explain them.
"""

# ╔═╡ a21b18cf-5a03-4313-ae95-88a2f475515d
candidate_index = @~ Categorical(prior)

# ╔═╡ 4256507e-18f5-4872-bd9f-af28ec533975
candidate_name = Variable(ω -> first(generator_library[candidate_index(ω)]))

# ╔═╡ 90609b78-b83a-496d-b017-fb9b8c74da2d
quotient_posterior(examples) = candidate_name |ᶜ Variable(ω ->
    is_consistent(last(generator_library[candidate_index(ω)]), examples))

# ╔═╡ 008b882f-3a2c-4012-93bb-2909adbb9e6f
md"""
Because consistency is fixed once the candidate is chosen, the posterior is the
prior restricted to the consistent candidates and renormalised. `exact_posterior`
computes that directly so we can compare it with the samples.
"""

# ╔═╡ bb1f29b9-9a46-4709-a89d-7c555b5818f2
function exact_posterior(examples)
    weights = [p * is_consistent(neighbours, examples)
               for ((_, neighbours), p) in zip(generator_library, prior)]
    weights / sum(weights)
end

# ╔═╡ 66437319-0005-44b8-95ca-70fb93c0634c
md"""
## Incomplete evidence

The examples below are sequences drawn from the coin model and labelled with the
answer to `task`. We start with the longest head run and only three examples.
"""

# ╔═╡ 32d4bc75-ca66-4f71-adf7-e79c11082990
task = longest_head_run

# ╔═╡ 516239f3-d802-455c-af0d-51dbbedb86e1
example_count = 3

# ╔═╡ 3cccbfb4-89db-4159-9157-665429a5c436
examples = [(s, task(s))
            for s in randsample(flip_sequence(sequence_length), example_count)]

# ╔═╡ ed8a585c-a50c-491f-a3b1-a398ec700f3c
[(sequence = show_sequence(s), answer = a) for (s, a) in examples]

# ╔═╡ f0d83343-10d2-4ff3-9635-d68a349a07e9
posterior_samples = randsample(quotient_posterior(examples), 400;
                               alg = RejectionSample)

# ╔═╡ 3df218de-2f15-4f5b-908f-3a5abf5b04c8
viz(string.(posterior_samples))

# ╔═╡ b75f4854-6487-4615-8bf5-7e6ec6e011f3
[(generator = name,
  sampled = count(==(name), posterior_samples) / length(posterior_samples),
  exact = p)
 for ((name, _), p) in zip(generator_library, exact_posterior(examples))]

# ╔═╡ c43147e3-299f-461c-90ac-de3c712170df
md"""
With three examples, the posterior usually spreads over several candidates, and
`permutation` often has the most weight. It is the coarsest candidate, and three
sequences from this coin rarely include a conflicting pair: two sequences with
the same head count but different longest runs. The simplicity prior then
favours a quotient that is wrong for this task.

Rerun the `examples` cell several times, then raise `example_count` to 10 and 20. Once a conflicting pair appears, `permutation` and `rotation` drop to zero.
"""

# ╔═╡ ee6589e4-0915-4702-90cf-1ca7f389b805
md"""
## Complete evidence

The next cell labels every sequence of the chosen length. No example is missing,
so the consistent candidates are exactly the sufficient ones from the table
above.
"""

# ╔═╡ 3f751742-5a83-4856-941e-81e16a452f9a
complete_examples = [(s, task(s)) for s in all_boolean_sequences(sequence_length)]

# ╔═╡ 7acf187c-6242-49b0-b11a-c1ee78c1cf57
[(generator = name, posterior_probability = p)
 for ((name, _), p) in zip(generator_library, exact_posterior(complete_examples))]

# ╔═╡ 0eed7f16-8d5a-4b1a-9c2b-57bc87d88383
md"""
For the longest run, `reversal` and `identity` share the posterior, about 0.62
and 0.38 at the starting settings. `identity` never becomes inconsistent: it can
memorise every answer. Only the simplicity prior ranks `reversal` above it. Try
`simplicity_strength = 0`, then 3, and watch how the split changes.

Now set `task = is_fair_posterior`. Every candidate is consistent with every
example, so the posterior equals the prior, and `permutation` is most probable.
"""

# ╔═╡ e97763c0-8b7a-4505-82c1-ccfeba84dde3
md"""
## Which cost?

The simplicity prior counted classes: the number of cases a decoder has to
handle. Class count is one type of cost. Another is the work needed to compute the canonical
form of a new sequence. `canonical_form` enumerates the whole orbit, so its cost
grows with orbit size.
"""

# ╔═╡ 132b398a-af3e-40ca-be0d-e79ae1f22a95
mean_orbit_size(neighbours, n) =
    mean(length(orbit(neighbours, s)) for s in all_boolean_sequences(n))

# ╔═╡ eb817729-bae0-4009-ba3b-737b20e0f435
[(generator = name,
  classes = class_count(neighbours, sequence_length),
  mean_orbit_size = mean_orbit_size(neighbours, sequence_length))
 for (name, neighbours) in generator_library]

# ╔═╡ d0e43196-156c-4cd1-8244-b723923fb1a9
md"""
The two costs rank the candidates in opposite orders. `permutation` has the
fewest classes but the largest orbits: a sequence with ``k`` heads has
``\binom{n}{k}`` orderings to enumerate. Try `sequence_length = 8` and compare.

Chapter 1 reached the same permutation class far more cheaply. Counting heads
takes one pass over the sequence and never builds the orbit. The quotient is the
same; only the way of describing it differs. Which representation counts as
simplest therefore depends on what you measure, and on which operations the
machine doing the computing makes cheap.
"""

# ╔═╡ 367a920a-a0c0-4cea-892a-e5e0459a8b86
md"""
## From a quotient to a normal form

For the fair-coin task we settled on the permutation quotient. The canonical
forms `HHHT`, `HHTT` and so on label its classes, but they do not make the task
easier to compute. The head count from Chapter 1 labels the same classes.
"""

# ╔═╡ b0e5395b-e452-4043-b278-c4568fa44301
count_coordinate(sequence) = 
	(flips = length(sequence), heads = count(identity, sequence))

# ╔═╡ d7fb52d7-b737-4261-8eeb-6811a077ef1d
permutation_neighbours = Dict(generator_library)[:permutation]

# ╔═╡ f8904fd2-e511-428f-a0e1-ac2250796fd9
(same_number_of_classes =
     length(unique(count_coordinate.(all_boolean_sequences(sequence_length)))) ==
     class_count(permutation_neighbours, sequence_length),
 one_count_per_class =
     all(length(unique(count_coordinate.(class))) == 1
         for class in values(quotient_classes(permutation_neighbours, sequence_length))))

# ╔═╡ b22e97e3-ebff-4e53-8045-a9fb9b566d8f
md"""
Both checks should be `true`: the count and the canonical form describe the same
quotient. The descriptions differ in what they make easy.

As data arrive, the fair-coin task has to track one transformation: observing
another flip. For a sequence, observing a flip lengthens a list. In count
coordinates it adds `(1, 1)` for a head or `(1, 0)` for a tail. `append_flip`
performs this update, and
the next cell checks that updating the count gives the same result as counting
the longer sequence.
"""

# ╔═╡ 0f9188a1-015b-4299-9c7c-340c046d1077
append_flip(coordinate, flip) = 
	(flips = coordinate.flips + 1, heads = coordinate.heads + flip)

# ╔═╡ 05acc28a-9c82-4fbc-850d-3e314852ea8c
all(count_coordinate(vcat(s, flip)) == append_flip(count_coordinate(s), flip)
    for s in all_boolean_sequences(sequence_length) for flip in (true, false))

# ╔═╡ e71771dd-0acc-4ced-bc5c-01f04716b2a8
md"""
The posterior is not a linear function of the count, but its *log odds* is.
Each head multiplies the odds that the coin is fair by the same factor, and each
tail by another. Taking logarithms turns those products into sums, so every head
moves the evidence by a fixed step and every tail by another fixed step.
"""

# ╔═╡ 3d40a0fc-31fc-4353-b531-95ad9777ba9b
head_step = log(fair_weight / trick_weight)

# ╔═╡ 32a0fd72-3377-4377-87e5-0e4a7db37651
tail_step = log((1 - fair_weight) / (1 - trick_weight))

# ╔═╡ da3e5d2b-042f-4eab-8e6d-96d37876e68c
prior_log_odds = log(is_fair_prior / (1 - is_fair_prior))

# ╔═╡ 1362977b-122d-4328-a1b7-bdb72bcd57d4
fair_log_odds(coordinate) = prior_log_odds + coordinate.heads * head_step +
    (coordinate.flips - coordinate.heads) * tail_step

# ╔═╡ 76719288-147c-485c-b1f9-72bc7724aefb
from_log_odds(z) = 1 / (1 + exp(-z))

# ╔═╡ f7ba257e-7305-403a-a525-269b23447e16
all(from_log_odds(fair_log_odds(count_coordinate(s))) ≈ is_fair_posterior(s)
    for s in all_boolean_sequences(sequence_length))

# ╔═╡ f7311226-d709-43fc-8be3-ae98b305f79b
[(heads = k,
  log_odds = fair_log_odds((flips = sequence_length, heads = k)),
  fair_posterior = 
  from_log_odds(fair_log_odds((flips = sequence_length, heads = k))))
 for k in 0:sequence_length]

# ╔═╡ 6315b04e-6d2b-4b60-b914-da2ec46b248e
md"""
At the starting settings, each head moves the log odds by about −0.53, towards
the trick coin, and each tail by about +1.20, towards the fair coin. The
posterior column changes unevenly; the log-odds column changes in equal steps.

The log odds is a *usable axis*. Deciding "fair or trick?" means checking its
sign, comparing two sequences means comparing two numbers, and observing another
flip means adding a step. The canonical forms supported none of these operations
directly.

Two moves produced this description. Quotienting removed the order of the flips,
and re-describing the quotient turned the evidence into a sum. A representation
in which the task needs only a few cheap, linear operations like these is what
the paper calls a normal form. Try changing `trick_weight` and predict how the
two steps change before running the cells.
"""

# ╔═╡ 2e61b2e0-41d1-4074-822e-d0d766c5dee2
md"""
## What the library leaves out

The learner here selects from four candidates that we supplied and cannot invent
a fifth generator. Nor did it find the count coordinate or the log-odds axis: we
supplied those in the last section. If no candidate were sufficient and cheap,
the posterior would still have to choose among them.

Chapter 4 changes the task partway through and asks how a learner can tell that
its representation has stopped working. Constructing new generators and axes is
the step that a fixed library cannot take.

## Discussion

Add a candidate `:complement => sequence -> [.!sequence]` that swaps heads and
tails. Before running the sufficiency table, predict which tasks it preserves.
Would your answer change if `trick_weight` were 0.5?

The longest-run task settled on the reversal quotient. Can you find a
description of it in which the longest run is cheap to read off?

With `simplicity_strength = 0` and complete evidence, the longest-run posterior
splits evenly between `identity` and `reversal`. What kind of evidence, if any,
could favour `reversal` without a simplicity prior? Consider a learner that must
answer questions about sequences it has never seen.
"""

# ╔═╡ 722bf4a7-0de0-4e2c-81d9-e4760f7b683b
md"""
---
## References

This notebook is part of a tutorial series introducing the ideas in Yu (2026).

- Yu, A. J. (2026). *The Art of Making Problems Simple: A Theory of Intelligence*. PsyArXiv. [doi:10.31234/osf.io/pghzn_v3](https://doi.org/10.31234/osf.io/pghzn_v3)
- Goodman, N. D., Tenenbaum, J. B., & The ProbMods Contributors (2016). *Probabilistic Models of Cognition* (2nd ed.). [probmods.org](https://probmods.org/)
- Tavares, Z., Koppel, J., Zhang, X., Das, R., & Solar-Lezama, A. (2021). A language for counterfactual generative models. *Proceedings of the 38th International Conference on Machine Learning*, PMLR 139, 10173–10182. [pdf](http://www.zenna.org/publications/causal.pdf)
"""

# ╔═╡ Cell order:
# ╠═777634ae-555b-4ed6-a41e-f3d3741c9cc3
# ╟─63530b43-d29b-4776-8ee7-566fd999b26f
# ╟─26c6cbd7-df24-4e41-8793-38895dc7f3b4
# ╠═4e8373bb-4723-47ed-95fa-d188b915b231
# ╠═1563d89a-1d16-4fef-b696-abddba416e66
# ╠═008c38cc-75d3-4574-8709-059e765db921
# ╠═79c9a71e-e998-4bcd-b326-6f431dd1b017
# ╠═55940074-579b-49fe-b045-4467b5b810e7
# ╠═804a80bc-4172-4605-8ad8-16c386a046c4
# ╠═47ec24ed-160e-4611-8aec-75a9ebcb104f
# ╠═84f6bd01-7fee-438a-904a-1c64ff8d2a60
# ╠═07f654f7-17c2-4d5b-99a7-9baddd457acb
# ╠═a8675295-f529-4bf0-8f42-b192cdecda2d
# ╠═2472053a-0d8d-4593-8222-b177b8d2a9bf
# ╟─25ed950d-4fca-4963-a645-0ef856144b40
# ╠═fe73a987-3c36-48c1-9e6f-12b751f1a4d7
# ╟─15f5a223-eff5-4e66-8626-d5a191573a0c
# ╠═2b52fe16-b9d2-4010-9cea-4f7074bf0dea
# ╠═74199ea0-f7b5-4059-963b-866f8185318e
# ╠═f9377259-a93c-4f88-8af9-2cd775939c76
# ╠═15e750a2-166a-46ba-8f8b-0471a0f36c05
# ╟─91109597-b673-4740-995a-d5d03ef86be7
# ╟─fbafa95e-ce32-4e3e-9a07-fb7ca983df21
# ╠═ad7f460f-c5cc-4df7-9798-11d93eb2fb7c
# ╠═95200c8d-d2c2-4f41-9097-fc2f1342c6d3
# ╠═58ac9fa7-7bad-4f61-98f0-0372e1d8d76c
# ╠═807c44ba-05e7-495c-938d-e66f2d1314f2
# ╟─6abab60c-d885-49d0-8d36-23c827d852c0
# ╟─2b9d24a8-5257-4204-9724-9b4bca2db59a
# ╠═6f381e96-3846-441f-b34a-3216026533a0
# ╠═02fe4a07-f226-48e7-9594-b2c32addab1d
# ╠═365c19b4-cabc-40f2-b191-a6a31d502227
# ╟─867f0d38-df3e-4825-a847-f59572065347
# ╟─d7dfd51d-218a-4326-85e2-9de1cbfc3634
# ╠═0e9a36a7-a185-48cd-b309-24ab49e6151b
# ╟─0cd57e79-6c4a-4c36-9498-366e07fbab93
# ╠═a567e1ff-c303-4370-99ef-3801cef3db69
# ╠═34f0e3de-4837-49a6-9f42-a580684b2979
# ╠═ad646840-497a-4dac-a370-fb065a3a5567
# ╟─17b812d5-91c2-4ca2-b86e-22f80d640de2
# ╠═a21b18cf-5a03-4313-ae95-88a2f475515d
# ╠═4256507e-18f5-4872-bd9f-af28ec533975
# ╠═90609b78-b83a-496d-b017-fb9b8c74da2d
# ╟─008b882f-3a2c-4012-93bb-2909adbb9e6f
# ╠═bb1f29b9-9a46-4709-a89d-7c555b5818f2
# ╟─66437319-0005-44b8-95ca-70fb93c0634c
# ╠═32d4bc75-ca66-4f71-adf7-e79c11082990
# ╠═516239f3-d802-455c-af0d-51dbbedb86e1
# ╠═3cccbfb4-89db-4159-9157-665429a5c436
# ╠═ed8a585c-a50c-491f-a3b1-a398ec700f3c
# ╠═f0d83343-10d2-4ff3-9635-d68a349a07e9
# ╠═3df218de-2f15-4f5b-908f-3a5abf5b04c8
# ╠═b75f4854-6487-4615-8bf5-7e6ec6e011f3
# ╟─c43147e3-299f-461c-90ac-de3c712170df
# ╟─ee6589e4-0915-4702-90cf-1ca7f389b805
# ╠═3f751742-5a83-4856-941e-81e16a452f9a
# ╠═7acf187c-6242-49b0-b11a-c1ee78c1cf57
# ╟─0eed7f16-8d5a-4b1a-9c2b-57bc87d88383
# ╟─e97763c0-8b7a-4505-82c1-ccfeba84dde3
# ╠═132b398a-af3e-40ca-be0d-e79ae1f22a95
# ╠═eb817729-bae0-4009-ba3b-737b20e0f435
# ╟─d0e43196-156c-4cd1-8244-b723923fb1a9
# ╟─367a920a-a0c0-4cea-892a-e5e0459a8b86
# ╠═b0e5395b-e452-4043-b278-c4568fa44301
# ╠═d7fb52d7-b737-4261-8eeb-6811a077ef1d
# ╠═f8904fd2-e511-428f-a0e1-ac2250796fd9
# ╟─b22e97e3-ebff-4e53-8045-a9fb9b566d8f
# ╠═0f9188a1-015b-4299-9c7c-340c046d1077
# ╠═05acc28a-9c82-4fbc-850d-3e314852ea8c
# ╟─e71771dd-0acc-4ced-bc5c-01f04716b2a8
# ╠═3d40a0fc-31fc-4353-b531-95ad9777ba9b
# ╠═32a0fd72-3377-4377-87e5-0e4a7db37651
# ╠═da3e5d2b-042f-4eab-8e6d-96d37876e68c
# ╠═1362977b-122d-4328-a1b7-bdb72bcd57d4
# ╠═76719288-147c-485c-b1f9-72bc7724aefb
# ╠═f7ba257e-7305-403a-a525-269b23447e16
# ╠═f7311226-d709-43fc-8be3-ae98b305f79b
# ╟─6315b04e-6d2b-4b60-b914-da2ec46b248e
# ╟─2e61b2e0-41d1-4074-822e-d0d766c5dee2
# ╟─722bf4a7-0de0-4e2c-81d9-e4760f7b683b
