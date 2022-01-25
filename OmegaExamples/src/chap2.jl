### A Pluto.jl notebook ###
# v0.17.6

using Markdown
using InteractiveUtils

# ╔═╡ 97728fb6-7c42-11ec-3a78-d7172e47f880
using Pkg

# ╔═╡ 73e742d8-ca8d-4dcd-92ee-56ae42a3c22e
Pkg.activate(Base.current_project())

# ╔═╡ 099573d4-e4d4-4523-89f7-e023f32f4381
using Omega

# ╔═╡ 8dce2d12-fce9-44de-aab4-b994f1a93f85
using Distributions

# ╔═╡ 865a8bb5-eddd-413f-8127-0b440cccd2f5
using UnicodePlots

# ╔═╡ 338301c7-0464-4803-9c09-a6deb90398fb
Pkg.instantiate()

# ╔═╡ c437c492-6246-4d97-9346-dacb6d9b6bbe
md"## Probabilistic programming in Omega"

# ╔═╡ 72efbebc-f275-4707-8a3f-681c8c8b0838
md"### Introduction"

# ╔═╡ cdd5bba6-87ab-4dc1-a34a-e26f9e1711b0
md"This chapter introduces the probabilistic programming language Omega. The models for agents in this tutorial are all implemented in Omega and so it's important to understand how the language works.

We begin with a quick overview of probabilstic programming.If you are new to probabistic programming, you might want to read an informal introduction(e.g. [here](http://www.pl-enthusiast.net/2014/09/08/probabilistic-programming/) or [here](https://moalquraishi.wordpress.com/2015/03/29/the-state-of-probabilistic-programming/)) or a more technical [survey](https://scholar.google.com/scholar?cluster=16211748064980449900&hl=en&as_sdt=0,5). For a practical introduction to both probabilistic programming and Bayesian modelling, we highly recommend [ProbMods](Archana's Book), which also uses the Omega language."

# ╔═╡ 9fbee918-defa-4cf9-bc65-560b0288ba48


# ╔═╡ 9a02dfe3-618a-4964-bf5f-0bbd07806a39
md"## Omega Stochastic Primitives"

# ╔═╡ 304fc34c-f0d1-426e-b060-b122300c05c8
md"### Sampling from random variables"

# ╔═╡ 8a5d946b-3744-405f-9f15-d70f582b41b6
md"Omega has a large library of primitive probability distributions. Running the 3 cells below multiple time will yield different i.i.d random samples:"

# ╔═╡ eb2074bb-0535-4d67-86de-7cbaa7cad3e5
md"Fair coins (Bernoulli distribution):"

# ╔═╡ aa5a3bde-f962-4814-ae7e-d0a3acf427cb
[randsample(@~Bernoulli()),randsample(@~Bernoulli()),randsample(@~Bernoulli())]

# ╔═╡ c5c240ee-663c-42ef-9198-341aa8da66d6
md"Biased coins (Bernoulli distribution):"

# ╔═╡ 348432df-b57f-4099-a6c1-81ba9637b88f
[randsample(@~Bernoulli(0.9)),randsample(@~Bernoulli(0/9)),randsample(@~Bernoulli(0.9))]

# ╔═╡ 265d3aa9-4d70-463b-b536-d50fdef2a80a
function coinWithSide(ω)
	sides = ["heads", "tails", "side"]
	dist = @~Categorical([.45, .45, .1])
	return sides[dist(ω)]
end

# ╔═╡ c63bdf9b-2bfc-4b35-9116-129411e0b9f4
md"Coins that can land on their edge"

# ╔═╡ b9cc0a62-e85e-4c5a-ba5e-a07a09ec4ca8
randsample(ω->coinWithSide(ω),5)

# ╔═╡ b3b40237-0d96-471f-8d74-fe779810c5e4
md"There are also continious random variables:"

# ╔═╡ f63e123c-3212-4a96-9dd4-1145f0bad64c
md"Two samples from standard Gaussian in 1D: "

# ╔═╡ be9773c5-c23a-4795-a27b-1f34dcfaaec2
[randsample(@~Normal()), randsample(@~Normal())]

# ╔═╡ 05e9eced-4fb3-4862-b729-6d22d2de8455
md"A single sample from a 2D Gaussian: "

# ╔═╡ b14c8069-732e-4c14-9ee3-fa706322fc76
md"You can write your own functions to sample from more complex distributions. This example uses recursion to define a sampler for the Geometric distribution:"

# ╔═╡ effc0e98-f6e4-48fd-8fb9-8b9ad664ec3d
ω = defω()

# ╔═╡ d7e8dbcf-a97f-4571-b41a-9f6931068cea
function geometric(p, ω, i=0)
	flip = i~Bernoulli(p)
	return (flip(ω)) ? (1 + geometric(p,ω, i+1)) : 1
end

# ╔═╡ dc818682-4086-4223-b4a7-8fd16d3c71ed
geometric(0.8, ω)

# ╔═╡ a5697e08-64b3-46f9-bec0-420bfae5ba9a
md"What makes Omega different from conventional programming languages is its ability to perform inference operations using these primitive probability distributions. Distribution objects in Omega have two key features:
* You can draw random i.i.d. samples from a distribution using the special function sample. That is, you sample $x \sim P$ where $P(x)$ is the distribution.
* You can compute the probability (or density) the distribution assigns to a value. That is, to compute $P(x)$, you use mean(randsample(dist,5000)), where dist is the distributions in Omega

The functions above that generate random samples are defined in the Omega library in terms of primitive distribitions (e.g. Bernoulli for flip and Normal for gaussian) and the built-in function sample:
"


# ╔═╡ 34c6be98-f25b-4f06-b36a-fc8e8edfcb6e
function flip(p=0.5)
	dist = @~Bernoulli(p)
	return randsample(dist)
end

# ╔═╡ 13f6c6e3-0304-46d2-95e0-0fd25e063cd6
function gaussian(μ, σ)
	dist = @~Normal(μ,σ)
	return randsample(dist)
end

# ╔═╡ 58846361-9825-421d-a229-85455057c254
[flip(), gaussian(1,1)]

# ╔═╡ 2051f130-5254-4fa1-bc33-883245ec7347
md"To create a new distribution, we pass a (potentially stochastic) function mean to perform *marginalization*. For example, we can use flip as an ingredient of a Binomial distribution"

# ╔═╡ 52248444-b6ac-4ef9-aa5b-6d7251819844
function binomial()
	a = @~Bernoulli()
	b = @~Bernoulli()
	c = @~Bernoulli()
	return a +ₚ b +ₚ c
end

# ╔═╡ 984e3e43-fa1b-407c-a44b-cdb6e18f9e24
randsample(binomial())

# ╔═╡ 4f289a2c-cc53-422a-a189-8aef793fa6b1
[randsample(binomial()),randsample(binomial()),randsample(binomial())]

# ╔═╡ 55fca003-a3ae-4865-8f52-e03c3aab490e
md"### Bayesian inference by conditioning"

# ╔═╡ 6da76d2f-3908-48ed-87c5-7c0756e50cf1
md"The most important use of inference methods is for Bayesian inference. Here our task is to infer the value of some unkown parameter by observing data that depends on the parameter.  For example, if flipping three separate coins produce exactly two Heads, what is the probability that the first coin landed Heads? To solve this in Omega. We use condition to constrain the sum of the variables. The result is a distribution representing the posterior distribution on the first variable a having value true (i.e. “Heads”)."

# ╔═╡ 26e35f85-c1e3-45c1-95e4-db1005468402
a = @~Bernoulli()

# ╔═╡ dffd191d-fa60-4214-b456-905723ddae47
b = @~Bernoulli()

# ╔═╡ 1d1656ba-5d77-4ad6-a68a-ca8377355a5c
c = @~Bernoulli()

# ╔═╡ 60b2fff5-bc0c-4b1e-8e6c-86784a52f08d
a_ = a |ᶜ (a +ₚ b +ₚ c ==ₚ 2)

# ╔═╡ a6effe8d-ac5b-4c4a-a666-a6505217b2b3
md"Probability of first coin being Heads (given exactly two Heads) : "

# ╔═╡ 894873a0-767b-49fb-877e-4eaa510df2e2
mean(randsample(a_,5000))

# ╔═╡ 6eae06da-100a-4508-bed9-15e673ded42c
a_2 = a |ᶜ (a +ₚ b +ₚ c >=ₚ 2)

# ╔═╡ b1dab238-a7a7-482e-8926-055a0e9df236
md"Probability of first coin being Heads (given at least two Heads): "

# ╔═╡ f29740f0-4674-4f41-9e63-ee7e7a1ec246
mean(randsample(a_2,5000))

# ╔═╡ 640f8930-136c-4406-9a4c-de6ed9c2e331
a_3 = ifelseₚ(a, "apple", "oranges")

# ╔═╡ 39a3e980-0373-4024-9932-a0b6e7aad7ff
randsample(a_3,10)

# ╔═╡ ea703c96-3c57-4f9f-858d-84cfcd8920ae
fruit = @~Categorical([0.3, 0.3, 0.4])

# ╔═╡ 6b07bc7d-1120-4440-b735-ac24ed8f18c1
categories = ["apple", "banana", "orange"]

# ╔═╡ c1551598-78f1-4e32-879f-716b229c89d6
tasty = @~Bernoulli(0.7)

# ╔═╡ 29ae5168-2e96-4184-8348-13e0c640f3eb
fruitTasteDist = @joint fruit tasty

# ╔═╡ 49f7e281-64cb-4df2-bfa7-d8e61010311a
randsample(fruitTasteDist)	

# ╔═╡ bd832e17-7eff-4d3c-b3ab-16c8f52975d1
begin
	# Helper functions for probmods
	
	"To visualize the generated samples of a random variable"
	viz(var::Vector{T} where {T<:Union{String,Char}}) =
	    barplot(Dict(freqtable(var)))
	viz(var::Vector{<:Real}) = histogram(var, symbols = ["■"])
	viz(var::Vector{Bool}) = viz(string.(var))
	viz(var::Vector{NamedTuple{U, V}}) where {U, V} = 
	    barplot(Dict(freqtable(var)), ylabel = string(U[1], ", ", U[2]), xlabel = "Frequency")
	
	function viz_marginals(var::Vector{NamedTuple{U, V}}) where {U, V}
	    c = barplot(Dict(freqtable(string.(U[1], "_", map(x -> x[U[1]], var)))))
	    for i in 2:length(U)
	        barplot!(c, Dict(freqtable(string.(U[i], "_", map(x -> x[U[i]], var)))))
	    end
	    c
	end
	
	# Required aditional distributions -
	struct UniformDraw{T}
	    elem::T
	end
	(u::UniformDraw)(i, ω) =
	    u.elem[(i ~ DiscreteUniform(1, length(u.elem)))(ω)]
	
	struct Dirichlet{V}
	    α::V
	end
	Dirichlet(k::Int64, a::Real) = Dirichlet(a .* ones(k))
	
	function (d::Dirichlet)(i, ω)
	    gammas = [((i..., j) ~ Gamma(αj))(ω) for (j, αj) in enumerate(d.α)]
	    Σ = sum(gammas)
	    [gamma / Σ for gamma in gammas]
	end
	
	# Other utility functions
	pget(x) = i -> x[i]
end

# ╔═╡ Cell order:
# ╟─97728fb6-7c42-11ec-3a78-d7172e47f880
# ╟─73e742d8-ca8d-4dcd-92ee-56ae42a3c22e
# ╟─338301c7-0464-4803-9c09-a6deb90398fb
# ╟─099573d4-e4d4-4523-89f7-e023f32f4381
# ╟─8dce2d12-fce9-44de-aab4-b994f1a93f85
# ╟─865a8bb5-eddd-413f-8127-0b440cccd2f5
# ╟─c437c492-6246-4d97-9346-dacb6d9b6bbe
# ╟─72efbebc-f275-4707-8a3f-681c8c8b0838
# ╟─cdd5bba6-87ab-4dc1-a34a-e26f9e1711b0
# ╠═9fbee918-defa-4cf9-bc65-560b0288ba48
# ╟─9a02dfe3-618a-4964-bf5f-0bbd07806a39
# ╟─304fc34c-f0d1-426e-b060-b122300c05c8
# ╟─8a5d946b-3744-405f-9f15-d70f582b41b6
# ╟─eb2074bb-0535-4d67-86de-7cbaa7cad3e5
# ╠═aa5a3bde-f962-4814-ae7e-d0a3acf427cb
# ╟─c5c240ee-663c-42ef-9198-341aa8da66d6
# ╠═348432df-b57f-4099-a6c1-81ba9637b88f
# ╠═265d3aa9-4d70-463b-b536-d50fdef2a80a
# ╟─c63bdf9b-2bfc-4b35-9116-129411e0b9f4
# ╠═b9cc0a62-e85e-4c5a-ba5e-a07a09ec4ca8
# ╟─b3b40237-0d96-471f-8d74-fe779810c5e4
# ╟─f63e123c-3212-4a96-9dd4-1145f0bad64c
# ╠═be9773c5-c23a-4795-a27b-1f34dcfaaec2
# ╟─05e9eced-4fb3-4862-b729-6d22d2de8455
# ╟─b14c8069-732e-4c14-9ee3-fa706322fc76
# ╠═effc0e98-f6e4-48fd-8fb9-8b9ad664ec3d
# ╠═d7e8dbcf-a97f-4571-b41a-9f6931068cea
# ╠═dc818682-4086-4223-b4a7-8fd16d3c71ed
# ╟─a5697e08-64b3-46f9-bec0-420bfae5ba9a
# ╠═34c6be98-f25b-4f06-b36a-fc8e8edfcb6e
# ╠═13f6c6e3-0304-46d2-95e0-0fd25e063cd6
# ╠═58846361-9825-421d-a229-85455057c254
# ╟─2051f130-5254-4fa1-bc33-883245ec7347
# ╠═52248444-b6ac-4ef9-aa5b-6d7251819844
# ╠═984e3e43-fa1b-407c-a44b-cdb6e18f9e24
# ╠═4f289a2c-cc53-422a-a189-8aef793fa6b1
# ╟─55fca003-a3ae-4865-8f52-e03c3aab490e
# ╟─6da76d2f-3908-48ed-87c5-7c0756e50cf1
# ╠═26e35f85-c1e3-45c1-95e4-db1005468402
# ╠═dffd191d-fa60-4214-b456-905723ddae47
# ╠═1d1656ba-5d77-4ad6-a68a-ca8377355a5c
# ╠═60b2fff5-bc0c-4b1e-8e6c-86784a52f08d
# ╟─a6effe8d-ac5b-4c4a-a666-a6505217b2b3
# ╠═894873a0-767b-49fb-877e-4eaa510df2e2
# ╠═6eae06da-100a-4508-bed9-15e673ded42c
# ╟─b1dab238-a7a7-482e-8926-055a0e9df236
# ╠═f29740f0-4674-4f41-9e63-ee7e7a1ec246
# ╠═640f8930-136c-4406-9a4c-de6ed9c2e331
# ╠═39a3e980-0373-4024-9932-a0b6e7aad7ff
# ╠═ea703c96-3c57-4f9f-858d-84cfcd8920ae
# ╠═6b07bc7d-1120-4440-b735-ac24ed8f18c1
# ╠═c1551598-78f1-4e32-879f-716b229c89d6
# ╠═29ae5168-2e96-4184-8348-13e0c640f3eb
# ╠═49f7e281-64cb-4df2-bfa7-d8e61010311a
# ╟─bd832e17-7eff-4d3c-b3ab-16c8f52975d1
