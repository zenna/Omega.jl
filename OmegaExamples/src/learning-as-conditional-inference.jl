### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ 427267ba-99f3-458b-8b92-beda4f3cf89c
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    using Omega, Distributions, UnicodePlots, FreqTables
	viz(var::Vector{T} where T<:Union{String, Char}) = 	
		barplot(Dict(freqtable(var)))
	viz(var::Vector{<:Real}) = histogram(var, symbols = ["■"])
	viz(var::Vector{Bool}) = viz(string.(var))
end

# ╔═╡ 990b5790-639f-11ec-1c82-8156cb2d73c6
md"""
The line between “reasoning” and “learning” is unclear in cognition. Just as reasoning can be seen as a form of conditional inference, so can learning: discovering persistent facts about the world (for example, causal processes or causal properties of objects). By saying that we are learning “persistent” facts we are indicating that there is something to infer which we expect to be relevant to many observations over time. Thus, we will formulate learning as inference in a model that (1) has a fixed latent value of interest, the hypothesis, and (2) has a sequence of observations, the data points.

When thinking about learning as inference, there are several key questions. First, what can be inferred about the hypothesis given a certain subset of the observed data? For example, in most cases, you cannot learn much about the weight of an object based on its color. However, if there is a correlation between weight and color – as is the case in many children’s toys – observing color does allow you to learn about weight.

Second, what is the relationship between the amount of input (how much data we’ve observed) and the knowledge gained? In psychology, this relationship is often characterized with a learning curve, representing a belief as a function of amount of data. In general, getting more data allows us to update our beliefs. But some data, in some models, has a much bigger effect. In addition, while knowledge often changes gradually as data is accumulated, it sometimes jumps in non-linear ways; these are usually the most psychologically interesting predictions.

## Example: Learning About Coins
As a simple illustration of learning, imagine that a friend pulls a coin out of her pocket and offers it to you to flip. You flip it five times and observe a set of all heads:

`[H, H, H, H, H]`.

Does this seem at all surprising? To most people, flipping five heads in a row is a minor coincidence but nothing to get excited about. But suppose you flip it five more times and continue to observe only heads. Now the data set looks like this:

`[H, H, H, H, H, H, H, H, H, H]`

Most people would find this a highly suspicious coincidence and begin to suspect that perhaps their friend has rigged this coin in some way – maybe it’s a weighted coin that always comes up heads no matter how you flip it. This inference could be stronger or weaker, of course, depending on what you believe about your friend or how she seems to act; did she offer a large bet that you would flip more heads than tails? Now you continue to flip five more times and again observe nothing but heads – so the data set now consists of 15 heads in a row:

`[H, H, H, H, H, H, H, H, H, H, H, H, H, H, H]`

Regardless of your prior beliefs, it is almost impossible to resist the inference that the coin is a trick coin.

This _learning curve_ reflects a highly systematic and rational process of conditional inference. For simplicity let’s consider only two hypotheses, two possible definitions of coin, representing a fair coin and a trick coin that produces heads 95% of the time. A priori, how likely is any coin offered up by a friend to be a trick coin? Of course there is no objective or universal answer to that question, but for the sake of illustration let’s assume that the _prior probability_ of seeing a trick coin is 1 in a 1000, versus 999 in 1000 for a fair coin.
"""

# ╔═╡ b51dd157-506b-42dd-8c3c-12f3eade747b
observed_data = [1, 1, 1, 1, 1]

# ╔═╡ ceeb5931-e505-4ee9-86ad-4adca3454cd5
fair_prior = 0.999

# ╔═╡ 8ea96115-7a4c-4185-b88f-c520f0001dcb
fair(fair_prior) = @~ Bernoulli(fair_prior)

# ╔═╡ 5568ebf8-6e3e-475d-a19e-f73f2cacf920
coin(i, ω, f) = ((@uid, i) ~ Bernoulli(f(ω) ? 0.5 : 0.95))(ω)

# ╔═╡ 9818825b-a4a7-4824-a45b-1dd06e42f05d
md"""
Try varying the number of flips and the number of heads observed. You should be able to reproduce the intuitive learning curve described above. Observing $5$ heads in a row is not enough to suggest a trick coin, although it does raise the hint of this possibility: its chances are now a few percent, approximately $30$ times the baseline chance of $1$ in a $1000$. After observing 10 heads in a row, the odds of trick coin and fair coin are now roughly comparable, although fair coin is still a little more likely. After seeing 15 or more heads in a row without any tails, the odds are now strongly in favor of the trick coin.

When exploring learning as a conditional inference, we are particularly interested in the dynamics of how inferred hypotheses change as a function of amount of data (often thought of as time the learner spends acquiring data). We can map out the trajectory of learning by plotting a summary of the posterior distribution as a function of the amount of observed data. Here we plot the expectation that the coin is fair in the above example:
"""

# ╔═╡ 523481cf-9700-4e89-8873-435a9bbc5b6d
true_weight = 0.9

# ╔═╡ d1a89a1e-c85b-466e-b0a1-79da2e3372bd
observed_data_sizes = [1, 3, 6, 10, 20, 50, 100]

# ╔═╡ c12f5d78-100c-4547-ab51-4d327be4cbdb
md"""
Notice that different runs of this program can give quite different trajectories, but always end up in the same place in the long run. This is because the data set used for learning is different on each run. This is a feature, not a bug: real learners have idiosyncratic experience, even if they are all drawn from the same distribution. Of course, we are often interested in the average behavior of an ideal learner: we could average this plot over many randomly chosen data sets, simulating many different learners.

Study how this learning curve depends on the choice of `fair_prior`. There is certainly a dependence. If we set `fair_prior` to be $0.5$, equal for the two alternative hypotheses, just $5$ heads in a row are sufficient to favor the trick coin by a large margin. If `fair_prior` is $99$ in $100$, $10$ heads in a row are sufficient. We have to increase `fair_prior` quite a lot, however, before $15$ heads in a row is no longer sufficient evidence for a trick coin: even at `fair_prior = 0.9999`, $15$ heads without a single tail still weighs in favor of the trick coin. This is because the evidence in favor of a trick coin accumulates exponentially as the data set increases in size; each successive head flips increases the evidence by nearly a factor of $2$.

Learning is always about the shift from one state of knowledge to another. The speed of that shift provides a way to diagnose the strength of a learner’s initial beliefs. Here, the fact that somewhere between $10$ and $15$ heads in a row is sufficient to convince most people that the coin is a trick coin suggests that for most people, the a priori probability of encountering a trick coin in this situation is somewhere between $1$ in a $100$ and $1$ in $10,000$—a reasonable range. Of course, if you begin with the suspicion that any friend who offers you a coin to flip is liable to have a trick coin in his pocket, then just seeing five heads in a row should already make you very suspicious—as we can see by setting `fair_prior` to a value such as $0.9$.
"""

# ╔═╡ 4f0b3594-878a-42c3-95f0-c85ac9276221
md"""
## Independent and Exchangeable Sequences
Now that we have illustrated the kinds of questions we are interested in asking of learning models, let’s delve into the mathematical structure of models for sequences of observations.

If the observations have nothing to do with each other, except that they have the same distribution, they are called _identically, independently distributed_ (usually abbreviated to i.i.d.). For instance the values that come from calling flip are i.i.d. To verify this, let’s first check whether the distribution of two `Bernoulli` in a sequence look the same (are “identical”):
"""

# ╔═╡ 3c890c50-4a45-4db4-9dd4-29b04fb2aa9c
gen_sequence = map(i -> ((@uid, i) ~ Bernoulli()), 1:2)

# ╔═╡ 719865fd-8d05-4f3c-8c12-82bf9cea8397
gen_sequence_samples = randsample(ω -> mapf(ω, gen_sequence), 10000)

# ╔═╡ de3c21d5-e86b-4cca-a3f6-8e4bfdb37ed9
viz(map(x -> x[1], gen_sequence_samples))

# ╔═╡ 23d7c9d3-0234-48dd-bd54-61cbc466b762
viz(map(x -> x[2], gen_sequence_samples))

# ╔═╡ 9adf5800-9c18-46de-a41e-b71f8c9a5250
md"""
Now let’s check that the first and second flips are independent, by conditioning on the first and seeing that the distribution of the second is unchanged:
"""

# ╔═╡ eb9802d9-f765-48e3-8a46-58263779e756
function test_independence(gen_sequence, val, ω)
	(gen_sequence[1] |ᶜ (gen_sequence[1] ==ₚ val))(ω)
	gen_sequence[2](ω)
end

# ╔═╡ 4e8da528-ed4c-4a12-9152-184d28ccdc7f
viz(randsample(ω -> test_independence(gen_sequence, true, ω), 1000))

# ╔═╡ 09ec7536-e3a2-45de-9659-f52cd9d3cd67
viz(randsample(ω -> test_independence(gen_sequence, false, ω), 1000))

# ╔═╡ f1f81ac8-8fd0-4a9d-8f4f-f4a33f1d9c58
md"""
It is easy to build other i.i.d.s in Omega. For instance, here is an extremely simple model for the words in a sentence:
"""

# ╔═╡ f452c5e3-7701-4156-aff3-41c6a9486139
pget(x) = i -> x[i]

# ╔═╡ a8d70517-3db6-4433-8f0d-663cb59d32ac
words = ["chef", "omelet", "soup", "eat", "work", "bake", "stop"]

# ╔═╡ a53e4406-a086-4557-a8af-037fc750fa09
probs = [0.00325, 0.48633, 0.07891, 0.06754, 0.19741, 0.13879, 0.02777]

# ╔═╡ 1ed88f98-b9e0-42ef-bb53-2e74cf91c89d
words_class(i, ω) = (pget(words) ∘ ((@uid, i) ~ Categorical(probs)))(ω)

# ╔═╡ 0ee0eaf2-4e32-4a6b-9165-7820c1507f0d
randsample(manynth(words_class, 1:10))

# ╔═╡ fd11a9bf-8951-4c4d-b4ea-7488e8576385
md"""
In this example the different words are indeed independent: you can show as above (by conditioning) that the first word tells you nothing about the second word. However, constructing sequences in this way it is easy to accidentally create a sequence that is not entirely independent. For instance:
"""

# ╔═╡ 5b8872b7-b731-4bb0-aa85-c7cf47ab7e67
probs_dep(ω) = ((@~ Bernoulli())(ω) ?
             [0.00325, 0.48633, 0.07891, 0.06754, 0.19741, 0.13879, 0.02777] :
             [0.36994, 0.12965, 0.02783, 0.41318, 0.02392, 0.01599, 0.01949])

# ╔═╡ 6b6e6026-7dc9-4644-b274-02a3b449a257
words_dep_class(i, ω) = (pget(words) ∘ ((@uid, i) ~ Categorical(probs_dep(ω))))(ω)

# ╔═╡ ce6d0f9f-1e61-4e80-8ca4-41a552abb3ae
randsample(manynth(words_dep_class, 1:10))

# ╔═╡ 07b4c6d6-285e-4f14-b423-ea4f865f724c
md"""
While the sequence looks very similar, the words are not independent: learning about the first word tells us something about the `probs_dep`, which in turn tells us about the second word. Let’s show this in a slightly simpler example:
"""

# ╔═╡ 357a550c-57a6-47b7-881f-c16dea3076d2
gen_sequence_(i, ω) = ((@uid, i) ~ Bernoulli((@~ Bernoulli())(ω) ? 0.2 : 0.7))(ω)

# ╔═╡ 4c998b22-618c-4229-acbc-0467ae79f808
gen_sequence_dep = map(i -> i ~ gen_sequence_, 1:2)

# ╔═╡ 369e1664-e8dc-46b3-944c-83ff0bb25589
gen_sequence_dep_samples = randsample(ω -> mapf(ω, gen_sequence_dep), 10000)

# ╔═╡ 2fdc9ba1-0274-4de5-bad4-5b103bd177b2
viz(map(x -> x[1], gen_sequence_dep_samples))

# ╔═╡ 65db1e98-c40a-44de-b05f-cb512bddd317
viz(map(x -> x[2], gen_sequence_dep_samples))

# ╔═╡ 5b725967-d42c-4a3f-ab1b-7ab2331f3f9e
viz(randsample(ω -> test_independence(gen_sequence_dep, true, ω), 1000))

# ╔═╡ b9edb20e-c99a-48a6-a909-a84e8ee0358e
viz(randsample(ω -> test_independence(gen_sequence_dep, false, ω), 1000))

# ╔═╡ 5399b7e0-9864-45ed-a598-69993f3a8dc3
md"""
Conditioning on the first value tells us something about the second. This model is thus not i.i.d., but it does have a slightly weaker property: it is _exchangeable_, meaning that the probability of a sequence of values remains the same if permuted into any order. When modeling learning it is often reasonable that the order of observations doesn’t matter—and hence that the distribution is exchangeable.

It turns out that exchangeable sequences can always be modeled in the form used for the last example: _de Finetti’s theorem_ says that, under certain technical conditions, any exchangeable sequence can be represented in terms of some `latent_prior` distribution and observation function `f`.
"""

# ╔═╡ dfacf8f1-356a-4255-8f80-5d86fa16d2fe
md"## IIDs in Omega"

# ╔═╡ 9f94944d-3702-4603-8c24-e4b4f3800770
md"The above example can be made independent in Omega using the function `iid`. It creates a copy of the parent variable `@~ Bernoulli()` as well as `gen_sequence_` which is why the resulting variables are independent. This can be shown (by conditioning) as given below:"

# ╔═╡ 4ee74436-419d-4836-aa20-c5da65e80f19
gen_sequence_indep_class = iid(@~ gen_sequence_)

# ╔═╡ 75522b7b-73dd-4b04-8984-ec51dc488a02
gen_sequence_indep = map(i-> i ~ gen_sequence_indep_class, 1:2)

# ╔═╡ 08c099b2-9038-4e4b-862b-11ed536c09d0
gen_sequence_indep_samples = randsample(ω -> mapf(ω, gen_sequence_indep), 10000)

# ╔═╡ 0cbc9f62-e8e6-4bfc-8d3b-ee2b1150cd45
viz(map(x -> x[1], gen_sequence_indep_samples))

# ╔═╡ 5f546a53-4755-4e7a-945f-8b0353863830
viz(map(x -> x[2], gen_sequence_indep_samples))

# ╔═╡ 1953b97d-3ee6-4605-b52e-07a1bef76dd3
md"This is the same as the result of `gen_sequence_dep_samples`. Now, testing for independence, we get:"

# ╔═╡ da34c7d8-0693-4b7b-bbff-36453eb76fa8
viz(randsample(ω -> test_independence(gen_sequence_indep, true, ω), 1000))

# ╔═╡ 1e2ce1c5-dda8-4dd7-b571-b7a0ca910c9c
viz(randsample(ω -> test_independence(gen_sequence_indep, false, ω), 1000))

# ╔═╡ a5d4ec57-b620-4394-89ba-08bf3fcb1b8c
md"## Example: Polya's Urn"

# ╔═╡ 69b7c347-517d-4eae-ad90-4562f03d8f37
md"""
A classic example is Polya’s urn: Imagine an urn that contains some number of white and black balls. On each step we draw a random ball from the urn, note its color, and return it to the urn along with _another_ ball of that color. Here is this model in Omega:
"""

# ╔═╡ 8423c090-aa21-4740-b2e6-70cbd5efba7e
begin
	struct UniformDraw{T}
		elem::T
	end
	(u::UniformDraw)(i, ω) = 
		u.elem[(i ~ DiscreteUniform(1, length(u.elem)))(ω)]
end

# ╔═╡ 1217dbdb-d863-4dc2-8916-0c77f426fa00
randsample(@~ UniformDraw(['a', 'b', 'c']))

# ╔═╡ 9fce8665-ff2b-4e12-ab80-67178f9e0ad6
function urn_seq(urn, num_samples, ω)
	if num_samples == 0
		return empty(urn)
	else
		ball = ((@uid, num_samples) ~ UniformDraw(urn))(ω)
		return vcat(ball, urn_seq(vcat(urn, ball), num_samples - 1, ω))
	end
end

# ╔═╡ 513d9d3b-128c-47cb-84c4-35eb1dd1c804
viz(randsample(ω -> string(urn_seq(['b', 'w'], 3, ω)), 1000))

# ╔═╡ e91bc5c2-36d8-466f-8cbb-33acfcc8a32d
md"""
Polya’s urn is an examples of a “rich get richer” dynamic, which has many applications for modeling the real world. Examining the distribution on sequences, it appears that this model is exchangeable—permutations of a sequence all have the same probability (e.g., `['b', 'b', 'w']`, `['b', 'w', 'b']`, `['w', 'b', 'b']` have the same probability; `['b', 'w', 'w']`, `['w', 'b', 'w']`, `['w', 'w', 'b']` do too). (Challenge: Can you prove this mathematically?)

Because the distribution is exchangeable, we know that there must be an alterative representation in terms of a latent quantity followed by independent samples. The de Finetti representation of this model is:
"""

# ╔═╡ ab263fe6-0d16-4aa5-a6f6-a7b611a5e407
function urn_de_Finetti(urn, num_samples, ω)
	num_white = count(x -> x =='w', urn)
	num_black = length(urn) - num_white
	latent_prior = ((@uid, num_samples) ~ Beta(num_white, num_black))(ω)
	map(i -> ((i ~ Bernoulli(latent_prior))(ω) ? 'b' : 'w'), 1:num_samples)
end

# ╔═╡ 4a74b4b5-0a08-4b4f-ac3d-a1f0b321ebbf
viz(randsample(ω -> string(urn_de_Finetti(['b', 'w'], 3, ω)), 1000))

# ╔═╡ 82abfdd1-e976-4751-96ae-cac10025a9d6
md"""
We sample a shared latent parameter – in this case, a sample from a Beta distribution – generating the sequence samples independently given this parameter. We obtain the same distribution on sequences of draws. (Challenge: show mathematically that these two representations give the same distribution.)

## Ideal learners
Recall that we aimed to formulate learning as inference in a model that has a fixed latent value of interest and a sequence of observations. We now know that this will be possible anytime we are willing to assume the data are exchangeable. 

Many Bayesian models of learning are formulated in this way. We often write this in the pattern of Bayes’ rule:
"""

# ╔═╡ 3245a72d-cb45-484b-a387-78553831ca59
md"""
```
hypothesis = prior(ω)
obs_fn(datum) = ...uses hypothesis...
hypothesis |ᶜ obs_fn ==ₚ observed_data
```

The `prior` samples a hypothesis from the hypothesis space. This distribution expresses our prior knowledge about how the process we observe is likely to work, before we have observed any data. The function `obs_fn` captures the relation between the `hypothesis` and a single `datum`. (The marginal probability function for `obs_fn` is called the _likelihood_. Sometimes `obs_fn` itself is colloquially called the likelihood, too.)

Overall this setup of prior, likelihood, and a sequence of observed data (which implies an exchangeable distribution on data!) describes an _ideal learner_.

## Example: Subjective Randomness
What does a random sequence look like? Is 00101 more random than 00000? Is the former a better example of a sequence coming from a fair coin than the latter? Most people say so, but notice that if you flip a fair coin, these two sequences are equally probable. Yet these intuitions about randomness are pervasive and often misunderstood: In 1936 the Zenith corporation attempted to test the hypothesis the people are sensitive to psychic transmissions. During a radio program, a group of psychics would attempt to transmit a randomly drawn sequence of ones and zeros to the listeners. Listeners were asked to write down and then mail in the sequence they perceived. The data thus generated showed no systematic effect of the transmitted sequence—but it did show a strong preference for certain sequences ([Goodfellow, 1938](https://scholar.google.com/scholar?q=%22A%20psychological%20interpretation%20of%20the%20results%20of%20the%20Zenith%20radio%20experiments%20in%20telepathy.%22)). The preferred sequences included 00101, 00110, 01100, and 01101.

[Griffiths and Tenenbaum (2001)](http://web.mit.edu/cocosci/Papers/random.pdf) suggested that we can explain this bias if people are considering not the probability of the sequence under a fair-coin process, but the probability that the sequence would have come from a fair process as opposed to a non-uniform (trick) process:
"""

# ╔═╡ 8005ed0c-f451-458b-a422-5dcf365645fc
is_fair = @~ Bernoulli()

# ╔═╡ f7ee441d-e0ca-491a-99ee-d188c7ede9d4
coin(i, ω) = ((@uid, i) ~ Bernoulli(is_fair(ω) ? 0.5 : 0.2))(ω)

# ╔═╡ b1d26590-42c8-464c-b4c7-ee9baa699155
obs_fn(obs) = ω -> map(i -> coin(i, ω, fair(fair_prior)), 1:length(obs))

# ╔═╡ 67c6dafd-c4e0-42ff-85ac-ef9594a0ff72
fair_posterior(obs) = fair(fair_prior) |ᶜ (obs_fn(obs) ==ₚ obs)

# ╔═╡ c7eb8d24-2c9d-4581-a5ea-aa38dbfc9a6e
viz(randsample(fair_posterior(observed_data), 1000))

# ╔═╡ 5ed94f8f-a98e-4769-9018-ab8cdf8f75d0
estimates(n) = 
	fair_posterior(randsample((@~ Bernoulli(true_weight)), n))

# ╔═╡ d6b8e4c1-2c8e-497f-953e-462bb36e864d
begin
	p_estimates = 
		map(n -> randsample(estimates(n), 10), observed_data_sizes)
	p_estimates = mean.(p_estimates)
end

# ╔═╡ 4f1c19d0-ab17-405e-9ec6-9a58b5486a40
scatterplot(observed_data_sizes, p_estimates, marker = :xcross)

# ╔═╡ a4bdc1d3-f78e-4021-ae60-b27512a78de9
rand_coins(seq) = manynth(coin, 1:length(seq))

# ╔═╡ 27983de7-1fb8-4026-94ec-5f2bf650fad5
is_fair_dist(seq) = is_fair |ᶜ (rand_coins(seq) ==ₚ seq)

# ╔═╡ d7df634a-3580-4556-a61a-4fe0e47760ac
md"To check if 00000 is fair:"

# ╔═╡ 3ac66c4b-a6c6-426f-a86c-0e575a65b1ba
seq1 = [false, false, false, false, false]

# ╔═╡ 5969f0d8-8a33-442c-81c9-4512a1071242
viz(randsample(is_fair_dist(seq1), 1000))

# ╔═╡ 386a2319-e253-4d37-b7c4-879b2d49a13b
md"To check if 00101 is fair:"

# ╔═╡ 8c225f53-de6c-449b-b670-bbca22c81c5f
seq2 = [false, false, true, false, true]

# ╔═╡ e6acd2e7-5113-433c-92bc-fe1eb9a06cc6
viz(randsample(is_fair_dist(seq2), 1000))

# ╔═╡ 22acd3fe-9db2-442d-92c0-fd848377b3ff
md"""
This model posits that when considering randomness people are more concerned with distinguishing a “truly random” generative process from a trick process. How do these inferences depend on the amount of data? Explore the learning trajectories of this model.
"""

# ╔═╡ Cell order:
# ╠═427267ba-99f3-458b-8b92-beda4f3cf89c
# ╟─990b5790-639f-11ec-1c82-8156cb2d73c6
# ╠═b51dd157-506b-42dd-8c3c-12f3eade747b
# ╠═ceeb5931-e505-4ee9-86ad-4adca3454cd5
# ╠═8ea96115-7a4c-4185-b88f-c520f0001dcb
# ╠═5568ebf8-6e3e-475d-a19e-f73f2cacf920
# ╠═b1d26590-42c8-464c-b4c7-ee9baa699155
# ╠═67c6dafd-c4e0-42ff-85ac-ef9594a0ff72
# ╠═c7eb8d24-2c9d-4581-a5ea-aa38dbfc9a6e
# ╟─9818825b-a4a7-4824-a45b-1dd06e42f05d
# ╠═523481cf-9700-4e89-8873-435a9bbc5b6d
# ╠═d1a89a1e-c85b-466e-b0a1-79da2e3372bd
# ╠═5ed94f8f-a98e-4769-9018-ab8cdf8f75d0
# ╠═d6b8e4c1-2c8e-497f-953e-462bb36e864d
# ╠═4f1c19d0-ab17-405e-9ec6-9a58b5486a40
# ╟─c12f5d78-100c-4547-ab51-4d327be4cbdb
# ╟─4f0b3594-878a-42c3-95f0-c85ac9276221
# ╠═3c890c50-4a45-4db4-9dd4-29b04fb2aa9c
# ╠═719865fd-8d05-4f3c-8c12-82bf9cea8397
# ╠═de3c21d5-e86b-4cca-a3f6-8e4bfdb37ed9
# ╠═23d7c9d3-0234-48dd-bd54-61cbc466b762
# ╟─9adf5800-9c18-46de-a41e-b71f8c9a5250
# ╠═eb9802d9-f765-48e3-8a46-58263779e756
# ╠═4e8da528-ed4c-4a12-9152-184d28ccdc7f
# ╠═09ec7536-e3a2-45de-9659-f52cd9d3cd67
# ╟─f1f81ac8-8fd0-4a9d-8f4f-f4a33f1d9c58
# ╠═f452c5e3-7701-4156-aff3-41c6a9486139
# ╠═a8d70517-3db6-4433-8f0d-663cb59d32ac
# ╠═a53e4406-a086-4557-a8af-037fc750fa09
# ╠═1ed88f98-b9e0-42ef-bb53-2e74cf91c89d
# ╠═0ee0eaf2-4e32-4a6b-9165-7820c1507f0d
# ╟─fd11a9bf-8951-4c4d-b4ea-7488e8576385
# ╠═5b8872b7-b731-4bb0-aa85-c7cf47ab7e67
# ╠═6b6e6026-7dc9-4644-b274-02a3b449a257
# ╠═ce6d0f9f-1e61-4e80-8ca4-41a552abb3ae
# ╟─07b4c6d6-285e-4f14-b423-ea4f865f724c
# ╠═357a550c-57a6-47b7-881f-c16dea3076d2
# ╠═4c998b22-618c-4229-acbc-0467ae79f808
# ╠═369e1664-e8dc-46b3-944c-83ff0bb25589
# ╠═2fdc9ba1-0274-4de5-bad4-5b103bd177b2
# ╠═65db1e98-c40a-44de-b05f-cb512bddd317
# ╠═5b725967-d42c-4a3f-ab1b-7ab2331f3f9e
# ╠═b9edb20e-c99a-48a6-a909-a84e8ee0358e
# ╟─5399b7e0-9864-45ed-a598-69993f3a8dc3
# ╟─dfacf8f1-356a-4255-8f80-5d86fa16d2fe
# ╟─9f94944d-3702-4603-8c24-e4b4f3800770
# ╠═4ee74436-419d-4836-aa20-c5da65e80f19
# ╠═75522b7b-73dd-4b04-8984-ec51dc488a02
# ╠═08c099b2-9038-4e4b-862b-11ed536c09d0
# ╠═0cbc9f62-e8e6-4bfc-8d3b-ee2b1150cd45
# ╠═5f546a53-4755-4e7a-945f-8b0353863830
# ╟─1953b97d-3ee6-4605-b52e-07a1bef76dd3
# ╠═da34c7d8-0693-4b7b-bbff-36453eb76fa8
# ╠═1e2ce1c5-dda8-4dd7-b571-b7a0ca910c9c
# ╟─a5d4ec57-b620-4394-89ba-08bf3fcb1b8c
# ╟─69b7c347-517d-4eae-ad90-4562f03d8f37
# ╠═8423c090-aa21-4740-b2e6-70cbd5efba7e
# ╠═1217dbdb-d863-4dc2-8916-0c77f426fa00
# ╠═9fce8665-ff2b-4e12-ab80-67178f9e0ad6
# ╠═513d9d3b-128c-47cb-84c4-35eb1dd1c804
# ╟─e91bc5c2-36d8-466f-8cbb-33acfcc8a32d
# ╠═ab263fe6-0d16-4aa5-a6f6-a7b611a5e407
# ╠═4a74b4b5-0a08-4b4f-ac3d-a1f0b321ebbf
# ╟─82abfdd1-e976-4751-96ae-cac10025a9d6
# ╟─3245a72d-cb45-484b-a387-78553831ca59
# ╠═8005ed0c-f451-458b-a422-5dcf365645fc
# ╠═f7ee441d-e0ca-491a-99ee-d188c7ede9d4
# ╠═a4bdc1d3-f78e-4021-ae60-b27512a78de9
# ╠═27983de7-1fb8-4026-94ec-5f2bf650fad5
# ╟─d7df634a-3580-4556-a61a-4fe0e47760ac
# ╠═3ac66c4b-a6c6-426f-a86c-0e575a65b1ba
# ╠═5969f0d8-8a33-442c-81c9-4512a1071242
# ╟─386a2319-e253-4d37-b7c4-879b2d49a13b
# ╠═8c225f53-de6c-449b-b670-bbca22c81c5f
# ╠═e6acd2e7-5113-433c-92bc-fe1eb9a06cc6
# ╟─22acd3fe-9db2-442d-92c0-fd848377b3ff
