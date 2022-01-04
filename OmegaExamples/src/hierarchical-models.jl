### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ c3382f9b-1c46-4efc-b4f3-288caba78983
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    using Omega, Distributions, UnicodePlots, FreqTables
end

# ╔═╡ 3c98081d-d887-40cb-bb97-5f963c35bcf1
ω = defω()

# ╔═╡ b4e2cadf-5c9e-49e7-a393-ac91d6cef484
begin
	# Utility functions
	viz(var::Vector{T} where T<:Union{String, Char}) = 	
		barplot(Dict(freqtable(var)))
	viz(var::Vector{<:Real}) = histogram(var, symbols = ["■"])
	viz(var::Vector{Bool}) = viz(string.(var))
	struct UniformDraw{T}
		elem::T
	end
	(u::UniformDraw)(i, ω) = 
		u.elem[(i ~ DiscreteUniform(1, length(u.elem)))(ω)]
	pget(x) = i -> x[i]
	struct Dirichlet{T}
		α::T
	end
	Dirichlet(k::Int64, a::Real) = Dirichlet(a.*ones(k))
	function (d::Dirichlet)(i, ω)
		gammas = [((i..., j) ~ Gamma(αj))(ω) for (j, αj) in enumerate(d.α)]
		Σ = sum(gammas)
		[gamma/Σ for gamma in gammas]
	end
end

# ╔═╡ 2c1386e4-9011-43e1-935a-0408aa119f81
md"""
Human knowledge is organized hierarchically into levels of abstraction. For instance, the most common or basic-level categories (e.g. dog, car) can be thought of as abstractions across individuals, or more often across subordinate categories (e.g., poodle, Dalmatian, Labrador, and so on). Multiple basic-level categories in turn can be organized under superordinate categories: e.g., dog, cat, horse are all animals; car, truck, bus are all vehicles. Some of the deepest questions of cognitive development are: How does abstract knowledge influence learning of specific knowledge? How can abstract knowledge be learned? In this section we will see how such hierarchical knowledge can be modeled with hierarchical generative models: generative models with uncertainty at several levels, where lower levels depend on choices at higher levels.

# Learning a Shared Prototype: Abstraction at the Basic Level
Hierarchical models allow us to capture the shared latent structure underlying observations of multiple related concepts, processes, or systems – to abstract out the elements in common to the different sub-concepts, and to filter away uninteresting or irrelevant differences. Perhaps the most familiar example of this problem occurs in learning about categories. Consider a child learning about a basic-level kind, such as dog or car. Each of these kinds has a prototype or set of characteristic features, and our question here is simply how that prototype is acquired.

The task is challenging because real-world categories are not homogeneous. A basic-level category like dog or car actually spans many different subtypes: e.g., poodle, Dalmatian, Labrador, and such, or sedan, coupe, convertible, wagon, and so on. The child observes examples of these sub-kinds or subordinate-level categories: a few poodles, one Dalmatian, three Labradors, etc. From this data she must infer what it means to be a dog in general, in addition to what each of these different kinds of dog is like. Knowledge about the prototype level includes understanding what it means to be a prototypical dog and what it means to be non-prototypical, but still a dog. This will involve understanding that dogs come in different breeds which share features between them, but also differ systematically as well.

As a simplification of this situation consider the following generative process. We will draw marbles out of several different bags. There are five marble colors. Each bag contains a certain mixture of colors. This generative process is represented in the following example:
"""

# ╔═╡ 8fbf82d1-f88c-4565-a3e1-70bb949dd1ca
colours = ["black", "blue", "green", "orange", "red"]

# ╔═╡ d77244a2-6c81-4347-a573-f607c325518b
colour_probs(n, ω, i) = (i ~ Dirichlet(n, 1))(ω)

# ╔═╡ bf360f12-e0bc-401b-92c1-133cba3cc4f6
make_bag(i, ω, colours) = 
	(pget(colours) ∘ (i ~ Categorical(colour_probs(length(colours), ω, i))))(ω)

# ╔═╡ 6ce22c12-1eea-4f5d-b97b-57c42cde6bf7
bagA, bagB = (@uid, 1), (@uid, 2)

# ╔═╡ 720e982d-7312-43c6-8658-75271d50b5ae
ωs = map(i -> defω(), 1:100)

# ╔═╡ d5f5f577-5fc2-4159-a389-b1b7b8eaaded
let
	bagA_samples = map(ω -> make_bag(bagA, ω, colours), ωs)
	viz(bagA_samples)
end

# ╔═╡ 66e53f00-42bd-46f0-8edc-987630deecb0
let
	bagA_samples = map(ω -> make_bag(bagA, ω, colours), ωs)
	viz(bagA_samples)
end

# ╔═╡ 2b5bded1-6dd5-4bc0-96d1-2e8251d20cd0
let
	bagA_samples = map(ω -> make_bag(bagA, ω, colours), ωs)
	viz(bagA_samples)
end

# ╔═╡ 5f6e1b26-9d1f-4b53-af54-d19d8809b77b
let
	bagB_samples = map(ω -> make_bag(bagB, ω, colours), ωs)
	viz(bagB_samples)
end

# ╔═╡ c1d86b8a-f7d5-4a29-9fbe-358d010bab86
md"""
Here, notice that for the same `ω` and bag, `make_bag` returns the same value in every pass. As this examples shows, memoization is particularly useful when writing hierarchical models because it allows us to associate arbitrary random draws with categories across entire runs of the program. In this case it allows us to associate a particular mixture of marble colors with each bag. The mixture is drawn once, and then remains the same thereafter for that bag. Intuitively, you can see how each sample is sufficient to learn a lot about what that bag is like; there is typically a fair amount of similarity between the empirical color distributions in each of the four samples from `bagA`. In contrast, you should see a different distribution of samples from `bagB`.

Now let’s explore how this model learns about the contents of different bags. We represent the results of learning in terms of the posterior predictive distribution for each bag: a single hypothetical draw from the bag. We will also draw a sample from the posterior predictive distribution on a new bag, for which we have had no observations.
"""

# ╔═╡ b3a6fceb-133d-4c99-9f85-6559509cf7e0
observed_data = Dict(1 => ["blue", "blue", "black", "blue", "blue", "blue"],
			2 => ["blue", "green", "blue", "blue", "blue", "red"],
			3 => ["blue", "orange"])

# ╔═╡ e9caf136-4135-4fda-9f92-c3ad71b994db


# ╔═╡ 5f4256bc-9296-4709-bee6-16e11ce8cda2
md"""
In all cases there is a fair amount of residual uncertainty about what other colors might be seen. Nothing significant is learned about the new bag as it has no observations. This generative model describes the prototypical mixture in each bag, but it does not attempt learn a common higher-order prototype. It is like learning separate prototypes for subordinate classes _poodle_, _Dalmatian_, and _Labrador_, without learning a prototype for the higher-level kind _dog_.

Let us introduce another level of abstraction: a global prototype that provides a prior on the specific mixtures of each bag.
"""

# ╔═╡ 2567de6c-0944-4f25-9969-957703301c43
ϕ = @~ Dirichlet(5)

# ╔═╡ 3a36eec2-171a-4b67-9d30-97ca92301a02
prototype = 

# ╔═╡ Cell order:
# ╠═c3382f9b-1c46-4efc-b4f3-288caba78983
# ╠═3c98081d-d887-40cb-bb97-5f963c35bcf1
# ╠═b4e2cadf-5c9e-49e7-a393-ac91d6cef484
# ╟─2c1386e4-9011-43e1-935a-0408aa119f81
# ╠═8fbf82d1-f88c-4565-a3e1-70bb949dd1ca
# ╠═d77244a2-6c81-4347-a573-f607c325518b
# ╠═bf360f12-e0bc-401b-92c1-133cba3cc4f6
# ╠═6ce22c12-1eea-4f5d-b97b-57c42cde6bf7
# ╠═720e982d-7312-43c6-8658-75271d50b5ae
# ╠═d5f5f577-5fc2-4159-a389-b1b7b8eaaded
# ╠═66e53f00-42bd-46f0-8edc-987630deecb0
# ╠═2b5bded1-6dd5-4bc0-96d1-2e8251d20cd0
# ╠═5f6e1b26-9d1f-4b53-af54-d19d8809b77b
# ╟─c1d86b8a-f7d5-4a29-9fbe-358d010bab86
# ╠═b3a6fceb-133d-4c99-9f85-6559509cf7e0
# ╠═e9caf136-4135-4fda-9f92-c3ad71b994db
# ╟─5f4256bc-9296-4709-bee6-16e11ce8cda2
# ╠═2567de6c-0944-4f25-9969-957703301c43
# ╠═3a36eec2-171a-4b67-9d30-97ca92301a02
