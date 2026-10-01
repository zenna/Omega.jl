### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 253ae5d0-703b-40d2-9baa-0234969f375b
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

# ╔═╡ f061924f-febe-4253-b604-d1cdb357baca
md"""
# 5. Transfer and abstract reasoning

Chapters 2–4 worked in a single domain: coin flips. This chapter asks what
carries over to a new domain. We use a small puzzle in the style of Raven's
Progressive Matrices. Each row shows an object pattern changing twice under the
same rule. The rows use different objects, and the last row uses objects that
never appeared before.

The learner has to decide what to carry over: the objects, a mapping between
objects, or the transformation itself. The paper's answer is that structure
transfers along a *structure-preserving map*: a correspondence between the new
domain and a familiar one that the transformations respect. When such a map
exists, a learner can reuse what it learned in the familiar domain without
rediscovering it.
"""

# ╔═╡ f2e5d8bc-9dd9-4e42-bc31-e40747d8b1bb
md"""
## Panels and rows

A panel is a short list of symbols, and a row is a list of panels. `make_row`
builds a row by applying a rule to the first panel, then to the result.
"""

# ╔═╡ 5d7e5446-7fe0-4d5e-8ea5-996ad9c03ae8
show_panel(panel) = join(string.(panel), " ")

# ╔═╡ f99c6cc7-c116-4bf6-8df7-710e9fc1e5f0
show_row(row) = join(show_panel.(row), "  |  ")

# ╔═╡ 523d8b93-8956-4e92-81fc-a9f3f7648435
make_row(rule, first_panel) = [first_panel, rule(first_panel), rule(rule(first_panel))]

# ╔═╡ 1c616d51-2854-4400-8f86-4be465ec82d3
md"""
## Positional rules

The rules below rearrange positions and never look at which symbol sits where.
They are the kind of generator Chapters 2 and 3 used for coin flips.
"""

# ╔═╡ fde7aff8-5b71-4411-93bd-364878febd1a
identity_panel(panel) = panel

# ╔═╡ ca93a883-c002-4375-ac81-1d2e69a58ff7
reverse_panel(panel) = reverse(panel)

# ╔═╡ 93c79bc1-7e6e-48ee-8e0d-43268cd1424d
rotate_panel(panel) = circshift(panel, 1)

# ╔═╡ 7a73163e-e7c0-4a4d-b702-efaf2447cb32
swap_first_two(panel) = [panel[2], panel[1], panel[3:end]...]

# ╔═╡ ba375c29-e7f8-4d37-a65c-0bd5dac4615b
positional_rules = [
    :identity => identity_panel,
    :reverse => reverse_panel,
    :rotate => rotate_panel,
    :swap_first_two => swap_first_two,
]

# ╔═╡ 4b091584-9e4e-41c2-a935-6ada28cac44a
md"""
## The puzzle

Both example rows use `rotate_panel`. The first row uses colours and the second
uses shapes. The query row shows only its first panel, in letters.
"""

# ╔═╡ 1f84a961-980e-4755-8f71-ec78f2fe84dd
colour_row = make_row(rotate_panel, [:red, :green, :blue])

# ╔═╡ 08c88244-6cc8-41aa-815b-871028b979ee
shape_row = make_row(rotate_panel, [:circle, :circle, :square])

# ╔═╡ 09d8e1f8-3849-4e90-a297-99396ee6bcdc
query_first = [:x, :y, :z]

# ╔═╡ bc792834-a970-4d58-b333-9803b7bede56
show_row.([colour_row, shape_row])

# ╔═╡ 0665fbde-c368-4bd3-98f4-fb77fb76d4ef
md"""
Before reading on, fill in the query row yourself. What should follow `x y z`?
"""

# ╔═╡ 9e21cb43-5e25-4daf-a1dc-1d1b5f2c1fa3
md"""
## An object-level rule

A second kind of rule works on symbols rather than positions. A *substitution*
maps each symbol to another: in the colour row, red becomes blue, green becomes
red and blue becomes green. That mapping reproduces the colour row exactly.

`learn_substitution` tries to build one mapping that explains every transition
in the given rows. It returns `nothing` if some symbol would have to map to two
different symbols.
"""

# ╔═╡ 1bcf2b01-c0d4-4c03-bca5-ac6202728c48
function learn_substitution(rows)
    mapping = Dict{Symbol, Symbol}()
    for row in rows, t in 1:length(row) - 1
        for (a, b) in zip(row[t], row[t + 1])
            get!(mapping, a, b) == b || return nothing
        end
    end
    mapping
end

# ╔═╡ 0af3763e-aa50-44c0-b158-f811abd26678
learn_substitution([colour_row])

# ╔═╡ cd268c6a-9322-421a-90af-c50f1a746fd7
learn_substitution([colour_row, shape_row])

# ╔═╡ 5dd45057-977a-4f69-9a3b-304fdc058a7f
md"""
The colour row alone yields a mapping. Adding the shape row breaks it: in the
first transition, one circle stays a circle while the other becomes a square.
Even when a substitution fits, it only covers the symbols it has seen. On its
own, it has nothing to say about `x`, `y` or `z`.
"""

# ╔═╡ caac0dbc-8992-4d0d-85aa-737c23169548
md"""
## Inferring the rule

The hypotheses are the four positional rules and the substitution. Each is
*consistent* with a set of rows if it reproduces every transition in them.
To complete the query row, a positional rule applies itself twice. A
substitution applies its mapping when it knows every symbol; otherwise the
learner has no basis for an answer and guesses among the options.
"""

# ╔═╡ dfa34d9a-51e0-411c-a4cf-1813839368f0
rule_named = Dict(positional_rules)

# ╔═╡ 615b1c97-6d46-4c49-99a1-ca596ca39244
hypotheses = [first.(positional_rules)..., :substitution]

# ╔═╡ 5e9b8efe-b8ed-4326-8efc-a89a24cab377
function fits(hypothesis, rows)
    hypothesis == :substitution && return learn_substitution(rows) !== nothing
    rule = rule_named[hypothesis]
    all(rule(row[t]) == row[t + 1] for row in rows for t in 1:length(row) - 1)
end

# ╔═╡ 635114a8-8c73-40b5-810e-cc81db76582a
function complete_row(hypothesis, rows, first_panel)
    hypothesis == :substitution || return make_row(rule_named[hypothesis], first_panel)
    mapping = learn_substitution(rows)
    (mapping === nothing || !all(haskey(mapping, s) for s in first_panel)) && return nothing
    substitute(panel) = [mapping[s] for s in panel]
    make_row(substitute, first_panel)
end

# ╔═╡ 3857a061-0c0a-4776-9d82-f759c5bb11c7
md"""
The answer options are what each positional rule predicts, plus one distractor
that copies the later colour panels instead of transforming the letters.
"""

# ╔═╡ bc8b6f72-4fd0-42f5-bb0a-798b56cbddfa
answer_options = unique([
    [make_row(rule, query_first) for (_, rule) in positional_rules]...,
    [query_first, colour_row[2], colour_row[3]],
])

# ╔═╡ c4cf3664-c5ea-414c-838d-b5a19e5d14fe
show_row.(answer_options)

# ╔═╡ fd0a6985-6be1-409a-b4c4-a5b7ea95f49c
md"""
The model draws a hypothesis uniformly, completes the query row, and conditions
on the hypothesis fitting the example rows. When a hypothesis cannot complete
the row, `:guess` picks one of the options uniformly.
"""

# ╔═╡ c2ab8733-577e-47a2-a172-6b6418664532
hypothesis_index = @~ Categorical(fill(1 / length(hypotheses), length(hypotheses)))

# ╔═╡ 48765dff-aed4-4a5c-9191-f41066150c3f
hypothesis = Variable(ω -> hypotheses[hypothesis_index(ω)])

# ╔═╡ 5596bbed-c864-4b7d-bc95-a8ac6ee94714
completion(rows) = Variable(ω -> begin
    completed = complete_row(hypothesis(ω), rows, query_first)
    completed === nothing ? (:guess ~ UniformDraw(answer_options))(ω) : completed
end)

# ╔═╡ bd166956-55c6-4c70-9be1-59c549bd1c61
answer_posterior(rows) =
    completion(rows) |ᶜ Variable(ω -> fits(hypothesis(ω), rows))

# ╔═╡ bb3fe8d9-eb6e-4f55-966a-73bca5370d71
rule_posterior(rows) =
    hypothesis |ᶜ Variable(ω -> fits(hypothesis(ω), rows))

# ╔═╡ 3a05c21b-3b42-4d9e-8aee-b5025dd2b38a
md"""
## One example row

First the learner sees only the colour row.
The UnicodePlots bar charts show sampled posterior probabilities, keeping all
rules and answer options in the same order even when their probability is zero.
"""

# ╔═╡ 89f6b501-6edb-402a-a294-acf3db2e1276
one_row = [colour_row]

# ╔═╡ 8f69a7db-f7ea-438b-a7cc-325ce8c24a37
function posterior_plot(samples, labels; title)
    probabilities = [count(==(label), samples) / length(samples) for label in labels]
    UnicodePlots.barplot(labels, probabilities;
        title, xlabel = "Sampled probability", maximum = 1.0, width = 40)
end

# ╔═╡ 4e55104a-97c9-468f-b5ad-0ee568571919
posterior_plot(
    string.(randsample(rule_posterior(one_row), 400; alg = RejectionSample)),
    string.(hypotheses); title = "Rules after one example row")

# ╔═╡ db67a802-a286-47f1-962b-608f25250ee6
posterior_plot(
    show_row.(randsample(answer_posterior(one_row), 400; alg = RejectionSample)),
    show_row.(answer_options); title = "Answers after one example row")

# ╔═╡ 6ece071a-338a-456d-87ce-e670418db7ae
md"""
Two hypotheses fit the colour row: `rotate` and the substitution. They split
the posterior roughly in half. `rotate` predicts `x y z | z x y | y z x`. The
substitution knows nothing about letters, so it guesses; we return to this
guess below. The rotated answer therefore gets about 0.6 of the samples, and each other option about 0.1.

The colour row does not distinguish a transformation of positions from a
mapping between colours, since both explain it equally well.
"""

# ╔═╡ e8f486cd-7aca-4ddc-9fec-98ee380cd876
md"""
## Two example rows
"""

# ╔═╡ 6309b1a8-d5e8-41ef-9f4e-b48612126ae8
two_rows = [colour_row, shape_row]

# ╔═╡ bd3b9909-90fa-48d5-965d-3cde2c9473eb
posterior_plot(
    string.(randsample(rule_posterior(two_rows), 400; alg = RejectionSample)),
    string.(hypotheses); title = "Rules after two example rows")

# ╔═╡ 8e8fdad6-13a6-4080-a123-d4ea0db1bc68
posterior_plot(
    show_row.(randsample(answer_posterior(two_rows), 400; alg = RejectionSample)),
    show_row.(answer_options); title = "Answers after two example rows")

# ╔═╡ 232ee465-f098-4906-9fbb-3f079cf0c966
md"""
The shape row rules out the substitution, so only `rotate` remains and every
sample gives the rotated answer. The shape row helped by repeating a symbol:
it has two circles that end up in different places, which no mapping between
symbols can explain.

Try `[shape_row[1:2]]`, the first transition of the shape row alone. Which rules
fit it? Rotating `circle circle square` and reversing it give the same panel,
so a single transition can leave two positional rules tied.
"""

# ╔═╡ 48cf103e-e929-4732-9690-3d244275df15
md"""
## Why the rotation transfers

To reuse something learned about colours on letters, a learner needs a
correspondence between the domains: a map ``\varphi`` from the new domain to the
familiar one, saying which colour each letter plays. A rule ``g`` carries over
along ``\varphi`` when transforming a letter panel and then translating it gives
the same result as translating first and then transforming:

```math
\varphi(g(p)) = g(\varphi(p)).
```

Positional rules satisfy this equation for *every* correspondence, because they move
symbols without inspecting them. The next cells list all six ways to match the
three letters with the three colours and check each positional rule against all
of them.
"""

# ╔═╡ 4ce97fc8-59a5-4e6a-9a36-0454761d1209
colours = [:red, :green, :blue]

# ╔═╡ 288c715f-87e6-4372-93ed-9a1d66dfd5ab
all_correspondences = [
    Dict(:x => a, :y => b, :z => c)
    for a in colours for b in colours for c in colours if allunique((a, b, c))
]

# ╔═╡ f774d576-2831-4ebc-a019-b82026c58d1f
translate(correspondence, panel) = [correspondence[s] for s in panel]

# ╔═╡ c060f671-bac0-480a-99ad-963d10260bcd
[(rule = name,
  carries_over_for_every_correspondence = all(
      translate(φ, rule(query_first)) == rule(translate(φ, query_first))
      for φ in all_correspondences))
 for (name, rule) in positional_rules]

# ╔═╡ b9fbb4ed-b7ef-47de-8ae6-213b4eb8170d
md"""
Every positional rule passes. A learner that stored the rotation can apply it to
letters without working out which letter corresponds to which colour.

The substitution is a table on colours. Given a correspondence, we *can* carry
it to letters: translate each letter to its colour, substitute, and translate
back. The next cell does this translation for all six correspondences.
"""

# ╔═╡ 0774acc9-15ae-4731-b351-36ce41dc1fee
colour_substitution = learn_substitution([colour_row])

# ╔═╡ bf7532fb-dd51-4d50-9bd6-af9d0c8ff4af
function transported_completion(φ)
    back = Dict(colour => letter for (letter, colour) in φ)
    step(panel) = [back[colour_substitution[φ[s]]] for s in panel]
    show_row(make_row(step, query_first))
end

# ╔═╡ 8aae5082-6519-45ff-aad0-8c989a084e4b
[(correspondence = join(["$(letter) → $(colour)" for (letter, colour) in sort(collect(φ))], ", "),
  completion = transported_completion(φ))
 for φ in all_correspondences]

# ╔═╡ bbd757d0-3d27-4859-a212-ed969f0e9ccb
md"""
With `x → red`, `y → green`, `z → blue`, the carried-over substitution gives the
same answer as the rotation. But half of the correspondences give the rotated
answer and the other half rotate the other way. So the substitution can
transfer, but only once the learner knows which letter plays which colour, and
the puzzle does not say.

The rotation and the substitution differ as relations and attributes do in
analogy, a distinction Gentner (1983) emphasised. How positions move is a relation, and it carries over
to any objects. Which colour becomes which is an attribute of particular
objects, and it carries over only if the objects themselves can be matched. The two
rules also differ in cost: the substitution needs a table with one entry per
symbol, plus a correspondence for each new domain; the rotation is one choice
among four rules, whatever the objects are.
"""

# ╔═╡ b8f11133-5899-44ce-bb7f-a8a6287f0149
md"""
## Discussion

Add a rule that acts on values: replace each colour with the next one in the
cycle red, green, blue. Does it explain the colour row? Could you apply it to
letters? What extra structure, such as an order on the letters, would the letter
domain need for this rule to transfer?

Chapter 4's `count_and_run` stored an answer, while `reversal_form` came from a
generator. How does that contrast resemble the one between the substitution and
the rotation here?

Here we supplied the rules. What would a learner need to discover
`rotate_panel` from the rows themselves?
"""

# ╔═╡ 322d461f-bc9b-4e0b-a676-33203fa2ce79
md"""
---
## References

This notebook is part of a tutorial series introducing the ideas in Yu (2026).

- Yu, A. J. (2026). *The Art of Making Problems Simple: A Theory of Intelligence*. PsyArXiv. [doi:10.31234/osf.io/pghzn_v3](https://doi.org/10.31234/osf.io/pghzn_v3)
- Goodman, N. D., Tenenbaum, J. B., & The ProbMods Contributors (2016). *Probabilistic Models of Cognition* (2nd ed.). [probmods.org](https://probmods.org/)
- Tavares, Z., Koppel, J., Zhang, X., Das, R., & Solar-Lezama, A. (2021). A language for counterfactual generative models. *Proceedings of the 38th International Conference on Machine Learning*, PMLR 139, 10173–10182. [pdf](http://www.zenna.org/publications/causal.pdf)
- Gentner, D. (1983). Structure-mapping: A theoretical framework for analogy. *Cognitive Science*, 7(2), 155–170.
- Raven, J. C. (1938). *Progressive Matrices*. H. K. Lewis.
"""

# ╔═╡ Cell order:
# ╠═253ae5d0-703b-40d2-9baa-0234969f375b
# ╟─f061924f-febe-4253-b604-d1cdb357baca
# ╟─f2e5d8bc-9dd9-4e42-bc31-e40747d8b1bb
# ╠═5d7e5446-7fe0-4d5e-8ea5-996ad9c03ae8
# ╠═f99c6cc7-c116-4bf6-8df7-710e9fc1e5f0
# ╠═523d8b93-8956-4e92-81fc-a9f3f7648435
# ╟─1c616d51-2854-4400-8f86-4be465ec82d3
# ╠═fde7aff8-5b71-4411-93bd-364878febd1a
# ╠═ca93a883-c002-4375-ac81-1d2e69a58ff7
# ╠═93c79bc1-7e6e-48ee-8e0d-43268cd1424d
# ╠═7a73163e-e7c0-4a4d-b702-efaf2447cb32
# ╠═ba375c29-e7f8-4d37-a65c-0bd5dac4615b
# ╟─4b091584-9e4e-41c2-a935-6ada28cac44a
# ╠═1f84a961-980e-4755-8f71-ec78f2fe84dd
# ╠═08c88244-6cc8-41aa-815b-871028b979ee
# ╠═09d8e1f8-3849-4e90-a297-99396ee6bcdc
# ╠═bc792834-a970-4d58-b333-9803b7bede56
# ╟─0665fbde-c368-4bd3-98f4-fb77fb76d4ef
# ╟─9e21cb43-5e25-4daf-a1dc-1d1b5f2c1fa3
# ╠═1bcf2b01-c0d4-4c03-bca5-ac6202728c48
# ╠═0af3763e-aa50-44c0-b158-f811abd26678
# ╠═cd268c6a-9322-421a-90af-c50f1a746fd7
# ╟─5dd45057-977a-4f69-9a3b-304fdc058a7f
# ╟─caac0dbc-8992-4d0d-85aa-737c23169548
# ╠═dfa34d9a-51e0-411c-a4cf-1813839368f0
# ╠═615b1c97-6d46-4c49-99a1-ca596ca39244
# ╠═5e9b8efe-b8ed-4326-8efc-a89a24cab377
# ╠═635114a8-8c73-40b5-810e-cc81db76582a
# ╟─3857a061-0c0a-4776-9d82-f759c5bb11c7
# ╠═bc8b6f72-4fd0-42f5-bb0a-798b56cbddfa
# ╠═c4cf3664-c5ea-414c-838d-b5a19e5d14fe
# ╟─fd0a6985-6be1-409a-b4c4-a5b7ea95f49c
# ╠═c2ab8733-577e-47a2-a172-6b6418664532
# ╠═48765dff-aed4-4a5c-9191-f41066150c3f
# ╠═5596bbed-c864-4b7d-bc95-a8ac6ee94714
# ╠═bd166956-55c6-4c70-9be1-59c549bd1c61
# ╠═bb3fe8d9-eb6e-4f55-966a-73bca5370d71
# ╟─3a05c21b-3b42-4d9e-8aee-b5025dd2b38a
# ╠═89f6b501-6edb-402a-a294-acf3db2e1276
# ╠═8f69a7db-f7ea-438b-a7cc-325ce8c24a37
# ╠═4e55104a-97c9-468f-b5ad-0ee568571919
# ╠═db67a802-a286-47f1-962b-608f25250ee6
# ╟─6ece071a-338a-456d-87ce-e670418db7ae
# ╟─e8f486cd-7aca-4ddc-9fec-98ee380cd876
# ╠═6309b1a8-d5e8-41ef-9f4e-b48612126ae8
# ╠═bd3b9909-90fa-48d5-965d-3cde2c9473eb
# ╠═8e8fdad6-13a6-4080-a123-d4ea0db1bc68
# ╟─232ee465-f098-4906-9fbb-3f079cf0c966
# ╟─48cf103e-e929-4732-9690-3d244275df15
# ╠═4ce97fc8-59a5-4e6a-9a36-0454761d1209
# ╠═288c715f-87e6-4372-93ed-9a1d66dfd5ab
# ╠═f774d576-2831-4ebc-a019-b82026c58d1f
# ╠═c060f671-bac0-480a-99ad-963d10260bcd
# ╟─b9fbb4ed-b7ef-47de-8ae6-213b4eb8170d
# ╠═0774acc9-15ae-4731-b351-36ce41dc1fee
# ╠═bf7532fb-dd51-4d50-9bd6-af9d0c8ff4af
# ╠═8aae5082-6519-45ff-aad0-8c989a084e4b
# ╟─bbd757d0-3d27-4859-a212-ed969f0e9ccb
# ╟─b8f11133-5899-44ce-bb7f-a8a6287f0149
# ╟─322d461f-bc9b-4e0b-a676-33203fa2ce79
