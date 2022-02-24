### A Pluto.jl notebook ###
# v0.18.1

using Markdown
using InteractiveUtils

# ╔═╡ 70a3c49c-b605-4edc-aeef-656eb8437cbb
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    using Omega, Distributions, UnicodePlots, OmegaExamples
end

# ╔═╡ 4a756c9c-7396-4f88-bae4-ad7fae133a23
md"""
	Entities should not be multiplied without necessity. – William of Ockham

In learning and perceiving we are fitting models to the data of experience. Typically our hypothesis space will span models varying greatly in complexity: some models will have many more free parameters or degrees of freedom than others. Under traditional approaches to model fitting we adjust each model’s parameters until it fits best, then choose the best-fitting model; a model with strictly more free parameters will tend to be preferred regardless of whether it actually comes closer to describing the true processes that generated the data. It then often generalizes less well – this is called over fitting.

But this is not the way the mind works. Humans assess models with a natural eye for complexity, balancing fit to the data with model complexity in subtle ways that will not inevitably prefer the most complex model. Instead we often seem to judge models using Occam’s razor: we choose the least complex hypothesis that fits the data well. In doing so we avoid over-fitting our data in order to support successful generalizations and predictions.
"""

# ╔═╡ af76aa17-dcce-4f9d-bfef-ec0597b2b3cf
md"""
# Occam’s Razor
An elegant and powerful form of Occam’s razor arises in the context of Bayesian inference, known as the Bayesian Occam’s razor. Bayesian Occam’s razor refers to the fact that “more complex” hypotheses about the data are penalized automatically in conditional inference. In many formulations of Occam’s razor, complexity is measured syntactically: for instance, it may be the description length of the hypothesis in some representation language, or a count of the number of free parameters used to specify the hypothesis. Syntactic forms of Occam’s razor have difficulty justifying the complexity measure on principled, non-arbitrary grounds. They also leave unspecified exactly how the weight of a complexity penalty should trade off with a measure of fit to the data. Fit is intrinsically a semantic notion, a matter of correspondence between the model’s predictions and our observations of the world. When complexity is measured syntactically and fit is measured semantically, they are intrinsically incommensurable and the trade-off between them will always be to some extent arbitrary.

In the Bayesian Occam’s razor, both complexity and fit are measured semantically. The semantic notion of complexity is a measure of flexibility: a hypothesis that is flexible enough to generate many different sets of observations is more complex, and will tend to receive lower posterior probability than a less flexible hypothesis that explains the same data. Because more complex hypotheses can generate a greater variety of data sets, they must necessarily assign a lower probability to each one. When we condition on some data, all else being equal, the posterior distribution over the hypotheses will favor the simpler ones because they have the tightest fit to the observations.

From the standpoint of a probabilistic programming language, the Bayesian Occam’s razor is essentially inescapable. We do not judge models based on their best fitting behavior but rather on their average behavior. No fitting per se occurs during conditional inference. Instead, we draw conditional samples from each model representing the model’s likely ways of generating the data. A model that tends to fit the data well on average – to produce relatively many generative histories with that are consistent with the data – will do better than a model that can fit better for certain parameter settings but worse on average.

## The Law of Conservation of Belief
It is convenient to emphasize an aspect of probabilistic modeling that seems deceptively trivial, but comes up repeatedly when thinking about inference. In Bayesian statistics we think of probabilities as being degrees of belief. Our generative model reflects world knowledge and the probabilities that we assign to the possible sampled values reflect how strongly we believe in each possibility. The laws of probability theory ensure that our beliefs remain consistent as we reason.

A consequence of belief maintenance is known as the Law of Conservation of Belief. Here are two equivalent formulations of this principle:

* Sampling from a distribution selects exactly one possibility (in doing so it implicitly rejects all other possible values).
* The total probability mass of a distribution must sum to 1. That is, we only have a single unit of belief to spread around.

The latter formulation leads to a common metaphor in discussing generative models: We can usefully think of belief as a “currency” that is “spent” by the probabilistic choices required to construct a sample. Since each choice requires “spending” some currency, an outcome that requires more choices to construct it will generally be more costly, i.e. less probable.

It is this conservation of belief that gives rise to the Bayesian Occam’s razor. A hypothesis that spends its probability on many alternatives that don’t explain the current data will have less probability for the alternatives that do, and will hence do less well overall than a hypothesis which only entertains options that fit the current data. We next examine a special case where this tradeoff plays out clearly, the size principle, then come back to the more general cases.

# The Size Principle
A simple case of Bayes Occam’s razor comes from the size principle (Tenenbaum and Griffiths, 2001): Of hypotheses which generate data uniformly, the one with smallest extension that is still consistent with the data is the most probable.

The following program demonstrates the size principle with a very simple model. Here we have two hypothesized sets: Big has 6 elements and Small has 3 elements. The generative model chooses one of the hypotheses at random and samples some number of symbols from it uniformly. We then wish to infer the hypothesis given observed elements.
"""

# ╔═╡ c29505c7-0057-46ea-b27d-d35281d4e946
function hypothesis_to_dist(hyp, ω, i)
	if hyp== "Big"
		arr  = ["a", "b", "c", "d", "e", "f"]
		return arr[(i~Categorical(ones(6).* (1/6)))(ω)]
	else
		arr  = ["a", "b", "c"]
		return arr[(i~Categorical(ones(3).*(1/3)))(ω)]
	end
end

# ╔═╡ 6ac09102-13d3-432d-8c6d-d34779027741
hypothesis(ω) = (@~ Bernoulli())(ω) ? "Big" : "Small"

# ╔═╡ f1e3d947-9ed5-46e7-8f02-5681f28c2b34
rand_hyp(ω, data) = 
	map(i -> hypothesis_to_dist(hypothesis(ω), ω, i), 1:length(data))

# ╔═╡ 84dd96a2-9347-4557-9997-f54cbc899eaf
data = ["a"]

# ╔═╡ b17022d8-3aa9-49fe-81d2-900850604801
post(data) = hypothesis |ᶜ ((ω -> rand_hyp(ω, data)) ==ₚ data)

# ╔═╡ 8b2efbb1-f395-4b40-9072-bec6faec6ffe
viz(randsample(post(data), 1000))

# ╔═╡ 8723d200-eb30-476d-b9d4-07233dfc8246
md"With a single observed `a`, we already favor hypothesis `Small`. What happens when we increase the amount of observed data? Consider the learning trajectory:"

# ╔═╡ 1fa98cb2-92fa-4a6e-85cb-099c6759ed3f
hyp_post(data) = (hypothesis ==ₚ "Big") |ᶜ ((ω -> rand_hyp(ω, data)) ==ₚ data)

# ╔═╡ f3cdfea3-3458-40dd-a233-f56c2651f4d2
full_data = ["a", "b", "a", "b", "b", "a", "b"]

# ╔═╡ bcdf5737-5d46-4101-b2ad-0c6fc3d6afd0
data_sizes = [0, 1, 3, 5, 7]

# ╔═╡ c2ed6e46-3ce4-4b9c-942e-5591bae43769
prob_Big(size, data) = mean(randsample(hyp_post(data[1:size]), 1000))

# ╔═╡ 0d182c8e-bc9e-4d0d-ba08-6414b4f27ace
lineplot(map(i -> prob_Big(i, full_data), data_sizes))

# ╔═╡ d2f7279c-43ea-4921-ad44-19c04bb2b0a3
md"""
As the number of data points increases, the hypothesis `Small` rapidly comes to dominate the posterior distribution. Why is this happening? Observations are distributed uniformly over the hypothesized set, the law of conservation of belief and the symmetry between observations imply that the probability of a draw from `Big` is $\frac{1}{6}$, while the probability of a draw from `Small` is $\frac{1}{3}$. Thus, by the product rule of probabilities, the probability of drawing a set of $N$ observations from `Big` is $(\frac{1}{6})^{N}$, while the probability of drawing a set of observations from `Small` is $(\frac{1}{3})^{N}$. The later probability decreases much more slowly than the former as the number of observations increases. Using Bayes’ rule, the posterior distribution over hypotheses is given by:

$P(hypothesis∣observations) ∝ P(observations∣hypothesis)P(hypothesis)$

Because our hypotheses are equally probable a priori, this simplifies to:

$P(hypothesis∣observations) ∝ P(observations∣hypothesis)$

So we see that the posterior distribution over hypotheses, in this case, is just the normalized likelihood $P(observations∣hypothesis)$. The likelihood ratio, $\frac{P(observations∣Big)}{P(observations∣Small)} = (\frac{1}{2})^{N}$, determines how quickly the simpler hypothesis `Small` comes to dominate the posterior.

One way to understand the Size Principle is that probabilistic inference takes into account _implicit negative evidence_. More flexible hypotheses could have generated more observations. Thus if those hypotheses were the true hypotheses we would expect to see a greater variety of observations. If the data does not contain them, this is a form of negative evidence against those hypotheses. Importantly, the Size Principle tells us that the prior distribution on hypotheses does not have to penalize complexity. The complexity of the hypothesis itself will lead to its being disfavored in the posterior distribution.

The size principle is related to an influential proposal in linguistics known as the _subset principle_. Intuitively, the subset principle suggests that when two grammars both account for the same data, the grammar that generates a smaller language should be preferred. (The name “subset principle” was originally introduced by Bob Berwick to refer to a slightly different result.)
"""

# ╔═╡ 0b580918-f6ac-4f98-b9ba-aa86710ea3d6
md"""
# Generalizing the Size Principle: Bayes Occam’s Razor
In our example above we have illustrated Bayes Occam’s razor with examples based strictly on the “size” of the hypotheses involved, however, the principle is more general. The Bayesian Occam’s razor says that all else being equal the hypothesis that assigns the highest likelihood to the data will dominate the posterior. Because of the law of conservation of belief, assigning higher likelihood to the observed data requires assigning lower likelihood to other possible data. Consider the following example:
"""

# ╔═╡ 1d5f6c99-7ee1-46b7-bfe5-826813553658
function hypothesis_to_dist_(hyp, ω, i)
	arr  = ["a", "b", "c", "d"]
	if hyp== "A"
		return arr[(i~Categorical([0.375, 0.375, 0.125, 0.125]))(ω)]
	else
		return arr[(i~Categorical([0.25, 0.25, 0.25, 0.25]))(ω)]
	end
end

# ╔═╡ 1721e80d-c0b7-4b5d-bfff-d8eab4eef690
obs_data = ["a", "b", "a", "b", "c", "d", "b", "b"]

# ╔═╡ ac5a2e51-0ee0-464d-bb45-f1d0f2ab4338
hypothesis_(ω) = (@~ Bernoulli())(ω) ? "A" : "B"

# ╔═╡ 16edd327-e590-44c9-8474-6e92cfe05049
rand_hyp_(ω, data) = 
	map(i -> hypothesis_to_dist_(hypothesis_(ω), ω, i), 1:length(data))

# ╔═╡ 789d19ab-88a9-4a75-b72a-d3c752014f1c
posterior(data) = hypothesis_ |ᶜ ((ω -> rand_hyp_(ω, data)) ==ₚ data)

# ╔═╡ 8b13fac0-96b9-4d28-8e5e-92b71e38f8af
viz(randsample(posterior(obs_data), 1000))

# ╔═╡ f437636e-51f9-4bed-8bc7-4fcd174b5f75
md"""
In this example, unlike the size principle cases above, both hypotheses lead to the same possible observed values. However, hypothesis A is skewed toward examples a and b – while it can produce c or d, it is less likely to do so. In this sense hypothesis A is less flexible than hypothesis B. The data set we conditioned on also has exemplars of all the elements in the support of the two hypotheses. However, because there are more exemplars of elements favoured by hypothesis A, this hypothesis is favoured in the posterior. The Bayesian Occam’s razor emerges naturally here.

These examples suggest another way to understand Bayes Occam’s razor: the posterior distribution will favour hypotheses for which the data set is simpler in the sense that it is more “easily generated.” Here more “easily” generated means generated with higher probability. We will see a more striking example of this for compositional models at the end of this section of the tutorial.

# Model selection with the Bayesian Occam’s Razor
The law of conservation of belief turns most clearly into Occam’s Razor when we consider models with more internal structure: some continuous or discrete parameters that at different settings determine how likely the model is to produce data that look more or less like our observations. To select among models we simply need to describe each model as a probabilistic program, and also to write a higher-level program that generates these hypotheses.

## Example: Fair or unfair coin?
In a previous chapter, we considered learning about the weight of a coin and noted that a simple prior on weights seemed unable to capture our more discrete intuition – that we first decide if the coin is fair or not, and only then worry about its weight. This example shows how our inferences about coin flipping can be explained in terms of model selection guided by the Bayesian Occam’s razor. Imagine a coin that you take out of a freshly unwrapped roll of quarters straight from the bank. Almost surely this coin is fair… But how does that sense change when you see more or less anomalous sequences of flips? We can simultaneously ask if the coin is fair, and what is its weight.
"""

# ╔═╡ c876d976-ea6a-442c-8fdc-ba08f575b860
observed_data = ["h", "h", "t", "h", "t", "h", "h", "h", "t", "h"] # fair coin
# observed_data = repeat(["h"], 10) #? suspicious coincidence, probability of H = 0.5
# observed_data = repeat(["h"], 15) # probably unfair - probablility of h is near 1
# observed_data = repeat(["h"], 20) # definitely unfair - probablility of h is near 1
# observed_data = randsample(ifelseₚ((@~ Bernoulli(0.85)), "h", "t") # unfair coin, probability of H = 0.85

# ╔═╡ 62febc1d-f325-43cd-801b-a0a40c4f6909
fair_prior = 0.999

# ╔═╡ 6d83b3c2-fdb7-45e0-8e20-a5780ee84b20
pseudo_counts = (α = 1, β = 1)

# ╔═╡ d18bd20f-3db5-446c-bc28-80e981b4aa0a
fair = @~ Bernoulli(fair_prior)

# ╔═╡ de7c9b8b-7692-448f-aa73-e7c67575afee
coin_weight = ifelseₚ(fair, 0.5, @~ Beta(pseudo_counts...))

# ╔═╡ d9ad32b3-f21f-433a-9e5d-85767c564592
viz(randsample(coin_weight, 1000))

# ╔═╡ d4099783-fa23-4208-9c49-03ad1fffa2e7
evidence(data) = manynth(Bernoulli(coin_weight), 1:length(data)) ==ₚ (data .== "h")

# ╔═╡ 0ac4b96e-7b88-42d5-8db3-c0db16d3373d
posterior_(data) = (@joint fair coin_weight) |ᶜ evidence(data)

# ╔═╡ ff4b24be-bbc4-44c4-8ca1-748291fefc3c
post_ = randsample(posterior(observed_data), 1000, alg = MH)

# ╔═╡ ff4969a3-2015-4fcb-a2c5-33dd9f768a32
viz(map(p -> p.fair, post_))

# ╔═╡ 718fb8af-3118-4b54-a7f8-52a57cf7dbd6
viz(map(p -> p.coin_weight, post_))

# ╔═╡ 385907e4-58df-4752-8846-2ccbf961c923
md"""
Try some of the observation sets that we’ve commented out above and see if the inferences accord with your intuitions.

Now let’s look at the learning trajectories for this model:
"""

# ╔═╡ abcd9e36-bb81-4401-9a2e-37a3d868f9ef
true_coin = ifelseₚ((@~ Bernoulli(0.9)), "h", "t")

# ╔═╡ 25df8264-16c7-4e09-9e28-6f50c0dfbb57
data_sizes_ = [0,1,3,6,10,20,30,40,50,60,70,100]

# ╔═╡ 0cf65054-f35c-494d-b51b-d17a0abbb285
predictions = 
	mean.(map(d -> randsample(posterior(randsample(true_coin, d)), 1000, alg = MH), data_sizes_))

# ╔═╡ e7a9cc50-728d-4d84-9996-b7ed02b61a78
lineplot(predictions, data_sizes_)

# ╔═╡ 6865652b-337e-48eb-856e-f1dbf89de354
md"""
In general (though not on every run) the learning trajectory stays near $0.5$ initially—favouring the simpler hypothesis that the coin is fair—then switches fairly abruptly to near $0.9$ — as it infers that it is an unfair coin and likely has high weight. Here the Bayesian Occam’s Razor penalizes the hypothesis with the flexibility to learn any coin weight until the data overwhelmingly favour it.

### The Effect of Unused Parameters
When statisticians suggest methods for model selection, they often include a penalty for the _number_ of parameters. This seems like a worrying policy from the point of view of a probabilistic program: we could always introduce parameters that are not used, and therefore have no effect on the program. For instance, we could change the above coin flipping example so that it draws the potential unfair coin weight even in the model which gives a fair coin:
"""

# ╔═╡ b9a06e66-f98c-44f5-8fd3-4cc9fc7c139f
unfair_weight = @~ Beta(pseudo_counts...)

# ╔═╡ 3a8b42de-bbc1-4f00-ad81-8c4d30c19a95
coin_weight_ = ifelseₚ(fair, 0.5, unfair_weight)

# ╔═╡ 746c1ca8-e58b-40e0-9793-b268efcebbd2
results = (@joint fair coin_weight_) |ᶜ ((@~ Bernoulli(coin_weight_)) ==ₚ true)

# ╔═╡ 1b32a911-0118-41ba-b3db-70bda2d85c0f
results_samples = randsample(results, 1000)

# ╔═╡ 87284531-eed0-47cd-8dbb-e9282dff8d09
viz(map(p -> p.fair, results_samples))

# ╔═╡ 4aa478c4-c838-418e-83d4-a9437af1fbe9
viz(map(p -> p.coin_weight_, results_samples))

# ╔═╡ 28487db4-9f89-45f3-aa44-9a435d239ec8
md"""
The two models now have the same number of free parameters (the unfair coin weight), but we will still favor the simpler hypothesis, as we did above. Why? The Bayesian Occam’s razor penalizes models not for having more parameters (or longer code) but for too much flexibility – being able to fit too many other potential observations. Unused parameters (or parameters with very little effect) don’t increase this flexibility, and hence aren’t penalized. The Bayesian Occam’s razor only penalizes complexity that matters for prediction, and only to the extent that it matters.

### Example: Curve Fitting
This example shows how the Bayesian Occam’s Razor can be used to select the right order of a polynomial fit.
"""

# ╔═╡ 49948540-e8a1-4c22-b45e-d839b8dacd17
make_poly(as) = var -> sum(map(x -> x[2] * (var ^ (x[1] - 1)), enumerate(as)))

# ╔═╡ f34e21b8-1a6f-4d7e-b9e5-4ee64ad22850
coeffs = manynth(Normal(0, 2), 1:4)

# ╔═╡ e44f9fb1-2fff-463d-a4c7-7c5119565787
order = @~ DiscreteUniform(1, 4)

# ╔═╡ 659952d0-59b2-48b3-b570-7ee8781cd3ee
f(ω) = make_poly(coeffs(ω)[1 : order(ω)])

# ╔═╡ 4cb68b2f-94b0-499f-80bd-a3fde0bb0233
fn(i, ω, x) = (i ~ Normal(f(ω)(x), 2))(ω)

# ╔═╡ 8fe06604-c131-48ce-ac2f-7972e095129e
obs_fn(data) = ω -> all(map(d -> fn(d[1], ω, d[2].x) == d[2].y, enumerate(data)))

# ╔═╡ 1f506494-f0fc-4d31-801e-cb455ee266c9
ret = @joint order coeffs

# ╔═╡ 9296fb16-ef0d-4fa5-8590-45142388cb9c
obs_data_ = [
	(x = - 4, y = 69.76636938284166), 
	(x = -3, y = 36.63586217969598),
	(x = -2, y = 19.95244368751754), 
	(x = -1, y = 4.819485497724985), 
	(x = 0, y = 4.027631414787425),
	(x = 1, y = 3.755022418210824), 
	(x = 2, y = 6.557548104903805),
	(x = 3, y = 23.922485493795072),
	(x = 4, y = 50.69924692420815)
]

# ╔═╡ f55bb58e-08a3-48f5-8e85-8a3d13c5833e
p_ = ret |ᶜ obs_fn(obs_data_)

# ╔═╡ 1c0e7ddd-8afa-4c7a-8940-b2359335c175
randsample(p_, 1000, alg = MH)

# ╔═╡ 61579949-3093-4360-a3a0-7359cfd8e111
md"Try the above code using a different data set generated from the same function:"

# ╔═╡ bc28d14a-732a-4476-ad9b-96a00f2d2c63
size = -4:4

# ╔═╡ 991131ba-e2df-48dc-9f55-f4cc397b78b3
data_ = randsample(ω -> map(x -> (x, (@~ Normal(f(ω)(x), 2))(ω)), size))

# ╔═╡ afd262c9-53ac-45ea-8d57-2519000ae567
md"You can also try making the data set smaller, or generate data from a different order polynomial. How much data does it take tend to believe the polynomial is third order?"

# ╔═╡ Cell order:
# ╠═70a3c49c-b605-4edc-aeef-656eb8437cbb
# ╟─4a756c9c-7396-4f88-bae4-ad7fae133a23
# ╟─af76aa17-dcce-4f9d-bfef-ec0597b2b3cf
# ╠═c29505c7-0057-46ea-b27d-d35281d4e946
# ╠═6ac09102-13d3-432d-8c6d-d34779027741
# ╠═f1e3d947-9ed5-46e7-8f02-5681f28c2b34
# ╠═84dd96a2-9347-4557-9997-f54cbc899eaf
# ╠═b17022d8-3aa9-49fe-81d2-900850604801
# ╠═8b2efbb1-f395-4b40-9072-bec6faec6ffe
# ╟─8723d200-eb30-476d-b9d4-07233dfc8246
# ╠═1fa98cb2-92fa-4a6e-85cb-099c6759ed3f
# ╠═f3cdfea3-3458-40dd-a233-f56c2651f4d2
# ╠═bcdf5737-5d46-4101-b2ad-0c6fc3d6afd0
# ╠═c2ed6e46-3ce4-4b9c-942e-5591bae43769
# ╠═0d182c8e-bc9e-4d0d-ba08-6414b4f27ace
# ╟─d2f7279c-43ea-4921-ad44-19c04bb2b0a3
# ╟─0b580918-f6ac-4f98-b9ba-aa86710ea3d6
# ╠═1d5f6c99-7ee1-46b7-bfe5-826813553658
# ╠═1721e80d-c0b7-4b5d-bfff-d8eab4eef690
# ╠═ac5a2e51-0ee0-464d-bb45-f1d0f2ab4338
# ╠═16edd327-e590-44c9-8474-6e92cfe05049
# ╠═789d19ab-88a9-4a75-b72a-d3c752014f1c
# ╠═8b13fac0-96b9-4d28-8e5e-92b71e38f8af
# ╟─f437636e-51f9-4bed-8bc7-4fcd174b5f75
# ╠═c876d976-ea6a-442c-8fdc-ba08f575b860
# ╠═62febc1d-f325-43cd-801b-a0a40c4f6909
# ╠═6d83b3c2-fdb7-45e0-8e20-a5780ee84b20
# ╠═d18bd20f-3db5-446c-bc28-80e981b4aa0a
# ╠═de7c9b8b-7692-448f-aa73-e7c67575afee
# ╠═d9ad32b3-f21f-433a-9e5d-85767c564592
# ╠═d4099783-fa23-4208-9c49-03ad1fffa2e7
# ╠═0ac4b96e-7b88-42d5-8db3-c0db16d3373d
# ╠═ff4b24be-bbc4-44c4-8ca1-748291fefc3c
# ╠═ff4969a3-2015-4fcb-a2c5-33dd9f768a32
# ╠═718fb8af-3118-4b54-a7f8-52a57cf7dbd6
# ╟─385907e4-58df-4752-8846-2ccbf961c923
# ╠═abcd9e36-bb81-4401-9a2e-37a3d868f9ef
# ╠═25df8264-16c7-4e09-9e28-6f50c0dfbb57
# ╠═0cf65054-f35c-494d-b51b-d17a0abbb285
# ╠═e7a9cc50-728d-4d84-9996-b7ed02b61a78
# ╟─6865652b-337e-48eb-856e-f1dbf89de354
# ╠═b9a06e66-f98c-44f5-8fd3-4cc9fc7c139f
# ╠═3a8b42de-bbc1-4f00-ad81-8c4d30c19a95
# ╠═746c1ca8-e58b-40e0-9793-b268efcebbd2
# ╠═1b32a911-0118-41ba-b3db-70bda2d85c0f
# ╠═87284531-eed0-47cd-8dbb-e9282dff8d09
# ╠═4aa478c4-c838-418e-83d4-a9437af1fbe9
# ╟─28487db4-9f89-45f3-aa44-9a435d239ec8
# ╠═49948540-e8a1-4c22-b45e-d839b8dacd17
# ╠═f34e21b8-1a6f-4d7e-b9e5-4ee64ad22850
# ╠═e44f9fb1-2fff-463d-a4c7-7c5119565787
# ╠═659952d0-59b2-48b3-b570-7ee8781cd3ee
# ╠═4cb68b2f-94b0-499f-80bd-a3fde0bb0233
# ╠═8fe06604-c131-48ce-ac2f-7972e095129e
# ╠═1f506494-f0fc-4d31-801e-cb455ee266c9
# ╠═9296fb16-ef0d-4fa5-8590-45142388cb9c
# ╠═f55bb58e-08a3-48f5-8e85-8a3d13c5833e
# ╠═1c0e7ddd-8afa-4c7a-8940-b2359335c175
# ╟─61579949-3093-4360-a3a0-7359cfd8e111
# ╠═bc28d14a-732a-4476-ad9b-96a00f2d2c63
# ╠═991131ba-e2df-48dc-9f55-f4cc397b78b3
# ╟─afd262c9-53ac-45ea-8d57-2519000ae567
