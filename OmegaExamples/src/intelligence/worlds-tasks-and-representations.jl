### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ a1a8a3ea-2261-4c42-b08a-724c6ab4dd91
begin
    import Pkg
    Pkg.activate(Base.current_project())
    using Omega, Distributions, OmegaExamples, UnicodePlots
end

# ╔═╡ 82477a57-922f-4532-811f-728c5cce86f9
md"""
# 1. Worlds, Tasks, and Representations

Chapter 1 of ProbMods, [Generative Models](https://pluto.land/n/zlwvqg1g), begins with the idea of a working model: a model captures some useful structure in the world, and we can run it to imagine what might happen. A probabilistic program makes this idea concrete by describing a process that generates possible states of the world.

Once we have such a model, we can ask it many questions. This chapter asks a question that comes before solving any one of them: **which representation makes the required computation easy?** A representation that works well for one task may discard exactly what another task needs.

This chapter separates three ingredients:

1. a probabilistic model of possible worlds;
2. a task that outputs the required answer to some query;
3. a representation that retains information for computing that answer.
"""

# ╔═╡ 25051bc1-d5b0-47ec-8c11-2895cc9d2d5e
md"""
## What is Omega?

``(\Omega, \Sigma_\Omega)`` is an abstract measurable space of possible states, and we write a task as

```math
\mathsf{Task}: \Omega \longrightarrow Y.
```

In Omega.jl, a random variable is a computation that takes a runtime world `ω::Ω` and returns a value. Sampling runs that computation in a possible world. Conditioning asks which worlds remain possible after an observation. Omega's runtime object gives us this computational interpretation; it does not implement the full measurable space or its sigma-algebra.
"""

# ╔═╡ 4f16c855-b116-40e0-8010-16284fbb23cb
md"""
## Example: Learning which coin produced a sequence

Suppose a friend gives you a coin. It may be fair, or it may be a trick coin that lands heads 85% of the time. The program below first chooses which kind of coin your friend gave you and then generates a sequence of flips. After seeing the flips, we run the model in the other direction and ask which coin probably produced them.

The inference follows the coin example in ProbMods' [Learning as conditional inference](https://pluto.land/n/1nr1tmd6). It also gives representation a concrete role: must the learner retain the order of every flip, or is the number of heads enough?
"""

# ╔═╡ 1ae181a6-bcb0-437e-b928-4c44eebeb5fa
begin
    is_fair_prior = 0.5
    fair_weight = 0.5
    trick_weight = 0.85
    is_fair_coin = @~ Bernoulli(is_fair_prior)
end

# ╔═╡ d33b3a6e-b1cb-44f4-88ea-cf25403491a5
coin_flip(i, ω) =
    (i ~ Bernoulli(is_fair_coin(ω) ? fair_weight : trick_weight))(ω)

# ╔═╡ a964b7ce-34e1-4074-be93-92573b7cf18a
flip_sequence(n) = Variable(ω -> [coin_flip(i, ω) for i in 1:n])

# ╔═╡ 31d29043-6305-481b-989d-399a37138d5d
show_sequence(sequence) = join(ifelse.(sequence, "H", "T"))

# ╔═╡ 85c74d6b-8ccd-4d14-9719-7c6a063e8868
prior_sequences = randsample(flip_sequence(4), 500)

# ╔═╡ 02b8b6c6-72ea-4db1-b845-b4e8671b52ac
viz(show_sequence.(prior_sequences))

# ╔═╡ 85320e5c-fbef-4621-a529-b369903552f7
md"""
Each sampled world contains a single value of `fair_coin` shared by all four flips. Conditional on that latent mechanism, the flips are independent and identically distributed. The ordered sequence is the learner's raw observation.
"""

# ╔═╡ bba5bdf2-660c-47dc-8b15-1bcc21fd58dc
begin
    sequence_a = [true, true, true, false]  # HHHT
    sequence_b = [true, false, true, true]  # HTHH
end

# ╔═╡ bd3756f2-17f0-4586-850a-eef5b71a200a
md"""
## What the representation looks like

The full representation keeps the ordered `Vector{Bool}`. A smaller representation keeps only the sequence length and number of heads:

{HHHT, HHTH, HTHH} ──▶ (flips = 4, heads = 3)

For a fixed sequence length, the head count alone identifies the coordinate. Including `flips` lets the same representation handle sequences of different lengths.
"""

# ╔═╡ fa2b23cb-08fc-424e-b1f3-08cfcff13420
begin
    full_representation(sequence) = sequence
    count_representation(sequence) = (
        flips = length(sequence),
        heads = count(identity, sequence),
    )
end

# ╔═╡ 1d6f3460-af29-4250-b54e-e7cbd10adc2c
[
    (sequence = show_sequence(sequence),
	 alt_representation = count_representation(sequence))
    for sequence in [sequence_a, sequence_b]
]

# ╔═╡ 9965eccd-ce7e-494e-8174-041a8b96904a
md"""
The count representation treats many ordered observations as the same. A sequence of length ``n`` has ``2^n`` possible Boolean strings but only ``n+1`` possible head counts. For the present task, the smaller space keeps the distinction we need and removes distinctions that the model treats as irrelevant.
"""

# ╔═╡ 1c45aaca-d1e2-4e3e-be46-63bd9289dfb5
function is_fair_posterior(sequence)
	sequence_likelihood(sequence, weight) = 
		prod((s ? weight : 1 - weight) for s in sequence)
    fair_likelihood = sequence_likelihood(sequence, fair_weight)
    trick_likelihood = sequence_likelihood(sequence, trick_weight)
    fair_mass = is_fair_prior * fair_likelihood
    trick_mass = (1 - is_fair_prior) * trick_likelihood
    fair_mass / (fair_mass + trick_mass)
end

# ╔═╡ b1939595-e275-482a-b69d-241ea1783ebd
function count_decoder(representation)
    n = representation.flips
    k = representation.heads
    fair_likelihood = fair_weight^k * (1 - fair_weight)^(n - k)
    trick_likelihood = trick_weight^k * (1 - trick_weight)^(n - k)
    fair_mass = is_fair_prior * fair_likelihood
    trick_mass = (1 - is_fair_prior) * trick_likelihood
    fair_mass / (fair_mass + trick_mass)
end

# ╔═╡ f37a69aa-5aa4-4024-b999-453e6f79da4d
[
    (
        sequence = show_sequence(sequence),
        task_from_full_sequence = is_fair_posterior(sequence),
        task_from_count = count_decoder(count_representation(sequence)),
    )
    for sequence in [sequence_a, sequence_b]
]

# ╔═╡ d9145ff1-52d8-4b62-b5f3-cf5e43599e6a
md"""
The task computes the posterior probability that the coin is fair. Under this conditionally i.i.d. model, the likelihood has the form

```math
P(s\mid\theta)=\theta^k(1-\theta)^{n-k}.
```

The likelihood depends on ``n`` and ``k``, not on flip order. The decoder therefore recovers the exact task result from the count representation:

```math
\mathsf{is\_fair\_posterior}
=
\mathsf{count\_decoder}\circ\mathsf{count\_representation}.
```

The head count is a sufficient statistic for this inference task under the assumed coin model.
"""

# ╔═╡ 9ff3cc91-ff52-42d4-b5fe-cdb89ad4dc92
md"""
## Why the count can make inference cheaper

The two representations support different computations. Starting from an ordered sequence, `is_fair_posterior` multiplies one likelihood term for every flip, so it grows linearly with ``n``. Starting from an already computed pair ``(n,k)``, `count_decoder` performs a fixed number of arithmetic operations and never traverses the observations. With fixed-precision arithmetic, its running time is therefore constant with respect to the sequence length.

Computing ``k`` from a new sequence still requires one pass over the data. The first complete calculation is therefore ``O(n)`` in either representation. The saving appears when the learner stores the count, reuses it for later queries, or receives count data directly: the ordered representation occupies ``O(n)`` space and each new likelihood calculation scans ``n`` values, while the count representation occupies ``O(1)`` space and its decoder does not revisit the sequence.

The count also changes rejection sampling. Given a coin weight ``\theta``, one particular ordered sequence with ``k`` heads has probability

```math
\theta^k(1-\theta)^{n-k},
```

whereas the event "exactly ``k`` heads" has probability

```math
{n \choose k}\theta^k(1-\theta)^{n-k}.
```

The count-conditioned query therefore accepts ``{n \choose k}`` times as many proposed worlds as a query conditioned on one particular ordering. For ``n=20`` and ``k=10``, that factor is ``{20 \choose 10}=184{,}756``. The current Omega count query still generates all ``n`` flips in each proposed world, so the representation improves its acceptance rate but not the cost of generating one proposal. A generative model that represents the head count directly with a binomial random variable can also avoid constructing the ordered sequence when no task needs it.
"""

# ╔═╡ c0e04a0c-31b2-4bef-adb9-76ddf62cc80d
sequence_condition(observed) =
    Variable(ω -> flip_sequence(length(observed))(ω) == observed)

# ╔═╡ 439377a4-9cb9-4c7a-aaf0-7cce2642bb5a
omega_fair_posterior(observed::Vector) =
    is_fair_coin |ᶜ sequence_condition(observed)

# ╔═╡ 45536470-c40d-43a8-8e43-02e5d3afbb47
head_count_variable(n) = Variable(
    ω -> count(identity, flip_sequence(n)(ω))
)

# ╔═╡ 762e18ac-ef81-4b68-aa05-205821498823
omega_fair_posterior(representation::NamedTuple) = 
	is_fair_coin |ᶜ (ω -> head_count_variable(representation.flips)(ω) == representation.heads)

# ╔═╡ 16d99340-a821-4620-97e2-b1601786fefa
posterior_a_samples = randsample(
    omega_fair_posterior(sequence_a),
    5000,
    alg = RejectionSample,
)

# ╔═╡ 2b65c790-4206-484c-915f-294b4c0bc0c3
viz(posterior_a_samples)

# ╔═╡ e77105d0-fbb6-40dc-8aa1-c0d74b5d49c5
posterior_b_samples = randsample(
    omega_fair_posterior(sequence_b),
    5000,
    alg = RejectionSample,
)

# ╔═╡ 8ad5075d-ce34-4a55-b9d1-b3b3e26fa111
viz(posterior_b_samples)

# ╔═╡ d7c86f21-06d2-4ccc-a199-2cf684a7e53d
posterior_count_samples_seq_a = randsample(
    omega_fair_posterior(count_representation(sequence_a)),
    5000,
    alg = RejectionSample,
)

# ╔═╡ 67c19116-a222-4ea6-b6e6-417edc14c9e1
viz(posterior_count_samples_seq_a)

# ╔═╡ 65d8f4af-f9a2-4232-9404-1a13c649fbc5
fair_probability(samples) = sum(samples) / length(samples)

# ╔═╡ 596c5d74-b022-4999-8eaf-56db20cc6926
(
    sequence_a = fair_probability(posterior_a_samples),
    sequence_b = fair_probability(posterior_b_samples),
    count_representation = fair_probability(posterior_count_samples_seq_a),
    exact = is_fair_posterior(sequence_a),
)

# ╔═╡ 2d36f2e8-e119-4d4f-8e92-7e53b70631db
md"""
We can now ask the same question in three ways: condition on either ordered observation, or condition on their shared count. The Monte Carlo estimates vary slightly because they use finite samples. The exact calculation above shows that all three queries define the same posterior.

The representation matters because it exposes the symmetry of the model. Permuting the flips changes the raw sequence but leaves the inference coordinate unchanged.
"""

# ╔═╡ 56adaf9b-c9ce-4383-8820-a49c73123b2a
md"""
## Change the task, change the representation

Now suppose the task asks for the longest uninterrupted run of heads. Order becomes relevant, so the count representation no longer retains enough information.
"""

# ╔═╡ 40361dd3-739f-4d2a-95f5-1451837b4d21
function longest_head_run(sequence)
    longest = 0
    current = 0
    for flip in sequence
        current = flip ? current + 1 : 0
        longest = max(longest, current)
    end
    longest
end

# ╔═╡ bc767067-65cf-4d83-8398-5ab8f19f5411
[
    (
        sequence = show_sequence(sequence),
        count_representation = count_representation(sequence),
        longest_head_run = longest_head_run(sequence),
    )
    for sequence in [sequence_a, sequence_b]
]

# ╔═╡ dce4c493-f693-45d7-998b-50b243c9ebde
md"""
`HHHT` and `HTHH` occupy the same count coordinate, but their longest runs are three and two. No decoder can recover both answers from `(flips = 4, heads = 3)`. The count representation is sufficient for inferring the latent coin mechanism and insufficient for detecting sequential structure.

## Significance and limitations

A representation determines which distinctions a solver can express cheaply. The count coordinate groups sequences that differ only in their order and turns an exponential observation space into a linear one. For this task, it also gives a decoder whose work does not grow with the number of flips once the count has been computed. These savings follow from the task and the conditional independence assumptions of the generative model.

We supplied the count representation. Omega performs inference within the model but does not discover this statistic automatically. If the flips were serially dependent, or if the task concerned order, the same representation would discard relevant structure. Chapter 3 considers uncertainty over a supplied library of candidate representations.
"""

# ╔═╡ Cell order:
# ╠═a1a8a3ea-2261-4c42-b08a-724c6ab4dd91
# ╟─82477a57-922f-4532-811f-728c5cce86f9
# ╟─25051bc1-d5b0-47ec-8c11-2895cc9d2d5e
# ╟─4f16c855-b116-40e0-8010-16284fbb23cb
# ╠═1ae181a6-bcb0-437e-b928-4c44eebeb5fa
# ╠═d33b3a6e-b1cb-44f4-88ea-cf25403491a5
# ╠═a964b7ce-34e1-4074-be93-92573b7cf18a
# ╠═31d29043-6305-481b-989d-399a37138d5d
# ╠═85c74d6b-8ccd-4d14-9719-7c6a063e8868
# ╠═02b8b6c6-72ea-4db1-b845-b4e8671b52ac
# ╟─85320e5c-fbef-4621-a529-b369903552f7
# ╠═bba5bdf2-660c-47dc-8b15-1bcc21fd58dc
# ╟─bd3756f2-17f0-4586-850a-eef5b71a200a
# ╠═fa2b23cb-08fc-424e-b1f3-08cfcff13420
# ╠═1d6f3460-af29-4250-b54e-e7cbd10adc2c
# ╟─9965eccd-ce7e-494e-8174-041a8b96904a
# ╠═1c45aaca-d1e2-4e3e-be46-63bd9289dfb5
# ╠═b1939595-e275-482a-b69d-241ea1783ebd
# ╠═f37a69aa-5aa4-4024-b999-453e6f79da4d
# ╟─d9145ff1-52d8-4b62-b5f3-cf5e43599e6a
# ╟─9ff3cc91-ff52-42d4-b5fe-cdb89ad4dc92
# ╠═c0e04a0c-31b2-4bef-adb9-76ddf62cc80d
# ╠═439377a4-9cb9-4c7a-aaf0-7cce2642bb5a
# ╠═45536470-c40d-43a8-8e43-02e5d3afbb47
# ╠═762e18ac-ef81-4b68-aa05-205821498823
# ╠═16d99340-a821-4620-97e2-b1601786fefa
# ╠═2b65c790-4206-484c-915f-294b4c0bc0c3
# ╠═e77105d0-fbb6-40dc-8aa1-c0d74b5d49c5
# ╠═8ad5075d-ce34-4a55-b9d1-b3b3e26fa111
# ╠═d7c86f21-06d2-4ccc-a199-2cf684a7e53d
# ╠═67c19116-a222-4ea6-b6e6-417edc14c9e1
# ╠═65d8f4af-f9a2-4232-9404-1a13c649fbc5
# ╠═596c5d74-b022-4999-8eaf-56db20cc6926
# ╟─2d36f2e8-e119-4d4f-8e92-7e53b70631db
# ╟─56adaf9b-c9ce-4383-8820-a49c73123b2a
# ╠═40361dd3-739f-4d2a-95f5-1451837b4d21
# ╠═bc767067-65cf-4d83-8398-5ab8f19f5411
# ╟─dce4c493-f693-45d7-998b-50b243c9ebde
