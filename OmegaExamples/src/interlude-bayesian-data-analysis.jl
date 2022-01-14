### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 71c84094-44f5-495b-b627-e09c880183a0
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    using Omega, Distributions, UnicodePlots, OmegaExamples
end

# ╔═╡ 3cbb6cf1-07b9-4706-a178-c370096ea159
md"""
Inference by conditioning a generative model is a basic building block of Bayesian statistics. In cognitive science this tool can be used in two ways. If the generative model is a hypothesis about a person’s model of the world, then we have a Bayesian _cognitive model_. If the generative model is instead the scientist’s model of how the data are generated, then we have _Bayesian data analysis_. Bayesian data analysis can be an extremely useful tool to us as scientists, when we are trying to understand what our data mean about psychological hypotheses. This can become confusing: a particular modeling assumption can be something we hypothesize that people assume about the world, or can be something that we as scientists want to assume (but don’t assume that people assume). A pithy way of saying this is that we can make assumptions about “Bayes in the head” (Bayesian cognitive models) or about “Bayes in the notebook” (Bayesian data analysis).

Bayesian data analysis (BDA) is a general-purpose approach to making sense of data. A BDA model is an explicit hypotheses about the generative process behind the experimental data – where did the observed data come from? For instance, the hypothesis that data from two experimental conditions came from two _different_ distributions. After making explicit hypotheses, Bayesian inference can be used to invert the model: go from experimental data to updated beliefs about the hypotheses.
"""

# ╔═╡ dc117328-a880-48b2-a363-7fd1ae20d6d6
md"""
# Parameters and predictives
In a BDA model the random variables are usually called parameters. Parameters can be of theoretical interest, or not (the latter are called nuisance parameters). Parameters are in general unobservable (or, “latent”), so we must infer them from observed data. We can also go from updated beliefs about parameters to expectations about future data, so call _posterior predictives_.

For a given Bayesian model (together with data), there are four conceptually distinct distributions we often want to examine. For parameters, we have priors and posteriors:
* The _prior distribution_ over parameters captures our initial state of knowledge (or beliefs) about the values that the latent parameters could have, before seeing the data.
* The _posterior distribution_ over parameters captures what we know about the latent parameters having updated our beliefs with the evidence provided by data.

From either the prior or the posterior over parameters we can then run the model forward, to get predictions about data sets:

* The prior predictive distribution tells us what data to expect, given our model and our initial beliefs about the parameters. The prior predictive is a distribution over data, and gives the relative probability of different observable outcomes before we have seen any data.
* The posterior predictive distribution tells us what data to expect, given the same model we started with, but with beliefs that have been updated by the observed data. The posterior predictive is a distribution over data, and gives the relative probability of different observable outcomes, after some data has been seen.
Loosely speaking, _predictive_ distributions are in “data space” and _parameter_ distributions are in “latent parameter space”.

### Example: Election surveys
Imagine you want to find out how likely Candidate A is to win an election. To do this, you will try to estimate the proportion of eligible voters in the United States who will vote for Candidate A in the election. Trying to determine directly how many (voting age, likely to vote) people prefer Candidate A vs. Candidate B would require asking over 100 million people (it’s estimated that about 130 million people voted in the US Presidential Elections in 2008 and 2012). It’s impractical to measure the whole distribution. Instead, pollsters measure a sample (maybe ask 1000 people), and use that to draw conclusions about the “true population proportion” (an unobservable parameter).

Here, we explore the result of an experiment with 20 trials and binary outcomes (“will you vote for Candidate A or Candidate B?”).
"""

# ╔═╡ 52cf5e5b-3f3d-4361-bec3-78a1b817e3cb
begin
	## observed data
	k = 1  # number of people who support candidate A
    n = 20 # number of people asked
end

# ╔═╡ 88c450fc-1930-4529-9259-dd22d721953f
p = @~ Uniform(0, 1) # true population proportion who support candidate A

# ╔═╡ ffddd0ab-0745-400a-8191-bdd2a4ecdfef
# recreate model structure, without conditioning
prior_predictive(ω) = (@~ Binomial(n, p(ω)))(ω) 

# ╔═╡ 3ac23e10-3340-45f2-93ff-1387d9d5c824
viz(randsample(prior_predictive, 1000))

# ╔═╡ db1b173c-f2d4-4fd1-bd26-d526f3f8c33b
# Observed k people support "A" 
# Assuming each person's response is independent of each other
posterior_predictive = p |ᶜ ((ω -> (@~ Binomial(n, p(ω)))(ω)) ==ₚ k)

# ╔═╡ bcd64b7e-e9bd-4f94-a609-0b3e573cdfc3
posterior_predictive_samples = randsample(posterior_predictive, 1000)

# ╔═╡ b24b3c1d-c74b-4c43-912a-7c2d181996ac
viz(posterior_predictive_samples)

# ╔═╡ bca6e816-8c92-4ce9-802c-3e6061fcb8f9
md"""
What can we conclude intuitively from examining these plots? First, because prior differs from posterior, the evidence has changed our beliefs. Second, the posterior predictive assigns quite high probability to the true data, suggesting that the model considers the data “reasonable”. Finally, after observing the data, we conclude the true proportion of people supporting Candidate A is quite low – around $0.09$, or anyhow somewhere between $0.0$ and $0.15$. Check your understanding by trying other data sets, varying both `k` and `n`.
"""

# ╔═╡ ae20e3db-1f78-4486-b31e-edad3ef51d8a
md"""
## Quantifying claims about parameters

How can we quantify a claim like “the true parameter is low”? One possibility is to compute the mean or expected value of the parameter, which is mathematically given by $∫x⋅p(x)dx$ for a posterior distribution $p(x)$. Thus in the above election example we could:
"""

# ╔═╡ 8c7d9c67-f95d-46b2-96cd-3f5c31cfe2bf
mean(posterior_predictive_samples)

# ╔═╡ 1b86689b-b6c3-47af-b73b-7cd6ef56c3d3
md"""
This tells us that the mean is about $0.09$. This can be a very useful way to summarize a posterior, but it eliminates crucial information about how _confident_ we are in this mean. A coherent way to summarize our confidence is by exploring the probability that the parameter lies within a given interval. Conversely, an interval that the parameter lies in with high probability (say $90\%$) is called a _credible interval_ (CI). Let’s explore credible intervals for the parameter in the above model:
"""

# ╔═╡ 4d54b1ef-b1ab-492a-a164-f5dfd7ac7bcb
mean(0.01 .< posterior_predictive_samples .< 0.18)

# ╔═╡ ddcefc32-42c0-4a83-a1c9-f26532d9b0ad
md"""
Here we see that $[0.01, 0.18]$ is an (approximately) $90\%$ credible interval – we can be about $90\%$ sure that the true parameter lies within this interval. Notice that the $90\%$ CI is not unique. There are different ways to choose a particular CI. One particularly common, and useful, one is the Highest Density Interval (HDI), which is the smallest interval achieving a given confidence. (For unimodal distributions the HDI is unique and includes the mean.)

Here is a quick way to approximate the HDI of a distribution:
"""

# ╔═╡ 0be7a6b1-886d-4440-8802-999af903bef1
cred(d, low, up) = mean(low .< d .< up)

# ╔═╡ c65d7c12-ff8f-4fbf-baaa-d2f142d66602
function find_HDI(targetp, d, low, up, eps)
	if cred(d, low, up) < targetp
		return [low, up]
	end
	y = cred(d, low + eps, up)
	z = cred(d, low, up - eps)
	return (y > z) ? 
	find_HDI(targetp,d,low+eps,up,eps) : find_HDI(targetp,d,low,up-eps,eps)
end

# ╔═╡ a5a247e0-7132-4fe3-8f35-3fbedf8fc858
md"To test the function -"

# ╔═╡ 7b44c10b-a12f-4274-a9a9-5caa6c3649d0
x = @~ Normal(0, 1)

# ╔═╡ b2861324-d7f0-426b-9cb5-2df784597777
samples = randsample(x |ᶜ (x >ₚ 0), 1000)

# ╔═╡ bd180618-0e37-45f9-bdd1-18c2746c532e
find_HDI(0.95, samples, -10, 10, 0.1)

# ╔═╡ 5f1ee809-914b-499e-9062-06af5c73456e
md"Credible intervals are related to, but shouldn’t be mistaken for the confidence intervals that are often used in frequentist statistics. (And these confidence intervals themselves should definitely not be confused with p-values….)"

# ╔═╡ 1aded1ad-3e41-47f8-89ee-9e852c9603ee
md"""
### Example: logistic regression
Now imagine you are a pollster who is interested in the effect of age on voting tendency. You run the same poll, but you are careful to recruit people in their 20’s, 30’s, etc. We can analyze this data by assuming there is an underlying linear relationship between age and voting tendency. However since our data are Boolean (or if we aggregate, the count of people in each age group who will vote for candidate A), we must use a function to link from real numbers to the range $[0,1]$. The logistic function is a common way to do so.
"""

# ╔═╡ 43944860-c1ee-48bb-a3a6-39b768065306
data = [(age = 20, n = 20, k = 1),
	(age = 30, n = 20, k = 5),
	(age = 40, n = 20, k = 17),
	(age = 50, n = 20, k = 18)
]

# ╔═╡ ebfa0d3e-c056-4fd2-9564-7e230a4d3c11
ages = map(d -> d.age, data)

# ╔═╡ 855a5f0c-f6ce-4ac5-8f6e-f935c2160cd4
logistic(x) = 1 / (1 + exp(-x))

# ╔═╡ dfa039a8-befb-4106-adb8-4f89bdb03519
a = @~ StdNormal{Float64}() # true effect of age

# ╔═╡ 8734a4d7-6349-47e4-a4bb-fca2685e0796
b = @~ StdNormal{Float64}() # true intercept

# ╔═╡ 63c901a7-3efb-414a-85b0-71bbbb1de894
bin(ω, n, age, a, b, i) = (i ~ Binomial(n, logistic(a(ω) * age + b(ω))))(ω)

# ╔═╡ 998a3439-2be5-4e2e-a7ad-ed11b8d17f62
evidence = pw(&, 
	((ω -> bin(ω, data[1].n, data[1].age, a, b, (@uid, 1))) ==ₚ data[1].k),
	((ω -> bin(ω, data[2].n, data[2].age, a, b, (@uid, 2))) ==ₚ data[2].k),
	((ω -> bin(ω, data[3].n, data[3].age, a, b, (@uid, 3))) ==ₚ data[3].k),
	((ω -> bin(ω, data[4].n, data[4].age, a, b, (@uid, 4))) ==ₚ data[4].k)
) # map gives the same variables for `bin`

# ╔═╡ fa5f280b-eb1b-483b-b7b9-05ef931b80a5
a_posterior = a |ᶜ evidence

# ╔═╡ 08cfd264-9969-4436-9af8-a1e5c342dc9e
b_posterior = b |ᶜ evidence

# ╔═╡ d9e93d06-0fab-4c44-89ba-f7ea17ddc908
posterior = @joint a_posterior b_posterior

# ╔═╡ 181a9dbf-550d-439e-a9f2-f67aae3fb992
viz_margnials(randsample(posterior, 1000, alg = MH))

# ╔═╡ 383f3eee-9fef-47ce-91b6-b4adbdea819b
md"""
Looking at the parameter posteriors we see that there seems to be an effect of age: the parameter `a` is greater than zero, so older people are more likely to vote for candidate A. But how well does the model really explain the data?

### Posterior prediction and model checking
The posterior predictive distribution describes what data you should expect to see, given the model you’ve assumed and the data you’ve collected so far. If the model is able to describe the data you’ve collected, then the model shouldn’t be surprised if you got the same data by running the experiment again. That is, the most likely data for your model after observing your data should be the data you observed. It is natural then to use the posterior predictive distribution to examine the descriptive adequacy of a model. If these predictions do not match the data already seen (i.e., the data used to arrive at the posterior distribution over parameters), the model is descriptively inadequate.

A common way to check whether the posterior predictive matches the data, imaginatively called a posterior predictive check, is to plot some statistics of your data vs the expectation of these statistics according to the predictive. Let’s do this for the number of votes in each age group:
"""

# ╔═╡ 01748bea-e5d6-4a2c-8597-7e65f3064eff
predictive = [
	ω -> (bin(ω, 20, 20, a_posterior, b_posterior, (@uid, @uid, 1)))
	ω -> (bin(ω, 20, 30, a_posterior, b_posterior, (@uid, @uid, 2)))
	ω -> (bin(ω, 20, 40, a_posterior, b_posterior, (@uid, @uid, 3)))
	ω -> (bin(ω, 20, 50, a_posterior, b_posterior, (@uid, @uid, 4)))
]

# ╔═╡ 349c946e-2f52-49f7-bd8a-46a8ff074dbd
posterior_samples = randsample.(predictive, 1000, alg = MH)

# ╔═╡ afeffccd-1473-470a-bbeb-5208b9dc7e95
ppstats = mean.(posterior_samples)

# ╔═╡ ddbcd835-0c10-4784-92a5-df574e0cbbfb
datastats = map(d -> d.k, data)

# ╔═╡ c474e003-9e02-49ed-94f9-726b09cde964
scatterplot(ppstats, datastats, marker = :xcross)

# ╔═╡ 06c7f3b6-2cc9-4f9f-990b-e6bd9b76f564
md"""
This scatter plot will lie on the $x=y$ line if the model completely accomodates the data. Looking closely at this plot, we see that there are a few differences between the data and the predictives. First, the predictions are compressed compared to the data. This is likely because the prior encourages moderate probabilities. Second, we see hints of non-linearity in the data that the model is not able to account for. This model is pretty good, but certainly not perfect, for explaining this data.

One final note: There is an important, and subtle, difference between a model’s ability to _accomodate_ some data and that model’s ability to _predict_ the data. This is roughly the difference between a posterior predictive check and a _prior_ predictive check.
"""

# ╔═╡ 35ab1400-8d03-4803-aae9-99fdf55526da
md"""
## Model selection
In the above examples, we’ve had a single data-analysis model and used the experimental data to learn about the parameters of the models and the descriptive adequacy of the models. Often as scientists, we are in fortunate position of having multiple, distinct models in hand, and want to decide if one or another is a better description of the data. The problem of _model selection_ given data is one of the most important and difficult tasks of BDA.

Returning to the simple election polling example above, imagine we begin with a (rather unhelpful) data analysis model that assumes each candidate is equally likely to win, that is `p=0.5`. We quickly notice, by looking at the posterior predictives, that this model doesn’t accommodate the data well at all. We thus introduce the above model where `p = @~ Uniform(0,1)`. How can we quantitatively decide which model is better? One approach is to combine the models into an uber model that decides which approach to take:
"""

# ╔═╡ 1ebcd990-9dfb-4fdc-954f-91bceeae12e8
begin
	# observed data
	k_ = 5 # number of people who support candidate A
	n_ = 20  # number of people asked
end

# ╔═╡ ebe8c2ad-a084-4aa8-9959-23d18a7dd783
# binary decision variable for which hypothesis is better
x_(ω) = (@~ Bernoulli())(ω) ? "simple" : "complex"

# ╔═╡ d5130e27-356a-4d32-8a40-4f487eab7a9f
p_(ω) = (x_(ω) == "simple") ? 0.5 : (@~ StdUniform{Float64}())(ω)

# ╔═╡ 24e1cd10-da09-4a5c-9e1f-55b34f1dcb2a
posterior_ = x_ |ᶜ ((ω ->  (@~ Binomial(n_, p_(ω)))(ω))==ₚ k_)

# ╔═╡ aae249b9-0ca1-4434-901b-d3961232ccc0
viz(randsample(posterior_, 1000))

# ╔═╡ eb0aa5b7-4735-4c7e-af23-8df237b1e7b9
md"""
We see that, as expected, the more complex model is preferred: we can confidently say that given the data the more complex model is the one we should believe. Further we can quantify this via the posterior probability of the complex model.

This model is an example from the classical hypothesis testing framework. We consider a model that fixes one of its parameters to a pre-specified value of interest (here $H₀:p=0.5$). This is sometimes referred to as a _null hypothesis_. The other model says that the parameter is free to vary. In the classical hypothesis testing framework, we would write: $H₁:p≠0.5$. With Bayesian hypothesis testing, we must be explicit about what $p$ is (not just what $p$ is not), so we write $H₁:p∼Uniform(0,1)$.

One might have a conceptual worry: Isn’t the second model just a more general case of the first model? That is, if the second model has a uniform distribution over $p$, then $p: 0.5$ is included in the second model. Fortunately, the posterior on models automatically penalizes the more complex model when it’s flexibility isn’t needed. (To verify this, set `k=10` in the example.) This idea is called the principle of parsimony or _Occam’s razor_, and will be discussed at length later. For now, it’s sufficient to know that more complex models will be penalized for being more complex, intuitively because they will be diluting their predictions. At the same time, more complex models are more flexible and can capture a wider variety of data (they are able to bet on more horses, which increases the chance that they will win some money). Bayesian model comparison lets us weigh these costs and benefits.
"""

# ╔═╡ ad26adcb-7974-4871-8efe-004b996dfae1
md"""
## Bayes’ factor
What we are plotting above are _posterior model probabilities_. These are a function of the marginal likelihoods of the data under each hypothesis and the prior model probabilities (here, defined to be equal: `Bernoulli(0.5)`). Sometimes, scientists feel a bit strange about reporting values that are based on prior model probabilities (what if scientists have different priors as to the relative plausibility of the hypotheses?) and so often report the ratio of marginal likelihoods, a quantity known as a _Bayes Factor_.

Let’s compute the Bayes’ Factor, by computing the likelihood of the data under each hypothesis.
"""

# ╔═╡ c240f715-68b8-4f77-a805-4ba024c9bd7a
simple_model = @~ Binomial(n_, 0.5)

# ╔═╡ 827c4019-205e-449c-b8db-34d6963748db
complex_model(ω) = (@~ Binomial(n_, (@~ StdUniform{Float64}())(ω)))(ω)

# ╔═╡ 29a88d50-02c8-481c-9099-5e83b70e3414
# simple_likelihood = logpdf(simple_model, k_)

# ╔═╡ 05d090dd-9834-4794-bd06-43ae8837ef8b
# complex_likelihood = logpdf(complex_model, k_)

# ╔═╡ 114f9812-b8c6-4f7b-aec3-ecb7aa1cf27e
# bayes_factor = simple_likelihood / complex_likelihood

# ╔═╡ 5ac859b4-74f9-4234-883e-2cb400b41160
md"""
## Savage-Dickey method
Sometimes the Bayes factor can be obtained by computing marginal likelihoods directly. (As in the example) However, it is sometimes hard to get good estimates of the two marginal probabilities. In the case where one model is a special case of the other, called _nested model comparison_, there is another option. The Bayes factor can also be obtained by considering only the more complex hypothesis, by looking at the distribution over the parameter of interest (here, $p$) at the point of interest (here, $p=0.5$). Dividing the probability density of the posterior by the density of the prior (of the parameter at the point of interest) gives you the Bayes Factor! This, perhaps surprising, result was described by Dickey and Lientz (1970), and they attribute it to Leonard “Jimmie” Savage. The method is called the _Savage-Dickey density ratio_ and is widely used in experimental science. We would use it like so:
"""

# ╔═╡ 5a8e197a-9760-4563-b7eb-b4ea3fa38f01
complex_model_prior = @~ StdUniform{Float64}()

# ╔═╡ 525eed2b-0473-4a7b-a0eb-df1231e47296
function complex_model_posterior(n, k)
	p = (@~ StdUniform{Float64}())
	p |ᶜ ((ω -> (@~ Binomial(n, p(ω)))(ω)) ==ₚ k)
end

# ╔═╡ 637878f7-8e41-47c1-b816-683e0ce88e29
savage_dickey_denomenator = mean(0.45 .< randsample(complex_model_prior, 1000) .< 0.55)

# ╔═╡ 05732059-db17-467a-a4f1-73e52d76fc5e
savage_dickey_numerator = mean(0.45 .< randsample(complex_model_posterior(n_, k_), 1000) .< 0.55)

# ╔═╡ 57e9ca64-f630-42e1-b4aa-270a12f45c4a
savage_dickey_ratio = savage_dickey_numerator/savage_dickey_denomenator

# ╔═╡ 0730bcb1-4040-4146-ba60-76bd6211044b
md"(Note that we have approximated the densities by looking at the expectation that $p$ is within $0.05$ of the target value $p=0.5$.)"

# ╔═╡ 833f60bd-f122-4f2a-a303-c988016c4d4f
md"""
## BDA of cognitive models
In this chapter we have described how we can use generative models of data to do data analysis. In the rest of this book we are largely interested in how we can build _cognitive models_ by hypothesizing that people have generative models of the world that they use to reason and learn. That is, we view people as intuitive Bayesian statisticians, doing in their heads what scientists do in their notebooks.

Of course when we, as scientists, try to test our cognitive models of people, we can do so using BDA! This leads to more complex models in which we have an “outer” Bayesian data analysis model and an “inner” Bayesian cognitive model. What is in the inner (cognitive) model captures our scientific hypotheses about what people know and how they reason. What is in the outer (BDA) model represents aspects of our hypotheses about the data that we _are not_ attributing to people: linking functions, unknown parameters of the cognitive model, and so on. This distinction can be subtle.
"""

# ╔═╡ Cell order:
# ╠═71c84094-44f5-495b-b627-e09c880183a0
# ╟─3cbb6cf1-07b9-4706-a178-c370096ea159
# ╟─dc117328-a880-48b2-a363-7fd1ae20d6d6
# ╠═52cf5e5b-3f3d-4361-bec3-78a1b817e3cb
# ╠═88c450fc-1930-4529-9259-dd22d721953f
# ╠═ffddd0ab-0745-400a-8191-bdd2a4ecdfef
# ╠═3ac23e10-3340-45f2-93ff-1387d9d5c824
# ╠═db1b173c-f2d4-4fd1-bd26-d526f3f8c33b
# ╠═bcd64b7e-e9bd-4f94-a609-0b3e573cdfc3
# ╠═b24b3c1d-c74b-4c43-912a-7c2d181996ac
# ╟─bca6e816-8c92-4ce9-802c-3e6061fcb8f9
# ╟─ae20e3db-1f78-4486-b31e-edad3ef51d8a
# ╠═8c7d9c67-f95d-46b2-96cd-3f5c31cfe2bf
# ╟─1b86689b-b6c3-47af-b73b-7cd6ef56c3d3
# ╠═4d54b1ef-b1ab-492a-a164-f5dfd7ac7bcb
# ╟─ddcefc32-42c0-4a83-a1c9-f26532d9b0ad
# ╠═0be7a6b1-886d-4440-8802-999af903bef1
# ╠═c65d7c12-ff8f-4fbf-baaa-d2f142d66602
# ╟─a5a247e0-7132-4fe3-8f35-3fbedf8fc858
# ╠═7b44c10b-a12f-4274-a9a9-5caa6c3649d0
# ╠═b2861324-d7f0-426b-9cb5-2df784597777
# ╠═bd180618-0e37-45f9-bdd1-18c2746c532e
# ╟─5f1ee809-914b-499e-9062-06af5c73456e
# ╟─1aded1ad-3e41-47f8-89ee-9e852c9603ee
# ╠═43944860-c1ee-48bb-a3a6-39b768065306
# ╠═ebfa0d3e-c056-4fd2-9564-7e230a4d3c11
# ╠═855a5f0c-f6ce-4ac5-8f6e-f935c2160cd4
# ╠═dfa039a8-befb-4106-adb8-4f89bdb03519
# ╠═8734a4d7-6349-47e4-a4bb-fca2685e0796
# ╠═63c901a7-3efb-414a-85b0-71bbbb1de894
# ╠═998a3439-2be5-4e2e-a7ad-ed11b8d17f62
# ╠═fa5f280b-eb1b-483b-b7b9-05ef931b80a5
# ╠═08cfd264-9969-4436-9af8-a1e5c342dc9e
# ╠═d9e93d06-0fab-4c44-89ba-f7ea17ddc908
# ╠═181a9dbf-550d-439e-a9f2-f67aae3fb992
# ╟─383f3eee-9fef-47ce-91b6-b4adbdea819b
# ╠═01748bea-e5d6-4a2c-8597-7e65f3064eff
# ╠═349c946e-2f52-49f7-bd8a-46a8ff074dbd
# ╠═afeffccd-1473-470a-bbeb-5208b9dc7e95
# ╠═ddbcd835-0c10-4784-92a5-df574e0cbbfb
# ╠═c474e003-9e02-49ed-94f9-726b09cde964
# ╟─06c7f3b6-2cc9-4f9f-990b-e6bd9b76f564
# ╟─35ab1400-8d03-4803-aae9-99fdf55526da
# ╠═1ebcd990-9dfb-4fdc-954f-91bceeae12e8
# ╠═ebe8c2ad-a084-4aa8-9959-23d18a7dd783
# ╠═d5130e27-356a-4d32-8a40-4f487eab7a9f
# ╠═24e1cd10-da09-4a5c-9e1f-55b34f1dcb2a
# ╠═aae249b9-0ca1-4434-901b-d3961232ccc0
# ╟─eb0aa5b7-4735-4c7e-af23-8df237b1e7b9
# ╟─ad26adcb-7974-4871-8efe-004b996dfae1
# ╠═c240f715-68b8-4f77-a805-4ba024c9bd7a
# ╠═827c4019-205e-449c-b8db-34d6963748db
# ╠═29a88d50-02c8-481c-9099-5e83b70e3414
# ╠═05d090dd-9834-4794-bd06-43ae8837ef8b
# ╠═114f9812-b8c6-4f7b-aec3-ecb7aa1cf27e
# ╟─5ac859b4-74f9-4234-883e-2cb400b41160
# ╠═5a8e197a-9760-4563-b7eb-b4ea3fa38f01
# ╠═525eed2b-0473-4a7b-a0eb-df1231e47296
# ╠═637878f7-8e41-47c1-b816-683e0ce88e29
# ╠═05732059-db17-467a-a4f1-73e52d76fc5e
# ╠═57e9ca64-f630-42e1-b4aa-270a12f45c4a
# ╟─0730bcb1-4040-4146-ba60-76bd6211044b
# ╟─833f60bd-f122-4f2a-a303-c988016c4d4f
