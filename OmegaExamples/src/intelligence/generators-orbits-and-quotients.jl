### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 38d37e89-dce4-4d4c-a7b7-06739e64f02d
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

# ╔═╡ ca43a069-c726-4b3e-acf8-d99e64462646
md"""
# 2. Generators, orbits, and quotients

Chapter 1 compressed an ordered sequence of coin flips into `(flips, heads)`. The compression worked for inferring which coin produced the data, but the chapter did not explain where that representation came from.

This chapter constructs the representation by composing transformations of the original representation. We will specify a small operation that changes a sequence, compose that operation to find all connected sequences, check which tasks stay constant across those sequences, and replace each set of task-equivalent sequences with one quotient coordinate.
"""

# ╔═╡ eefb02dc-8061-4f7a-9e06-5e6ef2245daa
md"""
## A local generator: swap two neighbours

Let ``\tau_i`` exchange flips at positions ``i`` and ``i+1``. This adjacent swap is a *generator*: a simple transformation whose compositions produce more complicated transformations.

"""

# ╔═╡ 4a6921dc-9c42-487e-ae49-e449424e12d8
function swap_adjacent(sequence, i)
    swapped = copy(sequence)
    swapped[i], swapped[i + 1] = swapped[i + 1], swapped[i]
    swapped
end

# ╔═╡ d58fac87-e34e-48d8-b90a-92bfbf40b140
show_sequence(sequence) = join(ifelse.(sequence, "H", "T"))

# ╔═╡ a071cd93-e156-4f0c-8444-c8167c9211d0
seed_sequence = [true, true, true, false] # HHHT

# ╔═╡ 98426849-bfe5-425c-900e-92be776cf39a
(
    swap_once = show_sequence(swap_adjacent(seed_sequence, 3)),
	swap_twice = show_sequence(swap_adjacent(swap_adjacent(seed_sequence, 3), 3)),
    swap_involution =
        swap_adjacent(swap_adjacent(seed_sequence, 3), 3) == seed_sequence,
    order_matters =
        swap_adjacent(swap_adjacent(seed_sequence, 2), 3) !=
        swap_adjacent(swap_adjacent(seed_sequence, 3), 2),
)

# ╔═╡ c8a316d8-2302-4869-9935-b0a9133b6527
md"""
Each swap is an *involution* because applying it twice returns the original sequence: ``\tau_i^2=e``, where ``e`` is the identity transformation. Composition also matters: swapping positions 2 and 3, then positions 3 and 4, can differ from reversing that order.

For sequences of length ``n``, the adjacent swaps generate the *symmetric group* ``S_n``, the group of all permutations of ``n`` positions. Composing two permutations produces another permutation, composition is associative, an identity leaves the sequence unchanged, and every permutation has an inverse. These group properties let us move around a structured family of sequences without changing their values, only their positions.
"""

# ╔═╡ 3a8bc4d7-f8c5-42f1-9b29-700569a4c15f
function permutation_orbit(sequence)
    seen = Set([Tuple(sequence)])
    frontier = [copy(sequence)]

    while !isempty(frontier)
        current = popfirst!(frontier)
        for i in 1:(length(current) - 1)
            candidate = swap_adjacent(current, i)
            key = Tuple(candidate)
            if key ∉ seen
                push!(seen, key)
                push!(frontier, candidate)
            end
        end
    end

    sort([collect(key) for key in seen], by = show_sequence)
end

# ╔═╡ fa19402a-5e85-424e-a763-175b0bf19a38
orbit = permutation_orbit(seed_sequence)

# ╔═╡ 418fab8f-9189-4207-b3c7-d73d62f9efbf
show_sequence.(orbit)

# ╔═╡ 93eee783-6141-42a6-9339-41d9fb8f4ec1
md"""
You should see `HHHT`, `HHTH`, `HTHH`, and `THHH`. `permutation_orbit` keeps a
collection of sequences it has seen and a queue of sequences whose neighbours
it still needs to visit. Each swap adds a new sequence only once.

Change the seed to two heads and two tails. Before running it, how many distinct
orderings do you expect? Keep the seed short: enumerating an orbit can grow quickly.
"""

# ╔═╡ 29691ca0-bf06-4b9a-823c-5797755e8f2b
md"""
## The orbit: every reachable observation

A group acts on a space when each group element transforms an object in that space. Here, ``S_4`` acts on four-flip sequences by permuting their positions. The *orbit* of `HHHT` is the set of sequences reachable under that action:

```math
\operatorname{Orb}(x)=\{g\cdot x:g\in S_4\}.
```

The orbit contains four sequences instead of ``4!=24`` because exchanging two identical heads does not produce a new sequence. More generally, a sequence with ``k`` heads has ``\binom{n}{k}`` distinct orbit members. The orbit reveals which raw distinctions arise only from order.

We now compare two questions from Chapter 1 across this orbit.
`is_fair_posterior` asks for the probability that the fair coin generated the
observed sequence, using the same prior and coin weights as Chapter 1.
`longest_head_run` asks for the largest number of consecutive heads in that
sequence. The first query infers a hidden coin type; the second computes a
property of the observed data. The table below evaluates both queries for every
orbit member so we can check which answers survive a change in flip order.
"""

# ╔═╡ c4bc0456-a9ee-4fbe-b019-207489a8df9e
is_fair_prior = 0.5

# ╔═╡ 5ca2b180-360a-4060-b00d-4bbab5d78c34
fair_weight = 0.5

# ╔═╡ fab79419-5f2b-48e0-938f-b8d5de3c04ff
trick_weight = 0.85

# ╔═╡ ffea1c21-b53f-44c8-8604-de2eb21b9456
is_fair_coin = @~ Bernoulli(is_fair_prior)

# ╔═╡ 46e5b1a6-1b7a-4f13-abb6-6fe01db9a498
count_representation(sequence) = (
    flips = length(sequence),
    heads = count(identity, sequence),
)

# ╔═╡ 7a368cd2-2d06-42a5-a2d7-d0833bad92d4
function is_fair_posterior(sequence)
    likelihood(weight) = prod(flip ? weight : 1 - weight for flip in sequence)
    fair_mass = is_fair_prior * likelihood(fair_weight)
    trick_mass = (1 - is_fair_prior) * likelihood(trick_weight)
    fair_mass / (fair_mass + trick_mass)
end

# ╔═╡ d68473f3-6e1e-4356-bd66-2d10134494a4
function longest_head_run(sequence)
    longest = 0
    current = 0
    for s in sequence
        current = s ? current + 1 : 0
        longest = max(longest, current)
    end
    longest
end

# ╔═╡ ea71f949-27d2-43df-a982-d5823240f2b5
orbit_table = [
    (
        sequence = show_sequence(sequence),
        representation = count_representation(sequence),
        fair_posterior = is_fair_posterior(sequence),
        longest_head_run = longest_head_run(sequence),
    )
    for sequence in orbit
]

# ╔═╡ c7b15d79-9a36-45d8-be13-494d33dc81b1
md"""
Read across the rows. Every ordering has three heads and the same fair-coin
posterior, about 0.404, but the longest head run is either two or three.
`count_representation` preserves the first answer and loses information needed
for the second. Try moving the tail by hand in `seed_sequence` and compare.
"""

# ╔═╡ 23171ad6-ce90-444a-b4cd-301625072c90
md"""
## Task invariants

A task ``T`` is *invariant* under a transformation ``g`` when

```math
T(g\cdot x)=T(x).
```

The fair-coin posterior is constant across the orbit because the conditionally independent coin model assigns the same likelihood to every permutation. The longest-run task varies across the same orbit because it depends on adjacency.

The transformations tell us which distinctions we *could* ignore; task invariance tells us which distinctions we may ignore without changing the answer.
"""

# ╔═╡ 9c3913d5-704e-407b-8a30-37b1eb13f442
function count_decoder(representation)
    n = representation.flips
    k = representation.heads
    fair_likelihood = fair_weight^k * (1 - fair_weight)^(n - k)
    trick_likelihood = trick_weight^k * (1 - trick_weight)^(n - k)
    fair_mass = is_fair_prior * fair_likelihood
    trick_mass = (1 - is_fair_prior) * trick_likelihood
    fair_mass / (fair_mass + trick_mass)
end

# ╔═╡ d1942514-c302-4c41-854b-2fd1656262d9
md"""
## From an orbit to a quotient

Define ``x\sim y`` when a permutation carries ``x`` to ``y``. This relation is an *equivalence relation*: every sequence is equivalent to itself, equivalence works in both directions, and equivalences compose. Its equivalence classes are the permutation orbits.

The *quotient space* ``X/S_n`` replaces every orbit in the original sequence space ``X`` with one object. For Boolean sequences of fixed length, the number of heads uniquely labels each quotient class. The map

```math
q(x)=(\operatorname{length}(x),\operatorname{heads}(x))
```

is a quotient map. The count representation is therefore a coordinate system for the permutation quotient.
"""

# ╔═╡ e198f3a9-15a2-4716-b774-297566c845d8
all_boolean_sequences(n) = [
    [isone((mask >> i) & 1) for i in 0:n-1]
    for mask in 0:(2^n - 1)
]

# ╔═╡ 0e3d905d-c13d-49bd-bce2-b687bb3a79ef
all_boolean_sequences(3)

# ╔═╡ 48a69650-fa64-4c11-b5de-809025e1b1d3
md"""
The next cell filters all Boolean sequences of the seed's length to those with
the same head count. These sequences form the seed's quotient class.
"""

# ╔═╡ 81d2cb4d-1a0f-4830-9027-b1c8dcbd98c4
count_class = filter(
	s -> (count_representation(s) == count_representation(seed_sequence)),
	all_boolean_sequences(length(seed_sequence))
)

# ╔═╡ 4664d6f7-7819-430a-8554-4acb2023f19e
(
    orbit_equals_count_class = Set(Tuple.(orbit)) == Set(Tuple.(count_class)),
    
	raw_sequence_count = length(all_boolean_sequences(4)),
    
	quotient_coordinate_count =
        length(unique(count_representation.(all_boolean_sequences(4)))),
    
	orbit_size = length(orbit),
)

# ╔═╡ b785c40d-a8b5-4cd2-bc75-75c6b0c83751
function quotient_classes(states, representation)
    classes = Dict{Any, Vector{Any}}()
    for state in states
        push!(get!(classes, representation(state), Any[]), state)
    end
    classes
end

# ╔═╡ 0e654f28-4a67-41d0-b646-f1339fc5d0dc
four_flip_quotient = quotient_classes(
    all_boolean_sequences(4),
    count_representation,
)

# ╔═╡ 7544520d-1088-4bb4-ab7f-74093b1bdd32
sort([(heads = coordinate.heads, class_size = length(class))
    for (coordinate, class) in four_flip_quotient], 
	 by = row -> row.heads)

# ╔═╡ 5f018a7d-142e-4f3e-9d61-953f94f3a63e
md"""
The quotient reduces the 16 ordered four-flip sequences to five coordinates, one for each possible head count. In general, it reduces ``2^n`` Boolean sequences to ``n+1`` count coordinates. Their class sizes for four flips are `1, 4, 6, 4, 1`, the corresponding binomial coefficients.

If a task is invariant on every class, it *factors through* the quotient:

```math
T = D\circ q.
```

Here, ``q`` is `count_representation`, and ``D`` computes the posterior from a head count. The factorisation makes the task easier because the solver no longer needs separate rules for `HHHT`, `HHTH`, `HTHH`, and `THHH`. It evaluates one decoder at their shared coordinate `(flips = 4, heads = 3)`. Across all length-``n`` observations, the decoder handles ``n+1`` inputs instead of ``2^n`` ordered inputs.

Try increasing the sequence length from four to five in the quotient cells. Compare the number of raw sequences with the number of head-count coordinates before deciding which space you would want to compute over.
"""

# ╔═╡ d31f7f48-217c-4a71-a344-f94701216d1e
md"""
## The quotient determines the count distribution

The distribution induced on the quotient by the original conditionally i.i.d. sequence model is binomial.

For a coin with head probability ``\theta``, every ordered sequence in the class labelled by ``(n,k)`` has probability

```math
\theta^k(1-\theta)^{n-k}.
```

The orbit contains ``\binom{n}{k}`` such sequences. Summing their equal probabilities gives the probability of the quotient coordinate:

```math
P(q(X)=(n,k)\mid\theta)
=\binom{n}{k}\theta^k(1-\theta)^{n-k}.
```

This expression is the probability mass function of ``\operatorname{Binomial}(n,\theta)``. Applying the quotient map to the ordered Bernoulli-sequence model therefore produces a binomial count model. We can generate and condition on the quotient coordinate directly instead of constructing an ordered sequence and then counting it.
"""

# ╔═╡ 0484323e-84f4-4864-aefa-fb5748382393
binomial_head_count(n, weight) = @~ Binomial(n, weight)

# ╔═╡ bb5647c5-c794-4295-a8d7-e24a72d0bdd0
observed_quotient_coordinate = count_representation(seed_sequence)

# ╔═╡ 9da2e32a-5bd5-4725-9e56-a9e184c21966
quotient_head_count(ω::Ω) = binomial_head_count(
        observed_quotient_coordinate.flips,
        is_fair_coin(ω) ? fair_weight : trick_weight,
    )(ω)

# ╔═╡ 0f08478d-a70f-4037-bdaa-6c2ac220026d
fair_coin_posterior = is_fair_coin |ᶜ
    ω -> (quotient_head_count(ω) .== observed_quotient_coordinate.heads)

# ╔═╡ 3470acaa-e4bc-45c5-b318-fea0cf20608e
posterior_samples = randsample(
    fair_coin_posterior,
    300,
    alg = RejectionSample,
)

# ╔═╡ 3344e29b-e5fb-4f29-a5c9-b15c314568d7
(
    sampled_fair_probability = sum(posterior_samples) / length(posterior_samples),
    exact_fair_probability = count_decoder(observed_quotient_coordinate),
)

# ╔═╡ afc53e76-c93f-40d0-9bfb-bfb912157f91
md"""
The posterior above conditions `is_fair_coin` on a count drawn directly from
`Binomial`. Each proposed world chooses a coin type and draws a head count for
the observed number of flips. Rejection sampling keeps the coin type when that
count matches `observed_quotient_coordinate.heads`.

Conditioning on the count gives the same coin posterior as conditioning on the
original sequence: the binomial coefficient multiplies both coin likelihoods
by the same amount and cancels when we normalise them. That cancellation also
explains why `count_decoder` can omit the coefficient. At the starting settings,
the exact probability is about 0.404; the estimate from 300 accepted samples
fluctuates around it. Try a seed with two heads, then with four heads, keeping
the length fixed. More heads favour the trick coin and lower the fair-coin
probability.
"""

# ╔═╡ d14da63b-9d12-48c3-91b3-14bebea2c584
md"""
## What the count cannot tell us

Now ask for the longest uninterrupted run of heads in the observed sequence.
The count coordinate records how many heads occurred, but discards where they
occurred. The starting orbit makes that loss explicit:

| Sequence | Count coordinate `(flips, heads)` | Longest head run |
|:--|:--|--:|
| `HHHT` | `(4, 3)` | 3 |
| `HHTH` | `(4, 3)` | 2 |
| `HTHH` | `(4, 3)` | 2 |
| `THHH` | `(4, 3)` | 3 |

Let ``L(x)`` denote the longest head run. A decoder that receives only
``q(x)=(4,3)`` must give the same answer for all four sequences. Hence, it
cannot return both ``L(\mathtt{HHHT})=3`` and ``L(\mathtt{HHTH})=2``.
No decoder ``D`` can satisfy ``L=D\circ q`` for every sequence: the run task
is not constant within a permutation orbit.

The next cells explore what remains uncertain when we know only the count.
`UniformDraw(orbit)` chooses an ordering uniformly from the seed's orbit.
Under our conditionally i.i.d. coin model, this uniform draw is the conditional distribution
of the sequence given its count: all orderings in the orbit have equal
probability under either coin. The first plot samples these orderings; the
second applies `longest_head_run` to each sampled ordering.
"""

# ╔═╡ 99113292-4f6b-4587-a16b-883e87335561
random_orbit_member = @~ UniformDraw(orbit)

# ╔═╡ 9e3a7f46-0c42-4459-b4aa-c7e1f8eac705
viz(show_sequence.(randsample(random_orbit_member, 400)))

# ╔═╡ 155d65f4-9d27-4c3d-95c9-0b722fefe11f
random_longest_run = longest_head_run ∘ random_orbit_member

# ╔═╡ 110f2caf-213f-4b44-864e-71fdb2f90afd
viz(randsample(random_longest_run, 400))

# ╔═╡ 27c2eaee-bf98-4fba-af39-9dd467e47639
md"""
For the starting seed `HHHT`, the first plot should give each ordering roughly
one quarter of the samples. The second should split roughly equally between
runs of length two and three, because two orbit members give each answer.
More samples make those proportions more stable; they cannot reveal which
ordering produced the original observation.

The count and the model thus determine a distribution over possible run
lengths, but the count does not determine the observed sequence's run length.
Choosing one orbit member, or reporting the mean run length of 2.5, cannot
recover that missing answer. If we need both the coin posterior and the exact
longest run, we could retain the sequence or compute and store its longest run
alongside the count before discarding the order.

## Discussion

Try `HHTT` as the seed by setting `seed_sequence` to `[true, true, false, false]`.
Its orbit has six members. Use `orbit_table` to predict the proportions of runs
of length one and two before sampling. Which task answers remain constant
throughout the orbit, and which vary? Why must the binomial count likelihood
include all six orderings even though the coin posterior decoder can cancel
that factor?

We chose adjacent swaps because they preserve the coin posterior in this
model. For the longest-run task, reversal still preserves the answer: it
reverses each run without changing its length. Arbitrary adjacent swaps can
split or join runs. Grouping a sequence with its reversal therefore preserves
the run task, while grouping all permutations loses too much.
"""

# ╔═╡ 136a8ae0-34ed-49b8-a3cd-35737fe260ab
md"""
---
## References

This notebook is part of a tutorial series introducing the ideas in Yu (2026).

- Yu, A. J. (2026). *The Art of Making Problems Simple: A Theory of Intelligence*. PsyArXiv. [doi:10.31234/osf.io/pghzn_v3](https://doi.org/10.31234/osf.io/pghzn_v3)
- Goodman, N. D., Tenenbaum, J. B., & The ProbMods Contributors (2016). *Probabilistic Models of Cognition* (2nd ed.). [probmods.org](https://probmods.org/)
- Tavares, Z., Koppel, J., Zhang, X., Das, R., & Solar-Lezama, A. (2021). A language for counterfactual generative models. *Proceedings of the 38th International Conference on Machine Learning*, PMLR 139, 10173–10182. [pdf](http://www.zenna.org/publications/causal.pdf)
"""

# ╔═╡ Cell order:
# ╠═38d37e89-dce4-4d4c-a7b7-06739e64f02d
# ╟─ca43a069-c726-4b3e-acf8-d99e64462646
# ╟─eefb02dc-8061-4f7a-9e06-5e6ef2245daa
# ╠═4a6921dc-9c42-487e-ae49-e449424e12d8
# ╠═d58fac87-e34e-48d8-b90a-92bfbf40b140
# ╠═a071cd93-e156-4f0c-8444-c8167c9211d0
# ╠═98426849-bfe5-425c-900e-92be776cf39a
# ╟─c8a316d8-2302-4869-9935-b0a9133b6527
# ╠═3a8bc4d7-f8c5-42f1-9b29-700569a4c15f
# ╠═fa19402a-5e85-424e-a763-175b0bf19a38
# ╠═418fab8f-9189-4207-b3c7-d73d62f9efbf
# ╟─93eee783-6141-42a6-9339-41d9fb8f4ec1
# ╟─29691ca0-bf06-4b9a-823c-5797755e8f2b
# ╠═c4bc0456-a9ee-4fbe-b019-207489a8df9e
# ╠═5ca2b180-360a-4060-b00d-4bbab5d78c34
# ╠═fab79419-5f2b-48e0-938f-b8d5de3c04ff
# ╠═ffea1c21-b53f-44c8-8604-de2eb21b9456
# ╠═46e5b1a6-1b7a-4f13-abb6-6fe01db9a498
# ╠═7a368cd2-2d06-42a5-a2d7-d0833bad92d4
# ╠═d68473f3-6e1e-4356-bd66-2d10134494a4
# ╠═ea71f949-27d2-43df-a982-d5823240f2b5
# ╟─c7b15d79-9a36-45d8-be13-494d33dc81b1
# ╟─23171ad6-ce90-444a-b4cd-301625072c90
# ╠═9c3913d5-704e-407b-8a30-37b1eb13f442
# ╟─d1942514-c302-4c41-854b-2fd1656262d9
# ╠═e198f3a9-15a2-4716-b774-297566c845d8
# ╠═0e3d905d-c13d-49bd-bce2-b687bb3a79ef
# ╟─48a69650-fa64-4c11-b5de-809025e1b1d3
# ╠═81d2cb4d-1a0f-4830-9027-b1c8dcbd98c4
# ╠═4664d6f7-7819-430a-8554-4acb2023f19e
# ╠═b785c40d-a8b5-4cd2-bc75-75c6b0c83751
# ╠═0e654f28-4a67-41d0-b646-f1339fc5d0dc
# ╠═7544520d-1088-4bb4-ab7f-74093b1bdd32
# ╟─5f018a7d-142e-4f3e-9d61-953f94f3a63e
# ╟─d31f7f48-217c-4a71-a344-f94701216d1e
# ╠═0484323e-84f4-4864-aefa-fb5748382393
# ╠═bb5647c5-c794-4295-a8d7-e24a72d0bdd0
# ╠═9da2e32a-5bd5-4725-9e56-a9e184c21966
# ╠═0f08478d-a70f-4037-bdaa-6c2ac220026d
# ╠═3470acaa-e4bc-45c5-b318-fea0cf20608e
# ╠═3344e29b-e5fb-4f29-a5c9-b15c314568d7
# ╟─afc53e76-c93f-40d0-9bfb-bfb912157f91
# ╟─d14da63b-9d12-48c3-91b3-14bebea2c584
# ╠═99113292-4f6b-4587-a16b-883e87335561
# ╠═9e3a7f46-0c42-4459-b4aa-c7e1f8eac705
# ╠═155d65f4-9d27-4c3d-95c9-0b722fefe11f
# ╠═110f2caf-213f-4b44-864e-71fdb2f90afd
# ╟─27c2eaee-bf98-4fba-af39-9dd467e47639
# ╟─136a8ae0-34ed-49b8-a3cd-35737fe260ab
