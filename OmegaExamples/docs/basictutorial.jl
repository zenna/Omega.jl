### A Pluto.jl notebook ###
# v0.18.0

using Markdown
using InteractiveUtils

# ╔═╡ b7772def-6186-44a2-b0d8-bbf55855948a
import Pkg

# ╔═╡ a194ae49-7def-4020-b047-995f15ad6516
Pkg.activate(Base.current_project())

# ╔═╡ 4e023a0d-8860-4d3e-ad20-7f6f2026efad
using Omega, Distributions, UnicodePlots

# ╔═╡ 1d48fee0-8bc6-11ec-3c86-3f1be0c6595c
md" # Basic Tutorial

In this tutorial we will run through the basics of creating a model and conditioning it.

First load Omega and Distributions:"

# ╔═╡ 6ef3eaa6-87e0-4206-b1b4-17e9fbc820a0
md"If you tossed a coin and observed the sequqnce `HHHHH`, you would be a little suspicious, `HHHHHHHH` would make you very suspicious.
Elementary probability theory tells us that for a fair coin, `HHHHHHHH` is just a likely outcome as `HHTTHHTH`.  What gives?
We will use Omega to model this behaviour, and see how that belief about a coin changes after observing a number of tosses.

Model the coin as a bernoulli distribution.  The weight of a bernoulli determines the probability it comes up true (which represents heads). Use a [beta distribution](https://en.wikipedia.org/wiki/Beta_distribution) to represent our prior belief weight of the coin."

# ╔═╡ eb7d27e9-2784-48be-b96c-4810edbfd07c
weight = @~ Beta(2.0, 2.0)

# ╔═╡ 4c985b30-307e-444c-bebf-94bba60500fe
beta_samples = randsample(weight, 10000)

# ╔═╡ e6405695-7577-4654-8971-496aad5f7e82
md"Let's see what this distribution looks like using UnicodePlots.  If you don't have it installed already install with:"

# ╔═╡ eb64defe-bce0-46d1-aa4b-83ea6f7927ab
UnicodePlots.histogram(beta_samples)

# ╔═╡ 8c796c06-0413-4430-8bc1-652471a4bc49
md"""
The distribution is symmetric around 0.5 and has support over the the interval [0, 1].

So far we have not done anything we couldn't do with `Distributions.jl`.
A primary distinction between a package like `Distribution.jl`, is that `Omega.jl` allows you to __condition__ probability distributions.

Create a model representing four flips of the coin.
Since a coin can be heads or tales, the appropriate distribution is the [bernouli distribution](https://en.wikipedia.org/wiki/Bernoulli_distribution):"""

# ╔═╡ e92d4bdb-b0f5-40f9-ac72-ba6512e40e7a
nflips = 4

# ╔═╡ 4c80763b-36ef-4dd7-9fcc-77865d410dd5
typeof(~ Bernoulli.(weight))

# ╔═╡ 0f6b489e-37c9-4728-ac1f-e9fa8db41a45
randsample(@~ (Bernoulli.(weight)))

# ╔═╡ 5ca61b39-a4bc-42d9-8bad-8a234f223b70
coinflips = Mv(Bernoulli.(weight), 1:nflips)

# ╔═╡ b8c6c52c-1bed-4b3f-a970-a6c4b30a6457
md"""

Take note that `weight` is the random variable defined previously.
`bernoulli` takes a type as its secoond argument; `Bool` indicates the result will be a `Bool` rather than an `Int`.

`coinflips` is a normal Julia array of Random Variables (`RandVar`s).
For reasons we will elaborate in later sections, it will be useful to have an `Array`-valued `RandVar` (instead of an `Array` of `RandVar`).

One way to do this (there are several ways discuseed later), is to use the function `randarray`
"""

# ╔═╡ 6351d968-668b-4df6-9fb8-d2f2ce97de1d
md"`coinflips` is a random variable and hence we can sample from it with `randsample`"

# ╔═╡ b6d44330-6b40-4a42-bea6-d915e9e35945
randsample(coinflips)

# ╔═╡ 3d76d33f-4149-404c-b929-143562919d2c
md"""Now we can condition the model.
We want to find the conditional distribution over the weight of the coin given some observations.
"""

# ╔═╡ ffb7ae8b-3d3f-4098-a79a-52bd4c541790
observations = [true, true, true, false]

# ╔═╡ d1134d33-2dfa-47b0-90cc-28fa20f6bbdb
md"Create a predicate that tests whether simulating from the model matches the observed data:"

# ╔═╡ 3e1f5056-0c16-4cbd-af84-10f835bf656d
condition = coinflips .== observations

# ╔═╡ 2f6c2ed4-614a-4d6d-83bb-32d2a2232a8e
md"""
`condition` is a random variable; we can sample from it.  The function `==ᵣ` (and more generally functions subscripted with ᵣ) should be read as "a realization of coinflips == observations"

We can use `rand` to sample from the model conditioned on `condition` being true:"""

# ╔═╡ 370da9a6-6e6f-42dd-83af-ba02d629d6be
weight_samples = randsample(weight |ᶜ condition, 10; alg = RejectionSample)

# ╔═╡ 728d77db-64ed-45d1-8c69-85d83ff2d3b6
md"""
`weight_samples` is a set of `10` samples from the conditional (sometimes called posterior) distribution of `weight` condition on the fact that coinflips == observations.

In this case, `rand` takes
- A random variable we want to sample from
- A predicate (type `RandVar` which evaluates to a `Bool`) that we want to condition on, i.e. assert that it is true
- An inference algorithm.  Here we use rejection sampling.

Plot a histogram of the weights like before:
"""

# ╔═╡ 8c7684b3-9a1f-4e09-b8ba-038600150f27
UnicodePlots.histogram(weight_samples)

# ╔═╡ 671aae80-cb2d-4ad4-9964-a07f5f9cd0ef
md"""Observe that our belief about the weight has now changed.
We are more convinced the coin is biased towards heads (`true`)."""

# ╔═╡ Cell order:
# ╠═b7772def-6186-44a2-b0d8-bbf55855948a
# ╠═a194ae49-7def-4020-b047-995f15ad6516
# ╟─1d48fee0-8bc6-11ec-3c86-3f1be0c6595c
# ╠═4e023a0d-8860-4d3e-ad20-7f6f2026efad
# ╟─6ef3eaa6-87e0-4206-b1b4-17e9fbc820a0
# ╠═eb7d27e9-2784-48be-b96c-4810edbfd07c
# ╠═4c985b30-307e-444c-bebf-94bba60500fe
# ╟─e6405695-7577-4654-8971-496aad5f7e82
# ╠═eb64defe-bce0-46d1-aa4b-83ea6f7927ab
# ╟─8c796c06-0413-4430-8bc1-652471a4bc49
# ╠═e92d4bdb-b0f5-40f9-ac72-ba6512e40e7a
# ╠═4c80763b-36ef-4dd7-9fcc-77865d410dd5
# ╠═0f6b489e-37c9-4728-ac1f-e9fa8db41a45
# ╠═5ca61b39-a4bc-42d9-8bad-8a234f223b70
# ╟─b8c6c52c-1bed-4b3f-a970-a6c4b30a6457
# ╟─6351d968-668b-4df6-9fb8-d2f2ce97de1d
# ╠═b6d44330-6b40-4a42-bea6-d915e9e35945
# ╟─3d76d33f-4149-404c-b929-143562919d2c
# ╠═ffb7ae8b-3d3f-4098-a79a-52bd4c541790
# ╟─d1134d33-2dfa-47b0-90cc-28fa20f6bbdb
# ╠═3e1f5056-0c16-4cbd-af84-10f835bf656d
# ╟─2f6c2ed4-614a-4d6d-83bb-32d2a2232a8e
# ╠═370da9a6-6e6f-42dd-83af-ba02d629d6be
# ╟─728d77db-64ed-45d1-8c69-85d83ff2d3b6
# ╠═8c7684b3-9a1f-4e09-b8ba-038600150f27
# ╟─671aae80-cb2d-4ad4-9964-a07f5f9cd0ef
