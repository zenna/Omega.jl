### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 38d37e89-dce4-4d4c-a7b7-06739e64f02d
begin
    import Pkg
    Pkg.activate(Base.current_project())
    using Omega, Distributions, OmegaExamples, UnicodePlots
end

# ╔═╡ ca43a069-c726-4b3e-acf8-d99e64462646
md"""
# 2. Generators, Orbits, and Quotients

Chapter 1 compressed an ordered sequence of coin flips into `(flips, heads)`. The compression worked for inferring which coin produced the data, but the chapter did not explain where that representation came from.

This chapter constructs the representation from transformations. We will specify a small operation that changes a sequence, compose that operation to find all connected sequences, check which tasks stay constant across those sequences, and replace each set of task-equivalent sequences with one quotient coordinate.

The example uses the same fair-versus-trick-coin task throughout.
"""

# ╔═╡ eefb02dc-8061-4f7a-9e06-5e6ef2245daa
md"""
## A local generator: swap two neighbours

Let ``\tau_i`` exchange flips at positions ``i`` and ``i+1``. This adjacent swap is a **generator**: a simple transformation whose compositions produce more complicated transformations.

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
Each swap is an **involution** because applying it twice returns the original sequence: ``\tau_i^2=e``, where ``e`` is the identity transformation. Composition also matters: swapping positions 2 and 3, then positions 3 and 4, can differ from reversing that order.

For sequences of length ``n``, the adjacent swaps generate the **symmetric group** ``S_n``, the group of all permutations of ``n`` positions. Composing two permutations produces another permutation, composition is associative, an identity leaves the sequence unchanged, and every permutation has an inverse. These group properties let us move around a structured family of sequences without changing their values, only their positions.
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

# ╔═╡ 29691ca0-bf06-4b9a-823c-5797755e8f2b
md"""
## The orbit: every reachable observation

A group acts on a space when each group element transforms an object in that space. Here, ``S_4`` acts on four-flip sequences by permuting their positions. The **orbit** of `HHHT` is the set of sequences reachable under that action:

```math
\operatorname{Orb}(x)=\{g\cdot x:g\in S_4\}.
```

The orbit contains four sequences instead of ``4!=24`` because exchanging two identical heads does not produce a new sequence. More generally, a sequence with ``k`` heads has ``\binom{n}{k}`` distinct orbit members. The orbit reveals which raw distinctions arise only from order.
"""

# ╔═╡ c4bc0456-a9ee-4fbe-b019-207489a8df9e
begin
    is_fair_prior = 0.5
    fair_weight = 0.5
    trick_weight = 0.85
    is_fair_coin = @~ Bernoulli(is_fair_prior)

    count_representation(sequence) = (
        flips = length(sequence),
        heads = count(identity, sequence),
    )
end

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

# ╔═╡ 23171ad6-ce90-444a-b4cd-301625072c90
md"""
## Task Invariants

A task ``T`` is **invariant** under a transformation ``g`` when

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

Define ``x\sim y`` when a permutation carries ``x`` to ``y``. This relation is an **equivalence relation**: every sequence is equivalent to itself, equivalence works in both directions, and equivalences compose. Its equivalence classes are the permutation orbits.

The **quotient space** ``X/S_n`` replaces every orbit in the original sequence space ``X`` with one object. For Boolean sequences of fixed length, the number of heads uniquely labels each quotient class. The map

```math
q(x)=(\operatorname{length}(x),\operatorname{heads}(x))
```

is a concrete quotient map. Chapter 1's count representation is a coordinate system for the permutation quotient.
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
For all boolean sequences of the same length as the seed sequence, filter based on whether the count representation of that boolean sequence matches that of the seed representation (i.e., we get the class of elements whose number of heads matches the seed sequence):
"""

# ╔═╡ 81d2cb4d-1a0f-4830-9027-b1c8dcbd98c4
count_class = filter(sequence -> (count_representation(sequence) == count_representation(seed_sequence)),
	all_boolean_sequences(length(seed_sequence)))

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
sort([
    (heads = coordinate.heads, class_size = length(class))
    for (coordinate, class) in four_flip_quotient
], by = row -> row.heads)

# ╔═╡ 5f018a7d-142e-4f3e-9d61-953f94f3a63e
md"""
The quotient reduces the 16 ordered four-flip sequences to five coordinates, one for each possible head count. In general, it reduces ``2^n`` Boolean sequences to ``n+1`` count coordinates. Their class sizes for four flips are `1, 4, 6, 4, 1`, the corresponding binomial coefficients.

If a task is invariant on every class, it **factors through** the quotient:

```math
T = D\circ q.
```

Here, ``q`` is `count_representation`, and ``D`` computes the posterior from a head count. The factorisation makes the task easier because the solver no longer needs separate rules for `HHHT`, `HHTH`, `HTHH`, and `THHH`. It evaluates one decoder at their shared coordinate `(flips = 4, heads = 3)`. Across all length-``n`` observations, the decoder handles ``n+1`` inputs instead of ``2^n`` ordered inputs.

This reduction concerns the information and computation required by the task. It does not, by itself, prove that every Omega inference algorithm will run faster; that claim would require a runtime comparison of concrete inference implementations.
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

This is exactly the probability mass function of ``\operatorname{Binomial}(n,\theta)``. In other words, pushing the ordered Bernoulli-sequence model through the quotient map produces a binomial count model. We can therefore generate and condition on the quotient coordinate directly instead of constructing an ordered sequence and then counting it.
"""

# ╔═╡ 0484323e-84f4-4864-aefa-fb5748382393
binomial_head_count(n, weight) = @~ Binomial(n, weight)

# ╔═╡ bb5647c5-c794-4295-a8d7-e24a72d0bdd0
observed_quotient_coordinate = count_representation(seed_sequence)

# ╔═╡ 9da2e32a-5bd5-4725-9e56-a9e184c21966
quotient_head_count = Variable(ω ->
    binomial_head_count(
        observed_quotient_coordinate.flips,
        is_fair_coin(ω) ? fair_weight : trick_weight,
    )(ω)
)

# ╔═╡ 0f08478d-a70f-4037-bdaa-6c2ac220026d
fair_coin_posterior = is_fair_coin |ᶜ
    (quotient_head_count .== observed_quotient_coordinate.heads)

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
The posterior above now conditions `is_fair_coin` on a count drawn directly from `Binomial`. No ordered flip vector appears in this inference path. The sampled estimate approaches the exact value from `count_decoder`; their small difference comes from finite Monte Carlo sampling.
"""

# ╔═╡ 99113292-4f6b-4587-a16b-883e87335561
random_orbit_member = @~ UniformDraw(orbit)

# ╔═╡ ecd47b5e-e5e6-4d47-8f37-7458127c9057
random_observation = random_orbit_member

# ╔═╡ 155d65f4-9d27-4c3d-95c9-0b722fefe11f
random_longest_run = longest_head_run ∘ random_observation

# ╔═╡ 9e3a7f46-0c42-4459-b4aa-c7e1f8eac705
viz(show_sequence.(randsample(random_orbit_member, 1200)))

# ╔═╡ 110f2caf-213f-4b44-864e-71fdb2f90afd
viz(randsample(random_longest_run, 1200))

# ╔═╡ 27c2eaee-bf98-4fba-af39-9dd467e47639
md"""
## Why put the orbit in Omega?

`random_orbit_member` places a probability distribution over raw observations that differ only by a lawful transformation. The first Unicode plot confirms that all four orderings occur. The longest-run plot varies because that task does not factor through the count quotient.

For coin inference, `quotient_head_count` instead models the smaller count state directly. The raw orbit remains here only to visualise the distinctions that the quotient removes and to contrast them with a task for which those distinctions matter.

## Limitations

We supplied the generators, identified the quotient, and replaced the sequence model with its binomial pushforward. Omega does not discover the permutation group, quotient, or binomial model automatically. A serially dependent coin model could make order relevant even for coin inference, in which case the count quotient would no longer preserve the posterior and the binomial replacement would be invalid.
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
# ╟─29691ca0-bf06-4b9a-823c-5797755e8f2b
# ╠═c4bc0456-a9ee-4fbe-b019-207489a8df9e
# ╠═7a368cd2-2d06-42a5-a2d7-d0833bad92d4
# ╠═d68473f3-6e1e-4356-bd66-2d10134494a4
# ╠═ea71f949-27d2-43df-a982-d5823240f2b5
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
# ╠═99113292-4f6b-4587-a16b-883e87335561
# ╠═ecd47b5e-e5e6-4d47-8f37-7458127c9057
# ╠═155d65f4-9d27-4c3d-95c9-0b722fefe11f
# ╠═9e3a7f46-0c42-4459-b4aa-c7e1f8eac705
# ╠═110f2caf-213f-4b44-864e-71fdb2f90afd
# ╟─27c2eaee-bf98-4fba-af39-9dd467e47639
