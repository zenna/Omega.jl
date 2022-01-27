### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ cecc21c0-7ab0-11ec-1952-459400f649e1
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    using Omega, Distributions, UnicodePlots, OmegaExamples
	using Images, Plots
end

# ╔═╡ 2ed16474-67d8-4c3a-b0c4-4700a8ad8a18
md"""
In the chapter on Hierarchical Models, we saw the power of probabilistic inference in learning about the latent structure underlying different kinds of observations: the mixture of colors in different bags of marbles, or the prototypical features of categories of animals. In that discussion we always assumed that we knew what kind each observation belonged to—the bag that each marble came from, or the subordinate, basic, and superordinate category of each object. Knowing this allowed us to pool the information from each observation for the appropriate latent variables. What if we don’t know a _priori_ how to divide up our observations? In this chapter we explore the problem of simultaneously discovering kinds and their properties – this can be done using _mixture models_.

# Learning Categories

Imagine a child who enters the world and begins to see objects. She can’t begin to learn the typical features of cats or mice directly, because she doesn’t yet know that there are such kinds of objects as cats and mice. Yet she may quickly notice that some of the objects all tend to purr and have claws, while other objects are small and run fast—she can _cluster_ the objects together on the basis of common features and thus form categories (such as cats and mice), whose typical features she can then learn.

To formalize this learning problem, we begin by adapting the bags-of-marbles examples from the Hierarchical Models chapter. However, we now assume that the bag that each marble is drawn from is _unobserved_ and must be inferred.
"""

# ╔═╡ 0c0ad821-018e-414c-8562-40516ab13421
colours = [:blue, :green, :red]

# ╔═╡ fd8307d2-9199-4644-8f14-edc9347ccc9a
ϕ = OmegaExamples.Dirichlet(3, 1)

# ╔═╡ ae12287b-57b8-405e-b291-42de64255849
α = 0.1

# ╔═╡ 8ac90d6a-071c-4874-b232-8ca1dd88295b
prototype(i, ω) = (i ~ ϕ)(ω) .* α

# ╔═╡ 1982d646-d45d-4ab3-b613-2e514186891a
colour_probs(i, ω) = (i ~ OmegaExamples.Dirichlet(prototype(i, ω)))(ω)

# ╔═╡ 268507f9-581c-454d-8c4a-5f158f190be0
make_bag(i, ω) = (pget(colours) ∘ (i ~ Categorical((i ~ colour_probs)(ω))))(ω)

# ╔═╡ 7cef9d52-abcb-41f9-b0ea-f46a8407bc80
obs_to_bag = DiscreteUniform(1, 3) 

# ╔═╡ 244c8a12-0241-4229-acaf-b5285add43c3
obs_fn(data) = 
	ω -> all(map(i -> make_bag(obs_to_bag(i, ω), ω) == data[i], 1:length(data)))

# ╔═╡ 010c18fa-af74-45ab-859b-1cd75f5c48f3
obs = [:red, :red, :blue, :blue, :red, :blue]

# ╔═╡ 6f33bc95-e348-404e-ac77-1ad928cbedc4
same_bag_1and2 = ((1 ~ obs_to_bag) ==ₚ (2 ~ obs_to_bag)) |ᶜ obs_fn(obs)

# ╔═╡ de573730-2626-4180-994a-8eac595e8986
same_bag_1and3 = ((1 ~ obs_to_bag) ==ₚ (3 ~ obs_to_bag)) |ᶜ obs_fn(obs)

# ╔═╡ 8ad0bfec-192e-4d8a-b646-47001b3cebb9
viz(randsample(same_bag_1and2, 1000))

# ╔═╡ c3b3ed66-4be0-4bc0-ba90-e480fd59cb27
viz(randsample(same_bag_1and3, 1000))

# ╔═╡ ee296542-36b6-4542-8f5d-35ab7105270c
md"""
We see that it is likely that observations `1` and `2` came from the same bag, but quite unlikely that `3` did. Why? Notice that we have set `α` small, indicating a belief that the marbles in a bag will tend to all be the same color. How do the results change if you make `α` larger? Why? Note that we have queried on whether observed marbles came out of the same bag, instead of directly querying on the bag number that an observation came from. This is because the bag number by itself is meaningless—it is only useful in its role of determining which objects have similar properties. Formally, the model we have defined above is symmetric in the bag labels (if you permute all the labels you get a new state with the same probability).

Instead of assuming that a marble is equally likely to come from each bag, we could instead learn a distribution over bags where each bag has a different probability. This is called a _mixture distribution_ over the bags:
"""

# ╔═╡ ae0a9675-f9b6-44c0-8ea9-f71ed06a02e0
# the probability that an observation will come from each bag:
bag_mixture = OmegaExamples.Dirichlet(3, 1)

# ╔═╡ 9aa43d24-1136-481c-8c69-a5705f1e189e
obs_to_bag_mix(i, ω) = (i~ Categorical((i~ bag_mixture)(ω)))(ω)

# ╔═╡ eb7a3c55-535c-4a5d-9b04-117f3fef6f6d
obs_fn_mix(data) = 
	ω -> all(map(i -> make_bag(obs_to_bag_mix(i, ω), ω) == data[i], 1:length(data)))

# ╔═╡ 99517093-0f0d-4ab1-9d65-5f1fdd2df58f
same_bag_1and2_mix = 
	((1 ~ obs_to_bag_mix) ==ₚ (2 ~ obs_to_bag_mix)) |ᶜ obs_fn_mix(obs)

# ╔═╡ f7f2365a-88d2-4d55-ae2d-0627e8ec29df
same_bag_1and3_mix = 
	((1 ~ obs_to_bag_mix) ==ₚ (3 ~ obs_to_bag_mix)) |ᶜ obs_fn_mix(obs)

# ╔═╡ ab98a869-b2fc-4d1b-b08f-6e7426064ae5
viz(randsample(same_bag_1and2_mix, 1000))

# ╔═╡ 62375f29-fa4a-46a7-803d-001a3cfe620d
viz(randsample(same_bag_1and3_mix, 1000))

# ╔═╡ 470b8eab-cec3-4bf6-a7d6-9a6341c6ce94
md"""
Models of this kind are called **mixture models** because the observations are a “mixture” of several categories. Mixture models are widely used in modern probabilistic modeling because they describe how to learn the unobservable categories which underlie observable properties in the world.

The observation distribution associated with each mixture _component_ (i.e., kind or category) can be any distribution we like. For example, here is a mixture model with _Normal_ components:
"""

# ╔═╡ 491a0641-cc37-4c7f-9f86-bc4682f0d916
data = [(x = 1.5343898902525506, y = 2.3460878867298494),
	(x = 1.1810142951204246, y = 1.4471493362364427),
	(x = 1.3359476185854833, y = 0.5979097803077312),
	(x = 1.7461500236610696, y = 0.07441351219375836),
	(x = 1.1644280209698559, y = 0.5504283671279169),
	(x = 0.5383179421667954, y = 0.36076578484371535),
	(x = 1.5884794217838352, y = 1.2379018386693668),
	(x = 0.633910148716343, y = 1.21804947961078),
	(x = 1.3591395983859944, y = 1.2056207607743645),
	(x = 1.5497995798191613, y = 1.555239222467223),
	(x = -1.7103539324754713, y = -1.178368516925668),
	(x = -0.49690324128135566, y = -1.4482931166889297),
	(x = -1.0191455290951414, y = -0.4103273022785636),
	(x = -1.6127046244033036, y = -1.198330563419632),
	(x = -0.8146486481025548, y = -0.33650743701348906),
	(x = -1.2570582864922166, y = -0.7744102418371701),
	(x = -1.2635542813354101, y = -0.9202555846522052),
	(x = -1.3169953429184593, y = -0.40784942495184096),
	(x = -0.7409787028330914, y = -0.6105091049436135),
	(x = -0.7683709878962971, y = -1.0457286452094976)]

# ╔═╡ 64aa7273-6007-47d4-ab5a-880998785685
cat_mixture = @~ OmegaExamples.Dirichlet(2, 1)

# ╔═╡ 299145bf-7ea9-4f39-9acd-9637060065d2
obs_to_cat(i, ω) = (i ~ Categorical(cat_mixture(ω)))(ω)

# ╔═╡ 8eb77c33-8169-47b9-b416-6800109405c0
x_mean(i, ω) = ((@uid, i) ~ StdNormal{Float64}())(ω)

# ╔═╡ f7994479-1da7-40f1-a196-6e4c1c9fdb3b
y_mean(i, ω) = ((@uid, i) ~ StdNormal{Float64}())(ω)

# ╔═╡ c948561b-029e-4007-aa1a-36aec850cd23
cat_to_mean(i, ω) = (x_mean = x_mean(i, ω), y_mean = y_mean(i, ω))

# ╔═╡ c1816744-9a46-4814-8a93-4dcfdbb78c2e
function predictives(data, ω)
	for (i, d) in enumerate(data)
		mus = cat_to_mean(obs_to_cat(i, ω), ω)
		cond!(ω, (i ~ Normal(mus.x_mean, 0.01))(ω) ==ₛ d.x)
		cond!(ω, ((@uid, i) ~ Normal(mus.y_mean, 0.01))(ω) ==ₛ d.y)
	end
	return cat_to_mean(obs_to_cat(@uid, ω), ω)
end

# ╔═╡ 770bb220-7925-4a2d-ab60-1ca94641614b
randsample(ω -> predictives(data, ω), 100, alg = MH)

# ╔═╡ 12d9c66a-cd28-43ec-b86c-12e655c9e0d0
md"""
### Example: Categorical Perception of Speech Sounds
This example is adapted from [Feldman et al. (2009)](https://scholar.google.com/scholar?q=%22The%20influence%20of%20categories%20on%20perception%3A%20explaining%20the%20perceptual%20magnet%20effect%20as%20optimal%20statistical%20inference.%22).

Human perception is often skewed by our expectations. A common example of this is called _categorical perception_ – when we perceive objects as being more similar to the category prototype than they really are. In phonology this is been particularly important and is called the perceptual magnet effect: Hearers regularize a speech sound into the category that they think it corresponds to. Of course this category isn’t known a priori, so a hearer must be doing a simultaneous inference of what category the speech sound corresponded to, and what the sound must have been. In the below code we model this as a mixture model over the latent categories of sounds, combined with a noisy observation process.
"""

# ╔═╡ d3a1f8dd-7aa2-4c4d-a812-ebdc0dead7f8
prototype_1 = 0

# ╔═╡ 9d693700-2c40-43a6-9d6e-8270e2df3c0f
prototype_2 = 5

# ╔═╡ b7e81dfe-9750-44fc-a26e-b27451819b1b
stimuli = prototype_1 : 0.2 : prototype_2

# ╔═╡ 4fcbee01-2d18-49c4-8003-cac8ae98304d
vowel_1 = @~ Normal(prototype_1, 1)

# ╔═╡ 7a50fe56-9bfc-4e6a-8613-8f938336345f
vowel_2 = @~ Normal(prototype_2, 1)

# ╔═╡ e1e9e1af-6328-47f8-adb9-1844e13fbd0a
category = @~ Bernoulli()

# ╔═╡ e57b870d-a7e8-4472-8b18-d71c5c407e9c
value = ifelseₚ(category, vowel_1, vowel_2)

# ╔═╡ 2ffd7b5a-245a-4204-bf34-94fb14c1c428
perceived_value = value |ᶜ (manynth(Normal(value, 1), 1:length(stimuli)) ==ₚ stimuli)

# ╔═╡ 78485aca-9668-45c7-be64-f2d0a16fb1f2
scatterplot(stimuli, randsample(perceived_value, length(stimuli), alg = MH))

# ╔═╡ 1c82d195-a6dd-4574-aa04-e02d4d48f720
md"Notice that the perceived distances between input sounds are skewed relative to the actual acoustic distances – that is they are attracted towards the category centers."

# ╔═╡ b102b7ce-7883-41fa-b527-2f1a45b2af48
plot(load("Pme.png"))

# ╔═╡ 2e54ad82-4e4d-4667-901e-d3f4ce010b10
md"""
### Example: Topic Models
One very popular class of mixture-based approaches are _topic models_, which are used for document classification, clustering, and retrieval. The simplest kind of topic models make the assumption that documents can be represented as _bags of words_ — unordered collections of the words that the document contains. In topic models, each document is associated with a mixture over _topics_, each of which is itself a distribution over words. (Sometimes models like this, where the observations are a mixture of different mixtures is called an _admixture_ model.)

One popular kind of bag-of-words topic model is known as _Latent Dirichlet Allocation_ (LDA, [Blei et al. (2003)](https://scholar.google.com/scholar?q=%22Latent%20dirichlet%20allocation%22)). The generative process for this model can be described as follows. For each document, mixture weights over a set of $K$ topics are drawn from a Dirichlet prior. Then $N$ topics are sampled for the document—one for each word. Each topic itself is associated with a distribution over words, and this distribution is drawn from a Dirichlet prior. For each of the $N$ topics drawn for the document, a word is sampled from the corresponding multinomial distribution. This is shown in the code below.
"""

# ╔═╡ 16ad44df-0819-443c-abf2-413207f2dda5
vocabulary = ["DNA", "evolution", "parsing", "phonology"]

# ╔═╡ 9688746c-b11d-4fb6-b644-1fa9d6ee6079
η = ones(Int64, length(vocabulary))

# ╔═╡ 26d9297a-6547-429c-972b-616e59106aa5
num_topics = 2

# ╔═╡ 19bb570d-0a07-43cd-bc06-92901998d45e
alpha = ones(Int64, num_topics)

# ╔═╡ 1c21d989-9b6b-41f3-b802-9d618b13aeb9
corpus = split.([
	"DNA evolution DNA evolution DNA evolution DNA evolution DNA evolution",
  "DNA evolution DNA evolution DNA evolution DNA evolution DNA evolution",
  "DNA evolution DNA evolution DNA evolution DNA evolution DNA evolution",
  "parsing phonology parsing phonology parsing phonology parsing phonology parsing phonology",
  "parsing phonology parsing phonology parsing phonology parsing phonology parsing phonology",
  "parsing phonology parsing phonology parsing phonology parsing phonology parsing phonology"
])

# ╔═╡ 5bbef8f3-afd0-4545-ba56-19e94ce6166b
topics = map(i -> (ω -> (i~ OmegaExamples.Dirichlet(η))(ω)), 1:num_topics)

# ╔═╡ bcec4fab-5c28-49c6-988f-d252d0d3a505
topic_dist(i, ω) = (i~ OmegaExamples.Dirichlet(alpha))(ω)

# ╔═╡ dc3bf647-9e0f-4719-9ac2-72502b97939d
z(i, ω) = (i~ Categorical((i~topic_dist)(ω)))(ω)

# ╔═╡ 40f0558e-3239-47fe-8e14-c7707cd31235
topic(i, ω) = topics[(i~z)(ω)](ω)

# ╔═╡ 5e6805ca-872d-454e-85fe-4f58d2fa8997
rand_doc(doc) = 
manynth((i, ω) -> (pget(vocabulary) ∘ (i~Categorical(topic(i, ω))))(ω), 1:length(doc))

# ╔═╡ 474e8b12-2171-4574-a9d2-8b4fbfc6e359
evidence(ω) = map(doc -> (rand_doc(doc) ==ₚ doc)(ω), corpus)

# ╔═╡ 68657786-6afa-45d5-8c22-7f30881b4617
model = (ω -> mapf(ω, topics)) |ᶜ (all ∘ evidence)

# ╔═╡ c55f67c0-6504-4371-807d-9b3543286bb3
results = randsample(model, 1000, alg = MH)

# ╔═╡ bea4dd18-f686-4e16-86c9-86e9b3c0ecd0
barplot(vocabulary, map(x -> mean(results[1][x]), 1:4))

# ╔═╡ ddac7295-ef47-477a-8c3c-d08c583fd026
barplot(vocabulary, map(x -> mean(results[2][x]), 1:4))

# ╔═╡ 8aabbc7b-3f85-4986-a196-3b12800cd68e
md"""
In this simple example, there are two topics `1` and `2`, and four words. These words are deliberately chosen to represent one of two possible subjects that a document can be about: One can be thought of as ‘biology’ (i.e., `DNA` and `evolution`), and the other can be thought of as ‘linguistics’ (i.e., `parsing` and `syntax`).

The documents consist of lists of individual words from one or the other topic. Based on the co-occurrence of words within individual documents, the model is able to learn that one of the topics should put high probability on the biological words and the other topic should put high probability on the linguistic words. It is able to learn this because different kinds of documents represent stable mixture of different kinds of topics which in turn represent stable distributions over words.

### Unknown Numbers of Categories
The models above describe how a learner can simultaneously learn which category each object belongs to, the typical properties of objects in that category, and even global parameters about kinds of objects in general. However, it suffers from a serious flaw: the number of categories was fixed. This is as if a learner, after finding out there are cats, dogs, and mice, must force an elephant into one of these categories, for want of more categories to work with.

The simplest way to address this problem, which we call _unbounded_ models, is to simply place uncertainty on the number of categories in the form of a hierarchical prior. Let’s warm up with a simple example of this: inferring whether one or two coins were responsible for a set of outcomes (i.e. imagine a friend is shouting each outcome from the next room–“heads, heads, tails…”–is she using a fair coin, or two biased coins?).
"""

# ╔═╡ 4323e9ab-e79f-4b88-a707-3aede0c1fb69
observed_data = [true, true, true, true, false, false, false, false]
# observed_data = [true, true, true, true, true, true, true, true]

# ╔═╡ 1e20218c-52db-4831-a964-a18fdfdb3661
coins = ifelseₚ((@~Bernoulli()), 1, [1, 2])

# ╔═╡ dd952ba1-5f28-409a-9266-246d2bdb6d02
coin_to_weight = StdUniform{Float64}()

# ╔═╡ 8a8886f8-17d3-4ff3-adda-5a8411a6e3b3
rand_obs(i, ω) = 
	(i~Bernoulli(((i ~ UniformDraw(coins(ω)))(ω) ~ coin_to_weight)(ω)))(ω)

# ╔═╡ ef1f7ba1-afda-4a6a-8596-da00e2812d56
coins_cond = 
	(length ∘ coins) |ᶜ (manynth(rand_obs, 1:length(observed_data)) ==ₚ observed_data)

# ╔═╡ 89909e7e-df47-46a5-a761-6c1628b5c792
# viz(randsample(coins_cond, 1000))

# ╔═╡ 0e7b1579-ebb3-4591-b66a-1f7c967d3557
md"""
How does the inferred number of coins change as the amount of data grows? Why? (Note that we have used the `RejectionSampling` inference method. Inference in unbounded mixture models can be very tricky because a different choice of dimensionality leads to different options for the category of each observation. For instance, in the case of Metropolis-Hastings this means that proposals to reduce the number of categories are almost always rejected – mixing is impossibly slow.)

We could extend this model by allowing it to infer that there are more than two coins. However, no evidence requires us to posit three or more coins (we can always explain the data as “a heads coin and a tails coin”). Instead, let us apply the same idea to the marbles examples above:
"""

# ╔═╡ 8250610d-89e5-415f-a9db-77ccb57bc543
observed_marbles = [:red, :red, :blue, :blue, :red, :blue]

# ╔═╡ b3839bbc-3c19-47f9-90ae-74e0ecaf3ff8
num_bags(ω) = (1 + (@~ Poisson(1))(ω))

# ╔═╡ acbefcd3-ec58-4525-a9df-c9722ba5f0bb
bags(i, ω) = (i~ UniformDraw(1:num_bags(ω)))(ω)

# ╔═╡ 87b1041a-4f24-4404-9cd7-b0a60fac8433
num_bags_cond = 
	num_bags |ᶜ (manynth(bags, 1:length(observed_marbles)) ==ₚ observed_marbles)

# ╔═╡ 8ab0c943-1d93-45b4-add2-445dfcf759d4
# viz(randsample(num_bags_cond, 1000))

# ╔═╡ 48ba2f1b-6737-4382-af54-b7131a42d4e5
md"""
Vary the amount of evidence and see how the inferred number of bags changes.

For the prior on `num_bags` we used the [_Poisson distribution_](https://en.wikipedia.org/wiki/Poisson_distribution) which is a distribution on non-negative integers. It is convenient, though implies strong prior knowledge (perhaps too strong for this example).

### Infinite mixtures
Unbounded models give a straightforward way to represent uncertainty over the number of categories in the world. However, inference in these models often presents difficulties. An alternative is to use _infinite_ mixture models. In an unbounded model, there are a finite number of categories whose number is drawn from an unbounded prior distribution, such as the Poisson prior that we just examined. In an infinite model we assume an _infinite number_ of categories (most not yet observed).

To understand how we can work with an infinite set of categories in a finite computer, let’s first revisit the Discrete distribution.

In Omega the categorical distribution is a random class, e.g. `Categorical([0.2, 0.3, 0.1, 0.4])`. If it wasn’t built-in and the only primitive random class you could use was `Bernoulli`, how could you sample from it? One solution is to recursively walk down the list of probabilities, deciding whether to stop on each step. For instance, in `Categorical([0.2, 0.3, 0.1, 0.4])` there is a $0.2$ probability of stopping on the first trial, a $0.3/0.8$ probability of stopping on the second (given that we didn’t stop on the first), and so on. We can start by turning the list of probabilities into a list of residual probabilities—the probability we will stop on each step, given that we haven’t stopped yet:
"""

# ╔═╡ ed4117b4-1a36-4857-8157-6f5320d97d7a
function categorical(probs, ω)
	@assert (sum(probs) ≈ 1) "probs is not a probability vector"
	residuals = [probs[1]]
	for i in 2:length(probs)
		push!(residuals, probs[i]/(1 - sum(probs[1:i-1])))
	end
	residuals[end] = 1
	b(ω, k) = (k ~ Bernoulli(residuals[k]))(ω)
	for k in 1:length(probs)
		return b(ω, k) ? k : continue
	end
end

# ╔═╡ c38e8b84-22f2-42fa-bd2a-cba3f63772e9
viz(randsample(ω -> categorical([0.2, 0.3, 0.1, 0.4], ω), 1000))

# ╔═╡ 1b88a8e5-0aca-4d7e-9752-8047aaf528f8
md"In the above mixture model examples, we generally expressed uncertainty about the probability of each category by putting a Dirichlet prior on the probabilities passed to a Categorical distribution:"

# ╔═╡ 5e01a71d-b73f-480e-88d9-479b6f4c73d7
probs_dirichlet = @~ OmegaExamples.Dirichlet(4, 1)

# ╔═╡ a047f972-0ef9-4268-b615-9c19f2b5d5d0
viz(randsample(ω -> categorical(probs_dirichlet(ω), ω), 1000))

# ╔═╡ 901a968b-dda4-4ba5-8e93-7159d3fb921d
md"""
It makes sense to sample the residuals directly. Since we know that the residual probability is simply a number between $0$ and $1$, we could do something like:
"""

# ╔═╡ 7df6f3e0-7560-47ff-81f4-41556ca94c6c
residuals(ω) = vcat(manynth(Beta(1, 1), 1:3)(ω), 1)

# ╔═╡ edba6c2f-43c3-417a-83dc-86e0c5257555
categorical_(resid, ω, i = 1) = 
	(i~ Bernoulli(resid[i]))(ω) ? i : categorical_(resid, ω, i + 1)

# ╔═╡ deac94d2-60eb-4283-b655-d266c75ff018
viz(randsample(ω -> categorical_(residuals(ω), ω), 1000))

# ╔═╡ 7bfb2857-cd7b-4211-88c4-edfead394b62
md"""
Notice that we have added a final residual probability of $1$ to the array of residuals. This is to make sure we stop at the end! It is kind of ugly, though, and breaks the symmetry between the final number and the ones before. After staring at the above code you might have an idea: why bother stopping? If we had an infinite set of residual probs we could still call `categorical_`, and we would eventually stop each time. We can get the effect of an infinite set by using independent `Beta` distributions to only construct a particular value when we need it:
"""

# ╔═╡ 9b6dce2c-6dd4-4686-871f-ba7998e9f807
residuals_ = (@~ Beta(1, 1)) 

# ╔═╡ 59e8f2ae-a875-4b00-9b55-3ca08e1169cd
categorical_inf(ω, i = 1) =
	(i~ Bernoulli(residuals_(ω)))(ω) ? i : categorical_inf(ω, i+1)

# ╔═╡ 0bff4d01-c4e1-458a-940d-a9c27a1149d7
itr =  randsample(categorical_inf, 1000);

# ╔═╡ fb91f3f9-a76d-40e4-8e07-1bc3d9437b34
barplot(1:maximum(itr), map(k -> count(x -> x == k, itr), 1:maximum(itr)))

# ╔═╡ 56e72004-fc58-4792-af54-00e5c6220c2a
md"""
We’ve just constructed an infinite analog of the Dirichlet-Discrete pattern, it is called a _Dirichlet Process_ (DP, more technically this is a GEM: a DP over integers). We have derived the DP by generalizing the Discrete distribution, but we’ve arrived at something that also looks like a Geometric distribution with heterogeneous stopping probabilities, which is an alternative derivation.

We can use the DP to construct an _infinite mixture model_:
"""

# ╔═╡ d1acfb54-bd5d-4ba0-92ba-ac1b118e6e28
colors = [:blue, :red, :green]

# ╔═╡ 6049d848-24d0-41a4-b41f-afb1669f9a91
obs_marbles = [:red, :blue, :red, :blue, :red, :blue]

# ╔═╡ 06945ce0-327b-422b-9c16-9329d68b4d7d
phi = OmegaExamples.Dirichlet(3, 1)

# ╔═╡ 9cd9fc1f-1d19-4d33-b3e3-02f529789f1d
α_ = 0.1

# ╔═╡ 0ec270e8-c3c7-4f2f-b8f7-d50100494c13
prototype_inf(i, ω) = α_ .* phi(i, ω)

# ╔═╡ dbba9fa2-7abb-4f75-98eb-39c4e25d3a2e
function make_bag_inf(i, ω)
	colour_probs = (i~ OmegaExamples.Dirichlet(prototype_inf(i, ω)))(ω)
	(pget(colors) ∘ (i~ Categorical(colour_probs)))(ω)
end

# ╔═╡ 65a3c717-7720-4643-9bd0-c7d7329ee603
get_bag_inf(i, ω, k = 1) = 
	((i, k) ~ Bernoulli(residuals_(ω)))(ω) ? k : get_bag_inf(i, ω, k+1)

# ╔═╡ 33fec097-ac33-4223-a4ff-7c39100d8faf
obs_fn_inf(data) = 
	ω -> all(map(i -> make_bag_inf(get_bag_inf(i, ω), ω) == data[i], 1:length(data)))

# ╔═╡ 4c21efb6-f851-4ba7-8ffb-1caf3c44421b
same_bag_12 = 
	((1 ~ get_bag_inf) ==ₚ (2 ~ get_bag_inf)) |ᶜ obs_fn_inf(obs_marbles)

# ╔═╡ 4f4c6dcf-49ed-4f9a-88f0-82ded6bf9851
same_bag_13 = 
	((1 ~ get_bag_inf) ==ₚ (3 ~ get_bag_inf)) |ᶜ obs_fn_inf(obs_marbles)

# ╔═╡ 50a731ab-6221-4d49-8231-ee6f0ffa125e
viz(randsample(same_bag_12, 20))

# ╔═╡ b461d87b-ff77-4211-9813-d7cbec0461c5
viz(randsample(same_bag_13, 10))

# ╔═╡ 56095cc7-03e2-42a6-838b-106281e18be2
md"""
Like the unbounded mixture above, there are an infinite set of possible catgories (here, bags). Unlike the unbounded mixture model the number of bags is never explicitly constructed. Instead, the set of categories is thought of as an infinite set; because they are constructed as needed only a finite number will ever be explicitly constructed. (Technically, these models are called infinite because the expected number of categories used goes to infinity as the number of observations goes to infinity.)
"""

# ╔═╡ Cell order:
# ╠═cecc21c0-7ab0-11ec-1952-459400f649e1
# ╟─2ed16474-67d8-4c3a-b0c4-4700a8ad8a18
# ╠═0c0ad821-018e-414c-8562-40516ab13421
# ╠═fd8307d2-9199-4644-8f14-edc9347ccc9a
# ╠═ae12287b-57b8-405e-b291-42de64255849
# ╠═8ac90d6a-071c-4874-b232-8ca1dd88295b
# ╠═1982d646-d45d-4ab3-b613-2e514186891a
# ╠═268507f9-581c-454d-8c4a-5f158f190be0
# ╠═7cef9d52-abcb-41f9-b0ea-f46a8407bc80
# ╠═244c8a12-0241-4229-acaf-b5285add43c3
# ╠═010c18fa-af74-45ab-859b-1cd75f5c48f3
# ╠═6f33bc95-e348-404e-ac77-1ad928cbedc4
# ╠═de573730-2626-4180-994a-8eac595e8986
# ╠═8ad0bfec-192e-4d8a-b646-47001b3cebb9
# ╠═c3b3ed66-4be0-4bc0-ba90-e480fd59cb27
# ╟─ee296542-36b6-4542-8f5d-35ab7105270c
# ╠═ae0a9675-f9b6-44c0-8ea9-f71ed06a02e0
# ╠═9aa43d24-1136-481c-8c69-a5705f1e189e
# ╠═eb7a3c55-535c-4a5d-9b04-117f3fef6f6d
# ╠═99517093-0f0d-4ab1-9d65-5f1fdd2df58f
# ╠═f7f2365a-88d2-4d55-ae2d-0627e8ec29df
# ╠═ab98a869-b2fc-4d1b-b08f-6e7426064ae5
# ╠═62375f29-fa4a-46a7-803d-001a3cfe620d
# ╟─470b8eab-cec3-4bf6-a7d6-9a6341c6ce94
# ╠═491a0641-cc37-4c7f-9f86-bc4682f0d916
# ╠═64aa7273-6007-47d4-ab5a-880998785685
# ╠═299145bf-7ea9-4f39-9acd-9637060065d2
# ╠═8eb77c33-8169-47b9-b416-6800109405c0
# ╠═f7994479-1da7-40f1-a196-6e4c1c9fdb3b
# ╠═c948561b-029e-4007-aa1a-36aec850cd23
# ╠═c1816744-9a46-4814-8a93-4dcfdbb78c2e
# ╠═770bb220-7925-4a2d-ab60-1ca94641614b
# ╟─12d9c66a-cd28-43ec-b86c-12e655c9e0d0
# ╠═d3a1f8dd-7aa2-4c4d-a812-ebdc0dead7f8
# ╠═9d693700-2c40-43a6-9d6e-8270e2df3c0f
# ╠═b7e81dfe-9750-44fc-a26e-b27451819b1b
# ╠═4fcbee01-2d18-49c4-8003-cac8ae98304d
# ╠═7a50fe56-9bfc-4e6a-8613-8f938336345f
# ╠═e1e9e1af-6328-47f8-adb9-1844e13fbd0a
# ╠═e57b870d-a7e8-4472-8b18-d71c5c407e9c
# ╠═2ffd7b5a-245a-4204-bf34-94fb14c1c428
# ╠═78485aca-9668-45c7-be64-f2d0a16fb1f2
# ╟─1c82d195-a6dd-4574-aa04-e02d4d48f720
# ╟─b102b7ce-7883-41fa-b527-2f1a45b2af48
# ╟─2e54ad82-4e4d-4667-901e-d3f4ce010b10
# ╠═16ad44df-0819-443c-abf2-413207f2dda5
# ╠═9688746c-b11d-4fb6-b644-1fa9d6ee6079
# ╠═26d9297a-6547-429c-972b-616e59106aa5
# ╠═19bb570d-0a07-43cd-bc06-92901998d45e
# ╠═1c21d989-9b6b-41f3-b802-9d618b13aeb9
# ╠═5bbef8f3-afd0-4545-ba56-19e94ce6166b
# ╠═bcec4fab-5c28-49c6-988f-d252d0d3a505
# ╠═dc3bf647-9e0f-4719-9ac2-72502b97939d
# ╠═40f0558e-3239-47fe-8e14-c7707cd31235
# ╠═5e6805ca-872d-454e-85fe-4f58d2fa8997
# ╠═474e8b12-2171-4574-a9d2-8b4fbfc6e359
# ╠═68657786-6afa-45d5-8c22-7f30881b4617
# ╠═c55f67c0-6504-4371-807d-9b3543286bb3
# ╠═bea4dd18-f686-4e16-86c9-86e9b3c0ecd0
# ╠═ddac7295-ef47-477a-8c3c-d08c583fd026
# ╟─8aabbc7b-3f85-4986-a196-3b12800cd68e
# ╠═4323e9ab-e79f-4b88-a707-3aede0c1fb69
# ╠═1e20218c-52db-4831-a964-a18fdfdb3661
# ╠═dd952ba1-5f28-409a-9266-246d2bdb6d02
# ╠═8a8886f8-17d3-4ff3-adda-5a8411a6e3b3
# ╠═ef1f7ba1-afda-4a6a-8596-da00e2812d56
# ╠═89909e7e-df47-46a5-a761-6c1628b5c792
# ╟─0e7b1579-ebb3-4591-b66a-1f7c967d3557
# ╠═8250610d-89e5-415f-a9db-77ccb57bc543
# ╠═b3839bbc-3c19-47f9-90ae-74e0ecaf3ff8
# ╠═acbefcd3-ec58-4525-a9df-c9722ba5f0bb
# ╠═87b1041a-4f24-4404-9cd7-b0a60fac8433
# ╠═8ab0c943-1d93-45b4-add2-445dfcf759d4
# ╟─48ba2f1b-6737-4382-af54-b7131a42d4e5
# ╠═ed4117b4-1a36-4857-8157-6f5320d97d7a
# ╠═c38e8b84-22f2-42fa-bd2a-cba3f63772e9
# ╟─1b88a8e5-0aca-4d7e-9752-8047aaf528f8
# ╠═5e01a71d-b73f-480e-88d9-479b6f4c73d7
# ╠═a047f972-0ef9-4268-b615-9c19f2b5d5d0
# ╟─901a968b-dda4-4ba5-8e93-7159d3fb921d
# ╠═7df6f3e0-7560-47ff-81f4-41556ca94c6c
# ╠═edba6c2f-43c3-417a-83dc-86e0c5257555
# ╠═deac94d2-60eb-4283-b655-d266c75ff018
# ╟─7bfb2857-cd7b-4211-88c4-edfead394b62
# ╠═9b6dce2c-6dd4-4686-871f-ba7998e9f807
# ╠═59e8f2ae-a875-4b00-9b55-3ca08e1169cd
# ╠═0bff4d01-c4e1-458a-940d-a9c27a1149d7
# ╠═fb91f3f9-a76d-40e4-8e07-1bc3d9437b34
# ╟─56e72004-fc58-4792-af54-00e5c6220c2a
# ╠═d1acfb54-bd5d-4ba0-92ba-ac1b118e6e28
# ╠═6049d848-24d0-41a4-b41f-afb1669f9a91
# ╠═06945ce0-327b-422b-9c16-9329d68b4d7d
# ╠═9cd9fc1f-1d19-4d33-b3e3-02f529789f1d
# ╠═0ec270e8-c3c7-4f2f-b8f7-d50100494c13
# ╠═dbba9fa2-7abb-4f75-98eb-39c4e25d3a2e
# ╠═65a3c717-7720-4643-9bd0-c7d7329ee603
# ╠═33fec097-ac33-4223-a4ff-7c39100d8faf
# ╠═4c21efb6-f851-4ba7-8ffb-1caf3c44421b
# ╠═4f4c6dcf-49ed-4f9a-88f0-82ded6bf9851
# ╠═50a731ab-6221-4d49-8231-ee6f0ffa125e
# ╠═b461d87b-ff77-4211-9813-d7cbec0461c5
# ╟─56095cc7-03e2-42a6-838b-106281e18be2
