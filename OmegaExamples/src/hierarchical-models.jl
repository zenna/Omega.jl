### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ c3382f9b-1c46-4efc-b4f3-288caba78983
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    using Omega, Distributions, UnicodePlots, OmegaExamples
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
colour_probs(n, ω, i) = (i~ OmegaExamples.Dirichlet(n, 1))(ω)

# ╔═╡ bf360f12-e0bc-401b-92c1-133cba3cc4f6
make_bag(i, ω, colours, n = @uid) = 
	(pget(colours) ∘ (n~ Categorical(colour_probs(length(colours), ω, i))))(ω)

# ╔═╡ 9bb472fd-f762-470d-bc47-7a7f480c88a7
randsample(ω -> make_bag(1, ω, colours))

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
obs = Dict(1 => ["blue", "blue", "black", "blue", "blue", "blue"],
			2 => ["blue", "green", "blue", "blue", "blue", "red"],
			3 => ["blue", "orange"])

# ╔═╡ 9689c468-21bf-4d7e-9e65-80657ec06990
rand_make_bag(i, ω, colours, k) = map(n -> make_bag(i, ω, colours, n), 1:k)

# ╔═╡ 82508f53-3232-48ac-b07d-62a895a28346
obs_fn = pw(&, 
	((ω -> rand_make_bag(1, ω, colours, length(obs[1]))) ==ₚ obs[1]),
	((ω -> rand_make_bag(2, ω, colours, length(obs[2]))) ==ₚ obs[2]),
	((ω -> rand_make_bag(3, ω, colours, length(obs[3]))) ==ₚ obs[3])
)

# ╔═╡ cd88fd6c-7642-4ff7-9d7d-70184251387c
bags(ω, colours) = (
	bag_1 = make_bag(1, ω, colours),
	bag_2 = make_bag(2, ω, colours),
	bag_3 = make_bag(3, ω, colours),
	bag_n = make_bag(@uid, ω, colours)
)

# ╔═╡ 537be4c0-8c9e-4f01-bd82-298a33cdb6aa
predictives = (ω -> bags(ω, colours)) |ᶜ obs_fn

# ╔═╡ 255a909a-863d-4958-a8a1-c63c377d8dfd
viz_marginals(randsample(predictives, 1000, alg = MH))

# ╔═╡ 5f4256bc-9296-4709-bee6-16e11ce8cda2
md"""
In all cases there is a fair amount of residual uncertainty about what other colors might be seen. Nothing significant is learned about the new bag as it has no observations. This generative model describes the prototypical mixture in each bag, but it does not attempt learn a common higher-order prototype. It is like learning separate prototypes for subordinate classes _poodle_, _Dalmatian_, and _Labrador_, without learning a prototype for the higher-level kind _dog_.

Let us introduce another level of abstraction: a global prototype that provides a prior on the specific mixtures of each bag.
"""

# ╔═╡ 2567de6c-0944-4f25-9969-957703301c43
ϕ = @~ OmegaExamples.Dirichlet(5, 1)

# ╔═╡ 3a36eec2-171a-4b67-9d30-97ca92301a02
prototype(ω) = ϕ(ω) .* 5

# ╔═╡ 3013d04b-ea8d-4d5b-83db-da73ec82a98f
colour_probs_global(i, ω) = (i~ OmegaExamples.Dirichlet(prototype(ω)))(ω)

# ╔═╡ 81c13a93-8c37-481f-8187-7c5cd01471eb
make_bag_global(i, ω, colours, n = @uid) = 
	(pget(colours) ∘ (n~ Categorical(colour_probs_global(length(colours), ω, i))))(ω)

# ╔═╡ 2ba74743-2584-4cdd-a21f-c724d527e588
rand_make_bag_gl(i, ω, colours, k) = map(n -> make_bag_global(i, ω, colours, n), 1:k)

# ╔═╡ d8165f92-6a64-4420-b9fd-198e9c105543
obs_fn_global = pw(&, 
	((ω -> rand_make_bag_gl(1, ω, colours, length(obs[1]))) ==ₚ obs[1]),
	((ω -> rand_make_bag_gl(2, ω, colours, length(obs[2]))) ==ₚ obs[2]),
	((ω -> rand_make_bag_gl(3, ω, colours, length(obs[3]))) ==ₚ obs[3])
)

# ╔═╡ 34580098-147c-4592-9e1b-00ed5d0d23f0
bags_global(ω, colours) = (
	bag_1 = make_bag_global(1, ω, colours),
	bag_2 = make_bag_global(2, ω, colours),
	bag_3 = make_bag_global(3, ω, colours),
	bag_n = make_bag_global(@uid, ω, colours)
)

# ╔═╡ 65cee163-c41f-463d-9e8a-8b4caedc6ef9
predictives_global = (ω -> bags_global(ω, colours)) |ᶜ obs_fn_global

# ╔═╡ 418939ad-7f4b-4930-a845-ffa6d6d4e21d
viz_marginals(randsample(predictives_global, 1000, alg = MH))

# ╔═╡ 848e250a-707f-4d18-bb45-96de52f853de
md"""
Compared with inferences in the previous example, this extra level of abstraction enables faster learning: more confidence in what each bag is like based on the same observed sample. This is because all of the observed samples suggest a common prototype structure, with most of its weight on `blue` and the rest of the weight spread uniformly among the remaining colours. In particular, we now make strong inferences for bag $3$ that blue is likely but orange isn’t – quite different from the earlier case without a shared global prototype.

Statisticians sometimes refer to this phenomenon of inference in hierarchical models as “sharing of statistical strength”: it is as if the sample we observe for each bag also provides a weaker indirect sample relevant to the other bags. In machine learning and cognitive science this phenomenon is often called _transfer learning_. Intuitively, knowing something about bags in general allows the learner to transfer knowledge gained from draws from one bag to other bags. This example is analogous to seeing several examples of different subtypes of dogs and learning what features are in common to the more abstract basic-level dog prototype, independent of the more idiosyncratic features of particular dog subtypes.

Learning about shared structure at a higher level of abstraction also supports inferences about new bags without observing any examples from that bag: a hypothetical new bag could produce _any_ colour, but is likely to have more blue marbles than any other colour. We can imagine hypothetical, previously unseen, new subtypes of dogs that share the basic features of dogs with more familiar kinds but may differ in some idiosyncratic ways.

# The Blessing of Abstraction
Now let’s investigate the relative learning speeds at different levels of abstraction. Suppose that we have a number of bags that all have identical prototypes: they mix red and blue in proportion $2:1$. But the learner doesn’t know this. She observes only one ball from each of $N$ bags. What can she learn about an individual bag versus the population as a whole as the number of bags changes? We plot learning curves: the mean squared error (MSE) of the prototype from the true prototype for the specific level (the first bag) and the general level (global prototype) as a function of the number of observed data points. We normalize by the MSE of the first observation (from the first bag), to focus on the effects of diverse data. (Note that these MSE quantities are directly comparable because they are each derived from a Dirichlet distribution of the same size – this is often not the case in hierarchical models.)
"""

# ╔═╡ a61e7923-7afa-4f76-8b2c-c677d65e49e1


# ╔═╡ Cell order:
# ╠═c3382f9b-1c46-4efc-b4f3-288caba78983
# ╟─2c1386e4-9011-43e1-935a-0408aa119f81
# ╠═8fbf82d1-f88c-4565-a3e1-70bb949dd1ca
# ╠═d77244a2-6c81-4347-a573-f607c325518b
# ╠═bf360f12-e0bc-401b-92c1-133cba3cc4f6
# ╠═9bb472fd-f762-470d-bc47-7a7f480c88a7
# ╠═6ce22c12-1eea-4f5d-b97b-57c42cde6bf7
# ╠═720e982d-7312-43c6-8658-75271d50b5ae
# ╠═d5f5f577-5fc2-4159-a389-b1b7b8eaaded
# ╠═66e53f00-42bd-46f0-8edc-987630deecb0
# ╠═2b5bded1-6dd5-4bc0-96d1-2e8251d20cd0
# ╠═5f6e1b26-9d1f-4b53-af54-d19d8809b77b
# ╟─c1d86b8a-f7d5-4a29-9fbe-358d010bab86
# ╠═b3a6fceb-133d-4c99-9f85-6559509cf7e0
# ╠═9689c468-21bf-4d7e-9e65-80657ec06990
# ╠═82508f53-3232-48ac-b07d-62a895a28346
# ╠═cd88fd6c-7642-4ff7-9d7d-70184251387c
# ╠═537be4c0-8c9e-4f01-bd82-298a33cdb6aa
# ╠═255a909a-863d-4958-a8a1-c63c377d8dfd
# ╟─5f4256bc-9296-4709-bee6-16e11ce8cda2
# ╠═2567de6c-0944-4f25-9969-957703301c43
# ╠═3a36eec2-171a-4b67-9d30-97ca92301a02
# ╠═3013d04b-ea8d-4d5b-83db-da73ec82a98f
# ╠═81c13a93-8c37-481f-8187-7c5cd01471eb
# ╠═2ba74743-2584-4cdd-a21f-c724d527e588
# ╠═d8165f92-6a64-4420-b9fd-198e9c105543
# ╠═34580098-147c-4592-9e1b-00ed5d0d23f0
# ╠═65cee163-c41f-463d-9e8a-8b4caedc6ef9
# ╠═418939ad-7f4b-4930-a845-ffa6d6d4e21d
# ╟─848e250a-707f-4d18-bb45-96de52f853de
# ╠═a61e7923-7afa-4f76-8b2c-c677d65e49e1
