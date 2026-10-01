### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ a4056412-fa2f-4be6-a99b-a77cd5727980
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

# ╔═╡ 800bc200-95a6-44f1-a63f-f8672b9ae83e
md"""
# 4. Representational revision

The task stayed fixed in Chapters 1–3; in this chapter it changes. A learner
that stores head counts to answer the coin question is now asked for the longest
run of heads. Chapter 2 showed that the count cannot answer this question.

We ask two questions. How can a learner tell that its representation has become
insufficient, rather than that its decoder needs more training? And when it
revises the representation, what should it change to?

The paper makes the first point in general: If a distinction that the task
needs is missing from the current representation, no amount of optimisation
within that representation can recover it. The fix has to add the distinction.
"""

# ╔═╡ b65423b3-9237-4c89-b890-e0c6216b6119
md"""
## The model and the tasks

The coin model and the two tasks are the same as in Chapters 1–3.
"""

# ╔═╡ 298276b8-6f73-4b02-8ce5-7f591375d3cc
is_fair_prior = 0.5

# ╔═╡ b8f676d1-839e-4d93-bc3f-675a3291ea0a
fair_weight = 0.5

# ╔═╡ 56211c51-2348-49f6-a656-c331a36f050c
trick_weight = 0.85

# ╔═╡ 483b8436-6ed9-42c9-ba5f-8ff4566ffba0
is_fair_coin = @~ Bernoulli(is_fair_prior)

# ╔═╡ 88575880-c26d-4868-b785-c42238b8744a
coin_flip(i, ω) =
    (i ~ Bernoulli(is_fair_coin(ω) ? fair_weight : trick_weight))(ω)

# ╔═╡ d885d465-05bd-49c2-a5e3-d9122b17bb60
flip_sequence(n) = Variable(ω -> [coin_flip(i, ω) for i in 1:n])

# ╔═╡ efbee75f-6d12-48a2-9626-d7bf2bf4f0ed
show_sequence(sequence) = join(ifelse.(sequence, "H", "T"))

# ╔═╡ eb1a067b-910c-497b-b002-31f542337c47
function is_fair_posterior(sequence)
    likelihood(weight) = prod(flip ? weight : 1 - weight for flip in sequence)
    fair_mass = is_fair_prior * likelihood(fair_weight)
    trick_mass = (1 - is_fair_prior) * likelihood(trick_weight)
    fair_mass / (fair_mass + trick_mass)
end

# ╔═╡ 3097369e-640d-4b49-a425-e21c8cc8e0ac
function longest_head_run(sequence)
    longest = 0
    current = 0
    for s in sequence
        current = s ? current + 1 : 0
        longest = max(longest, current)
    end
    longest
end

# ╔═╡ 283f8f98-ac85-469f-8528-b5e05bf58388
all_boolean_sequences(n) = [
    [isone((mask >> i) & 1) for i in 0:n-1]
    for mask in 0:(2^n - 1)
]

# ╔═╡ 411164da-5885-447c-a766-7bf0b5d5ae30
md"""
## A library of representations

The learner can choose among four representations:

- `count` is the `(flips, heads)` pair from Chapter 1.
- `count_and_run` adds the longest head run as an extra coordinate.
- `reversal_form` is the reversal canonical form from Chapter 3: the alphabetically
  first of the sequence and its mirror image.
- `full_sequence` keeps every flip in order.
"""

# ╔═╡ ecb7f689-00b5-4a11-a906-ba96363287bc
count_representation(s) = (flips = length(s), heads = count(identity, s))

# ╔═╡ 4ef6e280-14a4-448a-87a1-e4d1e5d378fc
count_and_run(s) = (flips = length(s), heads = count(identity, s),
                    longest_run = longest_head_run(s))

# ╔═╡ d71832f6-3a8d-4ed1-a241-f5f13bc981d9
reversal_form(s) = min(show_sequence(s), show_sequence(reverse(s)))

# ╔═╡ 970e66a5-9450-4a5d-b9f4-1988307045ca
full_sequence(s) = show_sequence(s)

# ╔═╡ dbaabca4-ee5a-41eb-b941-fdf37c9e6bc4
representation_library = [
    :count => count_representation,
    :count_and_run => count_and_run,
    :reversal_form => reversal_form,
    :full_sequence => full_sequence,
]

# ╔═╡ 8b57ab48-a4df-4b78-9c58-e53ce9ef5e01
sequence_length = 4

# ╔═╡ aa49212a-7834-426c-914a-ed51eb507b33
coordinate_count(representation, n) =
    length(unique(representation.(all_boolean_sequences(n))))

# ╔═╡ 3834e74d-4329-4f91-8af0-ea9b2fca1dd4
[(representation = name, coordinates = coordinate_count(r, sequence_length))
 for (name, r) in representation_library]

# ╔═╡ 3fa9e631-20d6-41f6-af65-aaa222f9802c
md"""
For four flips the representations have 5, 7, 10 and 16 distinct coordinates.

The four form a chain in which each one keeps every distinction the previous
one keeps and adds more: two sequences that share a `reversal_form` also share a
`count_and_run`, and two that share a `count_and_run` also share a `count`.
`refines` checks this ordering over every sequence.
"""

# ╔═╡ 3464b0bb-1c87-4393-a508-57e66a2f52d2
refines(finer, coarser, n) = all(
    coarser(s) == coarser(t)
    for s in all_boolean_sequences(n) for t in all_boolean_sequences(n)
    if finer(s) == finer(t))

# ╔═╡ 18850471-dc50-464d-99b0-d14b7f81d4b6
[(finer = first(representation_library[i + 1]), coarser = first(representation_library[i]),
  refines = refines(last(representation_library[i + 1]), last(representation_library[i]),
                    sequence_length))
 for i in 1:length(representation_library) - 1]

# ╔═╡ bdfbfeab-2054-4cd3-9d97-8ce11e67452d
md"""
`count_and_run` may look like cheating, because it stores the answer to the new
task directly. It *expands* the representation: it adds an axis that the old
one lacked. Whether it is a good revision depends on the tasks that come next.
"""

# ╔═╡ 0bb78d50-6035-4338-9610-90bef43d548b
md"""
## Insufficient or badly tuned?

A learner that keeps the count can still change its decoder, which is a table
from count coordinates to answers. The best table answers each coordinate with
the most common answer among the training sequences that map to it.
`fit_decoder` builds that table from training data, and `test_error` measures
how often it is wrong on fresh sequences. A coordinate that never appeared in
training counts as an error.
"""

# ╔═╡ d9491aff-881f-4af3-bc82-d524fec9d5ce
function fit_decoder(representation, training, task)
    table = Dict{Any, Dict{Any, Int}}()
    for s in training
        answers = get!(table, representation(s), Dict{Any, Int}())
        answers[task(s)] = get(answers, task(s), 0) + 1
    end
    Dict(key => first(argmax(last, collect(answers))) for (key, answers) in table)
end

# ╔═╡ c7eea782-0f85-44ce-bde1-979f40b44607
test_error(representation, decoder, test, task) =
    mean(get(decoder, representation(s), missing) !== task(s) for s in test)

# ╔═╡ 0e3bf838-24e8-486e-9a9f-1f1c492d2665
training_sizes = [5, 20, 100, 1000]

# ╔═╡ 70702949-eeb4-4806-86dc-9de65757d907
training_pool = randsample(flip_sequence(sequence_length), maximum(training_sizes))

# ╔═╡ b5c43437-6429-4975-81a2-05f81f2567da
test_sequences = randsample(flip_sequence(sequence_length), 2000)

# ╔═╡ 0626ac27-c3fa-4dc1-85aa-19f9b206acce
learning_curve = [
    NamedTuple{(:training, first.(representation_library)...)}((
        m,
        [test_error(r, fit_decoder(r, training_pool[1:m], longest_head_run),
                    test_sequences, longest_head_run)
         for (_, r) in representation_library]...,
    ))
    for m in training_sizes
]

# ╔═╡ 58955a2d-2df3-4674-81e7-b77ccf346058
md"""
As the training set grows, the error of every representation except `count`
falls towards zero. The error of `count` levels off at about 0.27, however
much data it sees.

The next cell computes that floor exactly. For each coordinate, the best
possible decoder picks the answer with the most probability; whatever
probability is left over in that class is error that no table can avoid.
"""

# ╔═╡ b55b3644-da2a-4bdf-8fc7-9b67b3418bb4
function sequence_probability(s)
    n, k = length(s), count(identity, s)
    is_fair_prior * fair_weight^k * (1 - fair_weight)^(n - k) +
        (1 - is_fair_prior) * trick_weight^k * (1 - trick_weight)^(n - k)
end

# ╔═╡ 619a0e1f-4600-4f13-bc63-019f78c0d74e
function best_possible_error(representation, task, n)
    mass = Dict{Any, Dict{Any, Float64}}()
    for s in all_boolean_sequences(n)
        answers = get!(mass, representation(s), Dict{Any, Float64}())
        answers[task(s)] = get(answers, task(s), 0.0) + sequence_probability(s)
    end
    sum(sum(values(a)) - maximum(values(a)) for a in values(mass))
end

# ╔═╡ 8be2bfa9-9ca9-4023-9061-0e487863d20a
[(representation = name,
  best_possible_error = best_possible_error(r, longest_head_run, sequence_length))
 for (name, r) in representation_library]

# ╔═╡ e51fdc7b-b946-44d8-96fe-9964ad50318c
md"""
`count` has an error floor of about 0.27; the other representations have none.
The floor comes from the classes with two and three heads. In each, half the
sequences have one longest run and half have another, and they are equally
likely under both coins.

This floor is the diagnostic: more data and better decoding only move `count`
towards it. When the error stays above zero after the decoder has converged,
the problem is the representation, not the tuning. Removing the floor requires
moving up the chain to a representation that separates the sequences `count`
merges.
"""

# ╔═╡ 4cf06a64-a5f2-4fc0-af40-2e422e2fe5a7
md"""
## Revising the representation

We now infer which representation to use, in the same way as Chapter 3. The
prior favours representations with fewer coordinates, and we condition on
consistency with labelled examples.

The examples now come from a *stream of tasks*. The learner wants a single
representation that serves every task it has seen so far. A third task asks
whether the first flip is a head.
"""

# ╔═╡ e81235c7-d30c-4bd5-a52f-5add8a926d92
first_flip_is_head(s) = first(s)

# ╔═╡ dbe70caa-b9ac-4059-b829-bad0ee0858c2
task_stream = [
    :fair_posterior => is_fair_posterior,
    :longest_head_run => longest_head_run,
    :first_flip_is_head => first_flip_is_head,
]

# ╔═╡ e84f5e7e-8c2a-482e-9553-cbce869866cf
md"""
Each example records its task, a sequence and the answer. A representation is
consistent when no two examples from the same task share a coordinate but have
different answers.
"""

# ╔═╡ 41e37818-2943-4489-b978-1c23da2c6739
same_answer(a, b) = a isa AbstractFloat ? isapprox(a, b) : a == b

# ╔═╡ cea1c160-8c7c-4d2a-8781-a7b6b7324b77
function is_consistent(representation, examples)
    answers = Dict{Any, Any}()
    for (task_name, sequence, answer) in examples
        key = (task_name, representation(sequence))
        if haskey(answers, key)
            same_answer(answers[key], answer) || return false
        else
            answers[key] = answer
        end
    end
    true
end

# ╔═╡ c2f35a46-9e2e-43fe-947c-588d6930b21e
simplicity_strength = 1.0

# ╔═╡ fec70317-3008-46c4-a4b0-bfb8820d559b
prior = let
    weights = [coordinate_count(r, sequence_length)^(-simplicity_strength)
               for (_, r) in representation_library]
    weights / sum(weights)
end

# ╔═╡ be971a0e-224d-4542-9384-483cdb0376ed
representation_index = @~ Categorical(prior)

# ╔═╡ fc96bc20-2811-418f-879a-d3c5cc26038d
representation_name = Variable(ω -> first(representation_library[representation_index(ω)]))

# ╔═╡ bf7f1f27-20ef-4644-96b0-5555b9a4257b
revision_posterior(examples) = representation_name |ᶜ Variable(ω ->
    is_consistent(last(representation_library[representation_index(ω)]), examples))

# ╔═╡ f4c40e21-c11e-4a48-8d34-b510e131eb5e
md"""
`task_examples` draws `examples_per_task` sequences for each task and labels them.
After stage ``k``, the learner has seen the examples of the first ``k`` tasks.
"""

# ╔═╡ 44717321-41df-4494-8c61-4001d2fe4fb8
examples_per_task = 12

# ╔═╡ b8101295-05ed-4ae9-bc4f-0b6906fad392
task_examples = [
    [(name, s, task(s)) for s in randsample(flip_sequence(sequence_length), examples_per_task)]
    for (name, task) in task_stream
]

# ╔═╡ 12581cba-4233-4572-a560-4c13c889d7f5
examples_up_to(stage) = reduce(vcat, task_examples[1:stage])

# ╔═╡ 1a40e78d-941f-4a2e-bfff-db2fad4c5048
stage_samples = [
    randsample(revision_posterior(examples_up_to(stage)), 400; alg = RejectionSample)
    for stage in eachindex(task_stream)
]

# ╔═╡ 03a53895-e226-460c-9cb4-4e5313797f1d
stage_table = [
    NamedTuple{(:after_task, first.(representation_library)...)}((
        first(task_stream[stage]),
        [count(==(name), stage_samples[stage]) / length(stage_samples[stage])
         for (name, _) in representation_library]...,
    ))
    for stage in eachindex(task_stream)
]

# ╔═╡ 04de4186-6656-4b21-9f7b-62260706d57b
md"""
Read the table one row at a time.

1. After the fair-coin task, every representation is consistent, so the
   posterior matches the prior and `count` is most probable.
2. After the longest-run task, `count` usually drops to zero: some pair of
   examples has the same head count but different runs. `count_and_run` is now
   the cheapest consistent choice.
3. After the first-flip task, `count_and_run` and `reversal_form` usually drop to
   zero too, and only `full_sequence` remains.

The examples are random, so a stage can fail to rule out a representation. If a
row looks different, rerun `task_examples` or raise `examples_per_task`.

A conflict triggered each revision, and a conflict is the example-level version
of the error floor above. A learner that revises its representation therefore
has several distinct jobs: detect a mismatch, decide whether better tuning
within the current representation could fix it, and propose a new
representation when it cannot.

As in Chapter 3, this learner chooses from a library we supplied. Every move
here is along a chain we built in advance. A learner that constructs the next
representation itself faces a much harder search.
"""

# ╔═╡ 07116bfd-f32d-43f6-ab55-b7c245fa3a04
md"""
## Which revision carries over?

At stage 2, `count_and_run` and `reversal_form` both fix the failure, and the
prior prefers `count_and_run` because it is smaller. The next cell checks, over
every sequence, which representations would suffice for other tasks the learner
might meet next.
"""

# ╔═╡ 58fb6c60-b6b7-47e8-bc9e-aa5c5f542149
longest_tail_run(s) = longest_head_run(.!s)

# ╔═╡ 2ec2bda8-05ff-42e3-a084-33f83584e686
number_of_runs(s) = 1 + count(s[i] != s[i + 1] for i in 1:length(s) - 1)

# ╔═╡ 1e53051b-e406-4901-ae45-e2938fd9cf35
future_tasks = [
    :longest_tail_run => longest_tail_run,
    :number_of_runs => number_of_runs,
    :first_flip_is_head => first_flip_is_head,
]

# ╔═╡ f146ebb5-8965-44ca-b05e-ff0ce83b4ec4
is_sufficient(representation, task, n) =
    is_consistent(representation, [(:task, s, task(s)) for s in all_boolean_sequences(n)])

# ╔═╡ 0980d096-2563-47fc-8e7d-504d2737d3a2
[NamedTuple{(:representation, first.(future_tasks)...)}((
     name, [is_sufficient(r, task, sequence_length) for (_, task) in future_tasks]...))
 for (name, r) in representation_library]

# ╔═╡ 139033a5-e664-41cd-9ebb-a87297ca4900
md"""
`count_and_run` answers the task it was built for and nothing else on this list.
`reversal_form` also answers the longest tail run and the number of runs.
Neither answers the first-flip question, which needs the order itself.

Part of this result is unsurprising: `reversal_form` is finer, and `full_sequence`,
the finest, answers everything. The interesting point is *why* `reversal_form`
stops where it does. It groups a sequence only with its mirror image, and
reversal preserves every run. So it discards exactly the distinctions that no
run-based task needs, and keeps the rest. `count_and_run` was built from one
answer and has no such reason to carry over. A representation derived from a
transformation that the tasks respect tends to transfer to related tasks; one
built by storing an answer does not.

The best revision therefore depends on which tasks come next, and a learner
rarely knows that in advance. When tasks keep changing, no single
representation stays best, so revising a representation is never finished.

## Discussion

Use `HHHT` and `HTHH`. What observation first tells you that `count` has become
insufficient for the longest run? Would that observation also tell you which
representation to switch to?

Reorder `task_stream` so that the first-flip task comes second. Which
representations survive each stage now? Does the learner end in the same place?

Chapter 3 derived `reversal_form` from a generator, while we built `count_and_run`
by adding an answer. Which kind of revision would you expect to transfer
better to a new domain? Chapter 5 takes up that question.
"""

# ╔═╡ ef21e37c-a9ae-436f-9bc4-37587fb8d390
md"""
---
## References

This notebook is part of a tutorial series introducing the ideas in Yu (2026).

- Yu, A. J. (2026). *The Art of Making Problems Simple: A Theory of Intelligence*. PsyArXiv. [doi:10.31234/osf.io/pghzn_v3](https://doi.org/10.31234/osf.io/pghzn_v3)
- Goodman, N. D., Tenenbaum, J. B., & The ProbMods Contributors (2016). *Probabilistic Models of Cognition* (2nd ed.). [probmods.org](https://probmods.org/)
- Tavares, Z., Koppel, J., Zhang, X., Das, R., & Solar-Lezama, A. (2021). A language for counterfactual generative models. *Proceedings of the 38th International Conference on Machine Learning*, PMLR 139, 10173–10182. [pdf](http://www.zenna.org/publications/causal.pdf)
"""

# ╔═╡ Cell order:
# ╠═a4056412-fa2f-4be6-a99b-a77cd5727980
# ╟─800bc200-95a6-44f1-a63f-f8672b9ae83e
# ╟─b65423b3-9237-4c89-b890-e0c6216b6119
# ╠═298276b8-6f73-4b02-8ce5-7f591375d3cc
# ╠═b8f676d1-839e-4d93-bc3f-675a3291ea0a
# ╠═56211c51-2348-49f6-a656-c331a36f050c
# ╠═483b8436-6ed9-42c9-ba5f-8ff4566ffba0
# ╠═88575880-c26d-4868-b785-c42238b8744a
# ╠═d885d465-05bd-49c2-a5e3-d9122b17bb60
# ╠═efbee75f-6d12-48a2-9626-d7bf2bf4f0ed
# ╠═eb1a067b-910c-497b-b002-31f542337c47
# ╠═3097369e-640d-4b49-a425-e21c8cc8e0ac
# ╠═283f8f98-ac85-469f-8528-b5e05bf58388
# ╟─411164da-5885-447c-a766-7bf0b5d5ae30
# ╠═ecb7f689-00b5-4a11-a906-ba96363287bc
# ╠═4ef6e280-14a4-448a-87a1-e4d1e5d378fc
# ╠═d71832f6-3a8d-4ed1-a241-f5f13bc981d9
# ╠═970e66a5-9450-4a5d-b9f4-1988307045ca
# ╠═dbaabca4-ee5a-41eb-b941-fdf37c9e6bc4
# ╠═8b57ab48-a4df-4b78-9c58-e53ce9ef5e01
# ╠═aa49212a-7834-426c-914a-ed51eb507b33
# ╠═3834e74d-4329-4f91-8af0-ea9b2fca1dd4
# ╟─3fa9e631-20d6-41f6-af65-aaa222f9802c
# ╠═3464b0bb-1c87-4393-a508-57e66a2f52d2
# ╠═18850471-dc50-464d-99b0-d14b7f81d4b6
# ╟─bdfbfeab-2054-4cd3-9d97-8ce11e67452d
# ╟─0bb78d50-6035-4338-9610-90bef43d548b
# ╠═d9491aff-881f-4af3-bc82-d524fec9d5ce
# ╠═c7eea782-0f85-44ce-bde1-979f40b44607
# ╠═0e3bf838-24e8-486e-9a9f-1f1c492d2665
# ╠═70702949-eeb4-4806-86dc-9de65757d907
# ╠═b5c43437-6429-4975-81a2-05f81f2567da
# ╠═0626ac27-c3fa-4dc1-85aa-19f9b206acce
# ╟─58955a2d-2df3-4674-81e7-b77ccf346058
# ╠═b55b3644-da2a-4bdf-8fc7-9b67b3418bb4
# ╠═619a0e1f-4600-4f13-bc63-019f78c0d74e
# ╠═8be2bfa9-9ca9-4023-9061-0e487863d20a
# ╟─e51fdc7b-b946-44d8-96fe-9964ad50318c
# ╟─4cf06a64-a5f2-4fc0-af40-2e422e2fe5a7
# ╠═e81235c7-d30c-4bd5-a52f-5add8a926d92
# ╠═dbe70caa-b9ac-4059-b829-bad0ee0858c2
# ╟─e84f5e7e-8c2a-482e-9553-cbce869866cf
# ╠═41e37818-2943-4489-b978-1c23da2c6739
# ╠═cea1c160-8c7c-4d2a-8781-a7b6b7324b77
# ╠═c2f35a46-9e2e-43fe-947c-588d6930b21e
# ╠═fec70317-3008-46c4-a4b0-bfb8820d559b
# ╠═be971a0e-224d-4542-9384-483cdb0376ed
# ╠═fc96bc20-2811-418f-879a-d3c5cc26038d
# ╠═bf7f1f27-20ef-4644-96b0-5555b9a4257b
# ╟─f4c40e21-c11e-4a48-8d34-b510e131eb5e
# ╠═44717321-41df-4494-8c61-4001d2fe4fb8
# ╠═b8101295-05ed-4ae9-bc4f-0b6906fad392
# ╠═12581cba-4233-4572-a560-4c13c889d7f5
# ╠═1a40e78d-941f-4a2e-bfff-db2fad4c5048
# ╠═03a53895-e226-460c-9cb4-4e5313797f1d
# ╟─04de4186-6656-4b21-9f7b-62260706d57b
# ╟─07116bfd-f32d-43f6-ab55-b7c245fa3a04
# ╠═58fb6c60-b6b7-47e8-bc9e-aa5c5f542149
# ╠═2ec2bda8-05ff-42e3-a084-33f83584e686
# ╠═1e53051b-e406-4901-ae45-e2938fd9cf35
# ╠═f146ebb5-8965-44ca-b05e-ff0ce83b4ec4
# ╠═0980d096-2563-47fc-8e7d-504d2737d3a2
# ╟─139033a5-e664-41cd-9ebb-a87297ca4900
# ╟─ef21e37c-a9ae-436f-9bc4-37587fb8d390
