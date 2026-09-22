### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ a1a8a3ea-2261-4c42-b08a-724c6ab4dd91
begin
    import Pkg
	# Pkg.activate(mktempdir())
 #    repo = "https://github.com/zenna/Omega.jl"
 #    rev = "complete-probmods"
	# Pkg.add([
 #        Pkg.PackageSpec(url=repo, rev=rev),
 #        Pkg.PackageSpec(url=repo, rev=rev, subdir="OmegaCore"),
 #        Pkg.PackageSpec(url=repo, rev=rev, subdir="InferenceBase"),
 #        Pkg.PackageSpec(url=repo, rev=rev, subdir="SoftPredicates"),
 #        Pkg.PackageSpec(url=repo, rev=rev, subdir="connectors/OmegaDistributions"),
 #        Pkg.PackageSpec(url=repo, rev=rev, subdir="connectors/OmegaSoftPredicates"),
 #        Pkg.PackageSpec(url=repo, rev=rev, subdir="OmegaMH"),
 #        Pkg.PackageSpec(url=repo, rev=rev, subdir="ReplicaExchange"),
 #        Pkg.PackageSpec(url=repo, rev=rev, subdir="OmegaExamples"),
 #    ])
	Pkg.activate(Base.current_project())
    using Omega, Distributions, OmegaExamples, UnicodePlots
end

# ╔═╡ 82477a57-922f-4532-811f-728c5cce86f9
md"""

This notebook series is a tutorial for the paper:
[Yu (2026), *The Art of Making Problems Simple: A Theory of Intelligence*](https://doi.org/10.31234/osf.io/pghzn). We expand on examples in [Probmods](http://probmods.org/) to detail the ideas in the paper. 

# 1. Worlds, Tasks, and Representations

Chapter 1 of ProbMods, [Generative Models](https://pluto.land/n/zlwvqg1g), begins with the idea of a working model: a model captures some useful structure in the world, and we can run it to imagine what might happen. A probabilistic program makes this idea concrete by describing a process that generates possible states of the world.

Once we have such a model, we can ask it many questions. We treat a **question**
as a function

```math
Q:\Omega\longrightarrow Y.
```

The input is a possible world ``\omega\in\Omega``. The output ``Q(\omega)\in Y``
is the answer in that world. For example, a yes-or-no question has
``Y=\{\mathsf{false},\mathsf{true}\}``, while a question about distance may return
a real number. The _task_ is to compute ``Q(\omega)``.

A **representation** is a function

```math
R:\Omega\longrightarrow Z
```

that describes a world in another space ``Z``. Think of a subway map. The city
is the world, and the map represents it using stations and connections. The map
supports questions such as "Can I travel from one station to another?" while
discarding details such as building colours. Those details would matter for a
different question, such as "What colour is the building above this station?"

A representation supports a question when a decoder ``D:Z\to Y`` can recover
the answer from it:

```math
Q = D\circ R.
```

This chapter asks: **which representation makes the required computation easy?**

This chapter separates three ingredients:

1. a probabilistic model of possible worlds;
2. a question, and the task of computing its answer;
3. a representation that retains information for computing that answer.
"""

# ╔═╡ 25051bc1-d5b0-47ec-8c11-2895cc9d2d5e
md"""
## Prerequisite: Omega

Omega is a probabilistic programming language. A random variable is a computation
that takes a possible world `ω` and returns a value. The cell below, `defω()`, constructs a runtime world, and `x(ω)` evaluates the Boolean random variable `x` in it, described by a Bernoulli distribution.

Run the cells below, then evaluate `x(ω)` again. It returns the same value in the
same world. Try `x(defω())` or re-running the `ω = defω()` cell to evaluate it in a fresh world.
"""

# ╔═╡ 03340860-8c42-4db2-bd9d-2bc73b2e8775
ω = defω()

# ╔═╡ 593d7b86-fbd8-463a-9b94-228f7eb835f2
x = @~ Bernoulli()

# ╔═╡ 72a2097d-f583-434e-b18e-b72c9f745111
x(ω)

# ╔═╡ 4f16c855-b116-40e0-8010-16284fbb23cb
md"""
## Example: Learning which coin produced a sequence

Suppose a friend gives you a coin. It may be fair, or it may be a trick coin that lands heads 85% of the time. The program below first chooses which kind of coin your friend gave you and then generates a sequence of flips. After seeing the flips, we can ask which coin probably produced them.

The inference follows the coin example in ProbMods' [Learning as conditional inference](https://pluto.land/n/1nr1tmd6).
"""

# ╔═╡ 1ae181a6-bcb0-437e-b928-4c44eebeb5fa
is_fair_prior = 0.5

# ╔═╡ 3a78b124-1642-4c58-b21a-de971172448d
fair_weight = 0.5

# ╔═╡ 339969d1-2573-4977-b36a-a23372c65c89
trick_weight = 0.85

# ╔═╡ 5d330ca3-84bb-471a-99ce-6854fc0ff289
is_fair_coin = @~ Bernoulli(is_fair_prior)

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
Each sampled world contains a single value of `is_fair_coin` shared by all four flips. Conditional on that latent mechanism, the flips are independent and identically distributed. The plot shows the frequencies of the four-flip strings. At the starting
settings, `HHHH` is common because the trick coin strongly favours heads.

Try changing `trick_weight` from 0.85 to 0.5. The two coin types then generate
the same distribution. Changing `is_fair_prior` will no longer change the
predicted distribution of flips. Keep both weights between 0 and 1.
"""

# ╔═╡ bba5bdf2-660c-47dc-8b15-1bcc21fd58dc
sequence_a = [true, true, true, false]  # HHHT

# ╔═╡ d3b38ca7-669f-4493-bcbf-0dbd30cda91c
sequence_b = [true, false, true, true]  # HTHH

# ╔═╡ bd3756f2-17f0-4586-850a-eef5b71a200a
md"""
## What different representations look like

The full representation keeps the ordered `Vector{Bool}`. A smaller representation keeps only the sequence length and number of heads:

{HHHT, HHTH, HTHH} ──▶ (flips = 4, heads = 3)

For a fixed sequence length, the head count alone identifies the coordinate. Including `flips` lets the same representation handle sequences of different lengths.
"""

# ╔═╡ fa2b23cb-08fc-424e-b1f3-08cfcff13420
full_representation(sequence) = sequence

# ╔═╡ f69e60b7-a50f-4f76-b7c6-8c8dfdb64d1a
count_representation(sequence) = (
    flips = length(sequence),
    heads = count(identity, sequence),
)

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

# ╔═╡ 9f38845c-d921-431f-8653-23a5026496ca
md"""
For `HHHT` and `HTHH`, both columns should give about 0.404. `is_fair_posterior`
multiplies the likelihood terms along the sequence. `count_decoder` groups those
terms into powers using the head count. Both apply Bayes' rule: divide the fair
coin's prior-weighted likelihood by the total for the two coin types.

Change the prior or either coin weight and compare the columns again. The values
change together because both computations use the same model.
"""

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

The two representations support different computations. Starting from an ordered sequence, `is_fair_posterior` multiplies one likelihood term for every flip, so it grows linearly with ``n``. Starting from an already computed pair ``(n,k)``, `count_decoder` evaluates two likelihoods using powers and never traverses the observations. The cost of those powers depends on the arithmetic implementation, but the decoder avoids multiplying a separate likelihood term for every flip.

Computing ``k`` from a new sequence still requires one pass over the data. The first complete calculation is therefore ``O(n)`` in either representation. The saving appears when the learner stores the count, reuses it for later queries, or receives count data directly: the ordered representation occupies ``O(n)`` space and each new likelihood calculation scans ``n`` values, while the count representation occupies ``O(1)`` space and its decoder does not revisit the sequence.

The count also changes rejection sampling. Given a coin weight ``\theta``, one particular ordered sequence with ``k`` heads has probability

```math
\theta^k(1-\theta)^{n-k},
```

whereas the event "exactly ``k`` heads" has probability

```math
{n \choose k}\theta^k(1-\theta)^{n-k}.
```

The count-conditioned query therefore accepts ``{n \choose k}`` times as many proposed worlds as a query conditioned on one particular ordering. The current implementation of the count query still generates all ``n`` flips in each proposed world, so the representation improves its acceptance rate but not the cost of generating one proposal. A generative model that represents the head count directly with a binomial random variable can also avoid constructing the ordered sequence when no task needs it.
"""

# ╔═╡ ae66ee93-fc10-4cf3-a0fa-e0b90b54c880
md"""
`sequence_condition` asks whether a generated sequence matches the observation.
`coin_given_sequence` uses `|ᶜ` to condition the coin type on that event.
`coin_given_count` takes a count representation and matches only the number of heads.
The three sampling cells below therefore ask the same coin question using
different representations of the data.

**Rejection sampling** repeatedly draws a proposed world from the prior model:
it chooses a coin type and generates flips from that coin. It keeps the coin
type if the flips satisfy the observation condition and discards the proposal
otherwise. The retained coin types are samples from the posterior. Averaging
their Boolean values estimates the posterior probability that the coin is fair.
"""

# ╔═╡ c0e04a0c-31b2-4bef-adb9-76ddf62cc80d
sequence_condition(observed) =
    Variable(ω -> flip_sequence(length(observed))(ω) == observed)

# ╔═╡ 439377a4-9cb9-4c7a-aaf0-7cce2642bb5a
coin_given_sequence(observed::Vector) =
    is_fair_coin |ᶜ sequence_condition(observed)

# ╔═╡ 45536470-c40d-43a8-8e43-02e5d3afbb47
head_count_variable(n) = Variable(
    ω -> count(identity, flip_sequence(n)(ω))
)

# ╔═╡ 762e18ac-ef81-4b68-aa05-205821498823
coin_given_count(representation::NamedTuple) =
	is_fair_coin |ᶜ (ω -> head_count_variable(representation.flips)(ω) == representation.heads)

# ╔═╡ 16d99340-a821-4620-97e2-b1601786fefa
posterior_a_samples = randsample(
    coin_given_sequence(sequence_a),
    400,
    alg = RejectionSample,
)

# ╔═╡ 2b65c790-4206-484c-915f-294b4c0bc0c3
viz(posterior_a_samples)

# ╔═╡ e77105d0-fbb6-40dc-8aa1-c0d74b5d49c5
posterior_b_samples = randsample(
    coin_given_sequence(sequence_b),
    400,
    alg = RejectionSample,
)

# ╔═╡ 8ad5075d-ce34-4a55-b9d1-b3b3e26fa111
viz(posterior_b_samples)

# ╔═╡ d7c86f21-06d2-4ccc-a199-2cf684a7e53d
posterior_count_samples_seq_a = randsample(
    coin_given_count(count_representation(sequence_a)),
    400,
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

# ╔═╡ 6715689b-08da-4c7e-a82a-90710bff450c
md"""
The displayed probabilities should cluster around 0.404 at the starting
settings. They will not match exactly because each comes from 400 samples.
Increase that number to reduce sampling variation, or edit the observed
sequences and predict how the posterior will move before rerunning the cells.

"""

# ╔═╡ 2d36f2e8-e119-4d4f-8e92-7e53b70631db
md"""
The representation here matters because it exposes the symmetry of the model. Permuting the flips changes the raw sequence but leaves the inference coordinate unchanged.
"""

# ╔═╡ 702915e6-180c-4bfb-8ebc-5c8536443026
md"""
## Compare the number of proposed worlds

The earlier calls each requested 400 **accepted posterior samples**. They did
not fix how many worlds the sampler had to propose before finding those matches.
To see the difference, we will generate a fixed collection of proposed worlds
and apply both acceptance rules to that same collection. This makes the proposal
and rejection steps explicit: each rule keeps matching worlds and discards the
rest. Unlike the earlier calls, which stop after 400 acceptances, this experiment
stops after a fixed number of proposals and counts how many each rule accepts.

Each proposal below contains a coin type and the sequence it generated. Both
use the same `ω`, so the recorded coin type is the one that generated the flips.
`proposal_count` controls how much work we allow before inspecting the estimates.
"""

# ╔═╡ 77d33bb3-4b28-45b3-a5a4-c5dc2a2d28d5
proposal_count = 2000

# ╔═╡ fabd4375-afca-4042-9ef4-715a817ff6b3
coin_and_flips(ω::Ω) = (
	fair=is_fair_coin(ω), 
	flips=flip_sequence(length(sequence_a))(ω),
)

# ╔═╡ f9d72d13-ea08-4e1e-819d-89450340dfd2
proposed_worlds = randsample(coin_and_flips, proposal_count)

# ╔═╡ 23c6de5e-a060-458a-8652-44ff54de7c01
sequence_matches = [world.flips == sequence_a for world in proposed_worlds]

# ╔═╡ 387ca99c-1da4-48a1-b762-56bd634210ed
count_matches = [count_representation(world.flips) == count_representation(sequence_a)
                 for world in proposed_worlds]

# ╔═╡ 003134d1-3a79-497f-98a9-c2ea3d3d205a
(proposed=proposal_count, accepted_sequence=count(sequence_matches),
 accepted_count=count(count_matches),
 expected_acceptance_ratio=binomial(length(sequence_a), count(identity, sequence_a)))

# ╔═╡ 06390fac-4053-4bae-ac90-12b8d644c9e3
md"""
For `HHHT`, the count rule should accept roughly four times as many proposals.
It accepts `HHHT`, `HHTH`, `HTHH`, and `THHH`, while the sequence rule accepts only
`HHHT`. Every sequence match is also a count match. Both conditions give the
same posterior because the four orderings have equal likelihood under each coin.

Try `[true, true, false, false]` for `sequence_a`: the expected ratio becomes six.
Try all heads: there is only one ordering, so the rules accept exactly the same
proposals. Keep the sequence short while exploring; rare matches need many proposals.

The next cell compares estimates after different prefixes of the proposal stream.
`estimate` averages the accepted coin types. A prefix with no accepted worlds
returns `missing`, so increasing the sequence length does not produce a misleading
zero estimate.
"""

# ╔═╡ 91b273f4-6996-4181-9ac5-770cf4503497
proposal_budgets = [100, 500, 1000, proposal_count]

# ╔═╡ 0e45638d-4d9e-4baf-939f-d4202ed1d612
function summarise_matches(proposals, matches)
    accepted = [world.fair for (world, keep) in zip(proposals, matches) if keep]
    n = length(accepted)
    p = is_fair_posterior(sequence_a)
    (accepted=n, estimate=n == 0 ? missing : mean(accepted),
     sampling_sd=n == 0 ? missing : sqrt(p * (1-p) / n))
end

# ╔═╡ 755fc40b-08a9-42bf-91b7-abe83a67db5d
[(proposed=n,
  sequence=summarise_matches(proposed_worlds[1:n], sequence_matches[1:n]),
  count=summarise_matches(proposed_worlds[1:n], count_matches[1:n]))
 for n in sort(unique(filter(n -> 0 < n <= proposal_count, proposal_budgets)))]

# ╔═╡ 43fdb83f-e487-4fb0-a138-680b92603ba4
md"""
As the proposal budget grows, both estimates approach the same fair-coin
probability, about 0.404 at the starting settings. The count query collects more
accepted samples from each prefix. Its estimate will usually fluctuate less,
although a particular run can still put the sequence estimate closer to the answer.

`sampling_sd` makes the accuracy comparison explicit. Accepted coin types are
independent Boolean draws with the same posterior probability ``p``. Conditional
on accepting ``m`` worlds, their average has standard deviation
``sqrt(p(1-p)/m)``. We use the exact posterior from the earlier decoder to display
that expected sampling variation. Four times as many accepted samples gives
about half the standard deviation. This comparison describes variation across runs;
individual estimates need not improve monotonically.

Rerun `proposed_worlds` and inspect the table again. Then raise `proposal_count`
or change the observed sequence. The advantage is fewer **proposals** for a
given accuracy. If you instead fix the number of accepted samples, as in the
400-sample calls above, the two estimators have the same sampling variance.
This experiment compares proposal budgets; it does not measure elapsed time.
"""

# ╔═╡ dce4c493-f693-45d7-998b-50b243c9ebde
md"""
## Discussion

Change `sequence_b` while keeping its head count fixed. Which results stay the
same, and which change? The count is useful for the coin question because the
model makes flip order irrelevant once we know the coin type. A task about runs
asks for information that this representation discards.

Now imagine a coin whose probability of heads depends on the previous flip.
Would counting heads still preserve the posterior? What would you need to keep
instead?
"""

# ╔═╡ Cell order:
# ╠═a1a8a3ea-2261-4c42-b08a-724c6ab4dd91
# ╟─82477a57-922f-4532-811f-728c5cce86f9
# ╟─25051bc1-d5b0-47ec-8c11-2895cc9d2d5e
# ╠═03340860-8c42-4db2-bd9d-2bc73b2e8775
# ╠═593d7b86-fbd8-463a-9b94-228f7eb835f2
# ╠═72a2097d-f583-434e-b18e-b72c9f745111
# ╟─4f16c855-b116-40e0-8010-16284fbb23cb
# ╠═1ae181a6-bcb0-437e-b928-4c44eebeb5fa
# ╠═3a78b124-1642-4c58-b21a-de971172448d
# ╠═339969d1-2573-4977-b36a-a23372c65c89
# ╠═5d330ca3-84bb-471a-99ce-6854fc0ff289
# ╠═d33b3a6e-b1cb-44f4-88ea-cf25403491a5
# ╠═a964b7ce-34e1-4074-be93-92573b7cf18a
# ╠═31d29043-6305-481b-989d-399a37138d5d
# ╠═85c74d6b-8ccd-4d14-9719-7c6a063e8868
# ╠═02b8b6c6-72ea-4db1-b845-b4e8671b52ac
# ╟─85320e5c-fbef-4621-a529-b369903552f7
# ╠═bba5bdf2-660c-47dc-8b15-1bcc21fd58dc
# ╠═d3b38ca7-669f-4493-bcbf-0dbd30cda91c
# ╟─bd3756f2-17f0-4586-850a-eef5b71a200a
# ╠═fa2b23cb-08fc-424e-b1f3-08cfcff13420
# ╠═f69e60b7-a50f-4f76-b7c6-8c8dfdb64d1a
# ╠═1d6f3460-af29-4250-b54e-e7cbd10adc2c
# ╟─9965eccd-ce7e-494e-8174-041a8b96904a
# ╠═1c45aaca-d1e2-4e3e-be46-63bd9289dfb5
# ╠═b1939595-e275-482a-b69d-241ea1783ebd
# ╠═f37a69aa-5aa4-4024-b999-453e6f79da4d
# ╟─9f38845c-d921-431f-8653-23a5026496ca
# ╟─d9145ff1-52d8-4b62-b5f3-cf5e43599e6a
# ╟─9ff3cc91-ff52-42d4-b5fe-cdb89ad4dc92
# ╟─ae66ee93-fc10-4cf3-a0fa-e0b90b54c880
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
# ╟─6715689b-08da-4c7e-a82a-90710bff450c
# ╟─2d36f2e8-e119-4d4f-8e92-7e53b70631db
# ╟─702915e6-180c-4bfb-8ebc-5c8536443026
# ╠═77d33bb3-4b28-45b3-a5a4-c5dc2a2d28d5
# ╠═fabd4375-afca-4042-9ef4-715a817ff6b3
# ╠═f9d72d13-ea08-4e1e-819d-89450340dfd2
# ╠═23c6de5e-a060-458a-8652-44ff54de7c01
# ╠═387ca99c-1da4-48a1-b762-56bd634210ed
# ╠═003134d1-3a79-497f-98a9-c2ea3d3d205a
# ╟─06390fac-4053-4bae-ac90-12b8d644c9e3
# ╠═91b273f4-6996-4181-9ac5-770cf4503497
# ╠═0e45638d-4d9e-4baf-939f-d4202ed1d612
# ╠═755fc40b-08a9-42bf-91b7-abe83a67db5d
# ╟─43fdb83f-e487-4fb0-a138-680b92603ba4
# ╟─dce4c493-f693-45d7-998b-50b243c9ebde
