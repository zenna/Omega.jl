### A Pluto.jl notebook ###
# v0.18.4

using Markdown
using InteractiveUtils

# ╔═╡ 427267ba-99f3-458b-8b92-beda4f3cf89c
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    using Omega, Distributions, UnicodePlots, OmegaExamples
end

# ╔═╡ 990b5790-639f-11ec-1c82-8156cb2d73c6
md"""
The line between “reasoning” and “learning” is unclear in cognition. Just as reasoning can be seen as a form of conditional inference, so can learning: discovering persistent facts about the world (for example, causal processes or causal properties of objects). By saying that we are learning “persistent” facts we are indicating that there is something to infer which we expect to be relevant to many observations over time. Thus, we will formulate learning as inference in a model that (1) has a fixed latent value of interest, the hypothesis, and (2) has a sequence of observations, the data points.

When thinking about learning as inference, there are several key questions. First, what can be inferred about the hypothesis given a certain subset of the observed data? For example, in most cases, you cannot learn much about the weight of an object based on its colour. However, if there is a correlation between weight and colour – as is the case in many children’s toys – observing colour does allow you to learn about weight.

Second, what is the relationship between the amount of input (how much data we’ve observed) and the knowledge gained? In psychology, this relationship is often characterized with a learning curve, representing a belief as a function of amount of data. In general, getting more data allows us to update our beliefs. But some data, in some models, has a much bigger effect. In addition, while knowledge often changes gradually as data is accumulated, it sometimes jumps in non-linear ways; these are usually the most psychologically interesting predictions.

## Example: Learning About Coins
As a simple illustration of learning, imagine that a friend pulls a coin out of her pocket and offers it to you to flip. You flip it five times and observe a set of all heads:

`[H, H, H, H, H]`.

Does this seem at all surprising? To most people, flipping five heads in a row is a minor coincidence but nothing to get excited about. But suppose you flip it five more times and continue to observe only heads. Now the data set looks like this:

`[H, H, H, H, H, H, H, H, H, H]`

Most people would find this a highly suspicious coincidence and begin to suspect that perhaps their friend has rigged this coin in some way – maybe it’s a weighted coin that always comes up heads no matter how you flip it. This inference could be stronger or weaker, of course, depending on what you believe about your friend or how she seems to act; did she offer a large bet that you would flip more heads than tails? Now you continue to flip five more times and again observe nothing but heads – so the data set now consists of 15 heads in a row:

`[H, H, H, H, H, H, H, H, H, H, H, H, H, H, H]`

Regardless of your prior beliefs, it is almost impossible to resist the inference that the coin is a trick coin.

This _learning curve_ reflects a highly systematic and rational process of conditional inference. For simplicity let’s consider only two hypotheses, two possible definitions of coin, representing a fair coin and a trick coin that produces heads $95\%$ of the time. A priori, how likely is any coin offered up by a friend to be a trick coin? Of course there is no objective or universal answer to that question, but for the sake of illustration let’s assume that the _prior probability_ of seeing a trick coin is 1 in a 1000, versus 999 in 1000 for a fair coin.
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
Try varying the number of flips and the number of heads observed. You should be able to reproduce the intuitive learning curve described above. Observing $5$ heads in a row is not enough to suggest a trick coin, although it does raise the hint of this possibility: its chances are now a few percent, approximately $30$ times the baseline chance of $1$ in a $1000$. After observing $10$ heads in a row, the odds of trick coin and fair coin are now roughly comparable, although fair coin is still a little more likely. After seeing 15 or more heads in a row without any tails, the odds are now strongly in favour of the trick coin.

When exploring learning as a conditional inference, we are particularly interested in the dynamics of how inferred hypotheses change as a function of amount of data (often thought of as time the learner spends acquiring data). We can map out the trajectory of learning by plotting a summary of the posterior distribution as a function of the amount of observed data. Here we plot the expectation that the coin is fair in the above example:
"""

# ╔═╡ 523481cf-9700-4e89-8873-435a9bbc5b6d
true_weight = 0.9

# ╔═╡ d1a89a1e-c85b-466e-b0a1-79da2e3372bd
# observed_data_sizes = [1, 3, 6, 10, 20, 50, 100]
observed_data_sizes = [1, 3, 6]

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
	(gen_sequence[1] |ᶜ (gen_sequence[1] .== val))(ω)
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

# ╔═╡ a5d4ec57-b620-4394-89ba-08bf3fcb1b8c
md"## Example: Polya's Urn"

# ╔═╡ 69b7c347-517d-4eae-ad90-4562f03d8f37
md"""
A classic example is Polya’s urn: Imagine an urn that contains some number of white and black balls. On each step we draw a random ball from the urn, note its color, and return it to the urn along with _another_ ball of that color. Here is this model in Omega:
"""

# ╔═╡ 9fce8665-ff2b-4e12-ab80-67178f9e0ad6
function urn_seq(urn, num_samples, ω)
	if num_samples == 0
		return empty(urn)
	else
		ball = ((@uid, num_samples) ~ Omega.UniformDraw(urn))(ω)
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
obs_fn(obs) = Variable(ω -> map(i -> coin(i, ω, fair(fair_prior)), 1:length(obs)))

# ╔═╡ 67c6dafd-c4e0-42ff-85ac-ef9594a0ff72
fair_posterior(obs) = fair(fair_prior) |ᶜ pw(==, obs_fn(obs), obs)

# ╔═╡ c7eb8d24-2c9d-4581-a5ea-aa38dbfc9a6e
viz(randsample(fair_posterior(observed_data), 1000))

# ╔═╡ 5ed94f8f-a98e-4769-9018-ab8cdf8f75d0
estimates(n, ω) = 
	fair_posterior(manynth((Bernoulli(true_weight)), 1:n)(ω))(ω)

# ╔═╡ d6b8e4c1-2c8e-497f-953e-462bb36e864d
begin
	p_estimates = 
		map(n -> randsample(ω -> estimates(n, ω), 1000), observed_data_sizes)
	p_estimates = mean.(p_estimates)
end

# ╔═╡ 4f1c19d0-ab17-405e-9ec6-9a58b5486a40
scatterplot(observed_data_sizes, p_estimates, marker = :xcross)

# ╔═╡ a4bdc1d3-f78e-4021-ae60-b27512a78de9
rand_coins(seq) = manynth(coin, 1:length(seq))

# ╔═╡ 27983de7-1fb8-4026-94ec-5f2bf650fad5
is_fair_dist(seq) = is_fair |ᶜ pw(==, rand_coins(seq), seq)

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

# ╔═╡ 6e78affd-3eb1-465e-87cd-853836c9fbec
md"""
## Learning a Continuous Parameter
The previous examples represent perhaps simple cases of learning. Typical learning problems in human cognition or AI are more complex in many ways. For one, learners are almost always confronted with more than two hypotheses about the causal structure that might underlie their observations. Indeed, hypothesis spaces for learning are often infinite. Countably infinite hypothesis spaces are encountered in models of learning for domains traditionally considered to depend on “discrete” or “symbolic” knowledge; hypothesis spaces of grammars in language acquisition are a canonical example. Hypothesis spaces for learning in domains traditionally considered more “continuous”, such as perception or motor control, are typically uncountable and parametrized by one or more continuous dimensions. In causal learning, both discrete and continuous hypothesis spaces typically arise. (In statistics, making conditional inferences over continuous hypothesis spaces given data is often called _parameter estimation_.)

We can explore a basic case of learning with continuous hypothesis spaces by slightly enriching our coin flipping example. Suppose instead of simply flipping a coin to determine which of two coin weights to use, we can choose any coin weight between $0$ and $1$. The following program computes conditional inferences about the weight of a coin drawn from a prior distribution described by the `Uniform` dsitribution, conditioned on a set of observed flips.
"""

# ╔═╡ b77a193e-1af9-4152-bd54-818628ebd8a7
obs_data = [1, 1, 1, 1, 1]

# ╔═╡ e01d2fc4-5ef9-4c3a-8c4a-e07157567864
coin_weight = @~StdUniform{Float64}()

# ╔═╡ 41803850-1725-4eee-8217-a3b3ea42a02f
coin_ = Bernoulli(coin_weight)

# ╔═╡ c4d1222e-8795-42b5-abf2-e53c48dda63d
evidence(obs) = pw(==, manynth(coin_, 1:length(obs)), obs)

# ╔═╡ cfe6baf2-f1a5-4d6f-9283-a82e4eb99311
weight_posterior(obs_data) = coin_weight |ᶜ evidence(obs_data)

# ╔═╡ f5b0452e-d60a-4503-9eb3-30d5c01bbb63
viz(randsample(weight_posterior(obs_data), 1000))

# ╔═╡ 7945b811-0cf7-459c-9793-032501c70381
md"""
Experiment with different data sets, varying both the number of flips and the relative proportion of heads and tails. How does the shape of the conditional distribution change? The location of its peak reflects a reasonable “best guess” about the underlying coin weight. It will be roughly equal to the proportion of heads observed, reflecting the fact that our prior knowledge is basically uninformative; a priori, any value of `coin_weight` is equally likely. The spread of the conditional distribution reflects a notion of confidence in our beliefs about the coin weight. The distribution becomes more sharply peaked as we observe more data, because each flip, as an independent sample of the process we are learning about, provides additional evidence of the process’s unknown parameters.

We can again look at the learning trajectory in this example:
"""

# ╔═╡ 08156d04-1a4b-40fb-9760-c4bcc3c55854
estimates_(n) = weight_posterior(ones(Int64, n))

# ╔═╡ 3d632404-dd97-420c-917a-6a4715a66df5
obs_data_sizes = [0,1,2,4,8,16,25,30,50,70,100]

# ╔═╡ c5d2b42f-5a23-42e5-963f-17560264ca03
e = map(n -> mean(randsample(estimates_(n), 1000)), obs_data_sizes)

# ╔═╡ e635efbe-2b93-4e8a-ab68-011e2d5deee4
scatterplot(obs_data_sizes, e, marker = :xcross)

# ╔═╡ 84eec6f7-09d2-4d75-94c0-3ef62c3699f8
md"""
It is easy to see that this model doesn’t really capture our intuitions about coins, or at least not in everyday scenarios. Imagine that you have just received a quarter in change from a store – or even better, taken it from a nicely wrapped-up roll of quarters that you have just picked up from a bank. Your prior expectation at this point is that the coin is almost surely fair. If you flip it $10$ times and get $7$ heads out of $10$, you’ll think nothing of it; that could easily happen with a fair coin and there is no reason to suspect the weight of this particular coin is anything other than $0.5$. But running the above query with uniform prior beliefs on the coin weight, you’ll guess the weight, in this case, is around $0.7$. Our hypothesis generating function needs to be able to draw `coin_weight` not from a uniform distribution, but from some other function that can encode various expectations about how likely the coin is to be fair, skewed towards heads or tails, and so on.

One option is the Beta distribution. The Beta distribution takes parameters `α` and `β`, which describe the prior toward `true` and `false`. (When `α` and `β` are integers they can be thought of as _prior_ observations.)
"""

# ╔═╡ bdd820b6-3e28-4d6f-92e6-e3988978fdf5
pseudo_counts = (α = 10, β = 10)

# ╔═╡ 1e5bf21c-a159-484d-a8eb-2fe9eb62832d
coin_weight_ = @~ Beta(pseudo_counts...)

# ╔═╡ e05060dc-bc8c-4ed3-9115-269a5d84732d
coin_beta = Bernoulli(coin_weight_)

# ╔═╡ bcc6e93e-fc96-4881-a72e-c214a1390964
evidence_beta(obs) = pw(==, manynth(coin_beta, 1:length(obs)), obs)

# ╔═╡ f71f5a45-89be-42c1-af9f-fcba45d793d0
weight_posterior_beta(obs) = coin_weight_ |ᶜ evidence_beta(obs)

# ╔═╡ 923e31a8-0c7d-42d1-bb08-ffaf148188bb
estimates_beta(n) = weight_posterior_beta(ones(Int64, n))

# ╔═╡ 0ab43263-3266-4a0c-ade4-4a633144d726
e_ = map(n -> mean(randsample(estimates_beta(n), 100)), observed_data_sizes)

# ╔═╡ 29e5a87a-45c3-4c7b-b841-4bf3d470eff9
scatterplot(observed_data_sizes, e_, marker = :xcross)

# ╔═╡ a504cf83-fab6-483f-a25d-c67eff261919
md"""
We are getting closer, in that learning is far more conservative. In fact, it is too conservative: after getting heads $100$ times in a row, most humans will conclude the coin can only come up heads. The model, in contrast, still expects the coin to come up tails around $10\%$ of the time.

We can of course decrease our priors `α` and `β` to get faster learning, but then we will just go back to our earlier problem. We would like instead to encode in our prior the idea that fair coins (probability $0.5$) are much more likely than even moderately unfair coins.

## A More Structured Hypothesis Space
The following model explicitly builds in the prior belief that fair coins are likely, and that all unfair coins are equally likely as each other:
"""

# ╔═╡ 5a6230f1-ea4a-45ac-8866-67875568fa07
is_fair_ = @~ Bernoulli(0.999)

# ╔═╡ a15c7d8e-f9d9-4615-8f97-bae3a0baa8a0
real_weight = ifelse.(is_fair_, 0.5, @~ StdUniform{Float64}())

# ╔═╡ 5cb0299a-27a2-4f65-b5db-4cceb60bc684
coin_human_like = Bernoulli(real_weight)

# ╔═╡ 947f20c4-92a9-43a9-855c-fd1c1aa841b6
evidence_human_like(obs) = pw(==, manynth(coin_human_like, 1:length(obs)), obs)

# ╔═╡ 2b00720e-c9cf-4ae0-8344-febf9e93dd1d
weight_posterior_human_like(obs) = real_weight |ᶜ evidence_human_like(obs)

# ╔═╡ b35e02ab-6d69-4f37-8da2-7b7ed7ffcf90
estimates_human_like(n) = weight_posterior_human_like(ones(Int64, n))

# ╔═╡ ba627b32-2572-4b0b-bed9-6aebf86b4f50
d_sizes = [0,1,2,4,6,8,10,12,15,20,25,30,40,50]

# ╔═╡ e969d56c-3f54-441b-896a-21dd2736c45c
exp = map(n -> mean(randsample(estimates_human_like(n), 100)), d_sizes)

# ╔═╡ f476b8b5-589f-491b-b3fe-9657a1143d5a
scatterplot(d_sizes, exp, marker = :xcross)

# ╔═╡ 3116379d-b55f-4d4d-a2ba-1aeb01926169
md"""
This model stubbornly believes the coin is fair until around $10$ successive heads have been observed. After that, it rapidly concludes that the coin can only come up heads. The shape of this learning trajectory is much closer to what we would expect for humans. This model is a simple example of a _hierarchical prior_ which we explore in detail in a later chapter.

## Example: Estimating Causal Power
Modeling beliefs about coins makes for clear examples, but it’s obviously not a very important cognitive problem. However, many important cognitive problems have a remarkably similar structure.

For instance, a common problem for cognition is _causal learning_: from observed evidence about the co-occurrence of events, attempt to infer the causal structure relating them. An especially simple case that has been studied by psychologists is _elemental causal induction_: causal learning when there are only two events, a potential cause C and a potential effect E. Cheng and colleagues have suggested assuming that C and background effects can both cause E, with a noisy-or interaction. Causal learning then becomes an example of parameter learning, where the parameter is the “causal power” of C to cause E:
"""

# ╔═╡ 1f7a6006-a3d8-4e26-ac68-51389234202e
cp = @~ StdUniform{Float64}() # Causal power of C to cause E

# ╔═╡ 9f9802b1-f04d-433a-8422-ab2aad484266
b = @~ StdUniform{Float64}() # Background probability of E

# ╔═╡ 229fe518-9818-410d-8051-b48242570cd6
randsample(pw(.&, manynth(Bernoulli(cp), 1:2), [false, false]))

# ╔═╡ c1a176b6-ab7d-47ac-ab33-4525f5f366a8
function obs_function(data)
	cp_ = manynth(Bernoulli(cp), 1:length(data.C))
	b_ = manynth(Bernoulli(b), 1:length(data.C))
	pw(==, pw(.|, pw(.&, cp_, data.C), b_), data.E)
end

# ╔═╡ ae93dd8d-f4ec-4465-b007-d3ad47804284
data = (C = [true, true, false, true], E = [true, true, false, true])

# ╔═╡ 45f8dfc1-16b2-428e-8ced-bc69e85fd549
viz(randsample(cp |ᶜ obs_function(data), 1000))

# ╔═╡ a499e130-77f1-47f9-9016-988917bf5b27
md"""
Experiment with this model: when does it conclude that a causal relation is likely (high `cp`)? Does this match your intuitions? What role does the background rate `b` play? What happens if you change the functional relationship in `obs_function`?
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
# ╟─a5d4ec57-b620-4394-89ba-08bf3fcb1b8c
# ╟─69b7c347-517d-4eae-ad90-4562f03d8f37
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
# ╟─6e78affd-3eb1-465e-87cd-853836c9fbec
# ╠═b77a193e-1af9-4152-bd54-818628ebd8a7
# ╠═e01d2fc4-5ef9-4c3a-8c4a-e07157567864
# ╠═41803850-1725-4eee-8217-a3b3ea42a02f
# ╠═c4d1222e-8795-42b5-abf2-e53c48dda63d
# ╠═cfe6baf2-f1a5-4d6f-9283-a82e4eb99311
# ╠═f5b0452e-d60a-4503-9eb3-30d5c01bbb63
# ╟─7945b811-0cf7-459c-9793-032501c70381
# ╠═08156d04-1a4b-40fb-9760-c4bcc3c55854
# ╠═3d632404-dd97-420c-917a-6a4715a66df5
# ╠═c5d2b42f-5a23-42e5-963f-17560264ca03
# ╠═e635efbe-2b93-4e8a-ab68-011e2d5deee4
# ╟─84eec6f7-09d2-4d75-94c0-3ef62c3699f8
# ╠═bdd820b6-3e28-4d6f-92e6-e3988978fdf5
# ╠═1e5bf21c-a159-484d-a8eb-2fe9eb62832d
# ╠═e05060dc-bc8c-4ed3-9115-269a5d84732d
# ╠═bcc6e93e-fc96-4881-a72e-c214a1390964
# ╠═f71f5a45-89be-42c1-af9f-fcba45d793d0
# ╠═923e31a8-0c7d-42d1-bb08-ffaf148188bb
# ╠═0ab43263-3266-4a0c-ade4-4a633144d726
# ╠═29e5a87a-45c3-4c7b-b841-4bf3d470eff9
# ╟─a504cf83-fab6-483f-a25d-c67eff261919
# ╠═5a6230f1-ea4a-45ac-8866-67875568fa07
# ╠═a15c7d8e-f9d9-4615-8f97-bae3a0baa8a0
# ╠═5cb0299a-27a2-4f65-b5db-4cceb60bc684
# ╠═947f20c4-92a9-43a9-855c-fd1c1aa841b6
# ╠═2b00720e-c9cf-4ae0-8344-febf9e93dd1d
# ╠═b35e02ab-6d69-4f37-8da2-7b7ed7ffcf90
# ╠═ba627b32-2572-4b0b-bed9-6aebf86b4f50
# ╠═e969d56c-3f54-441b-896a-21dd2736c45c
# ╠═f476b8b5-589f-491b-b3fe-9657a1143d5a
# ╟─3116379d-b55f-4d4d-a2ba-1aeb01926169
# ╠═1f7a6006-a3d8-4e26-ac68-51389234202e
# ╠═9f9802b1-f04d-433a-8422-ab2aad484266
# ╠═229fe518-9818-410d-8051-b48242570cd6
# ╠═c1a176b6-ab7d-47ac-ab33-4525f5f366a8
# ╠═ae93dd8d-f4ec-4465-b007-d3ad47804284
# ╠═45f8dfc1-16b2-428e-8ced-bc69e85fd549
# ╟─a499e130-77f1-47f9-9016-988917bf5b27
