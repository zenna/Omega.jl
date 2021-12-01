### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ f532f3b0-5293-11ec-104c-dba9836ec3d1
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
<<<<<<< HEAD
    using Omega, Distributions, UnicodePlots, OmegaExamples
end

# ╔═╡ 711c87ea-9ec0-4957-bc00-641e2dd6eaec
md"# Cognition and conditioning"

# ╔═╡ 877ff248-596c-4755-8085-281d1752ec5b
md"We have built up a tool set for constructing probabilistic generative models. These can represent knowledge about causal processes in the world: running one of these programs generates a particular outcome by sampling a “history” for that outcome. However, the power of a causal model lies in the flexible ways it can be used to reason about the world. In the last chapter we used generative models to reason about outcomes from initial conditions. Generative models also enable reasoning in other ways. For instance, if we have a generative model in which $X$ is the output of a process that depends on $Y$ (say `X = cool_function(Y)`) we may ask: “Assuming I have observed a certain $X$, what must $Y$ have been?” That is we can reason backward from outcomes to initial conditions. More generally, we can make hypothetical assumptions and reason about the generative history: “assuming something, how did the generative model run?” In this section, we describe how a wide variety of such hypothetical inferences can be made from a single generative model by conditioning the model on an assumed or observed fact."
=======
    using Omega, Distributions, UnicodePlots
end

# ╔═╡ 711c87ea-9ec0-4957-bc00-641e2dd6eaec
md"## Cognition and conditioning"

# ╔═╡ 877ff248-596c-4755-8085-281d1752ec5b
md"We have built up a tool set for constructing probabilistic generative models. These can represent knowledge about causal processes in the world: running one of these programs generates a particular outcome by sampling a “history” for that outcome. However, the power of a causal model lies in the flexible ways it can be used to reason about the world. In the last chapter we ran generative models forward to reason about outcomes from initial conditions. Generative models also enable reasoning in other ways. For instance, if we have a generative model in which X is the output of a process that depends on Y (say `X = coolFunction(Y)`) we may ask: “assuming I have observed a certain X, what must Y have been?” That is we can reason backward from outcomes to initial conditions. More generally, we can make hypothetical assumptions and reason about the generative history: “assuming something, how did the generative model run?” In this section we describe how a wide variety of such hypothetical inferences can be made from a single generative model by conditioning the model on an assumed or observed fact."
>>>>>>> dd838e4 (Add ch 2)

# ╔═╡ a0d93e64-92ca-4d32-905f-b99e5f3780d5
md"Much of cognition can be understood in terms of conditional inference. In its most basic form, causal attribution is conditional inference: given some observed effects, what were the likely causes? Predictions are conditional inferences in the opposite direction: given that I have observed some cause, what are its likely effects? These inferences can be described by conditioning a probabilistic program that expresses a causal model. The acquisition of that causal model, or learning, is also conditional inference at a higher level of abstraction: given our general knowledge of how causal relations operate in the world, and some observed events in which candidate causes and effects co-occur in various ways, what specific causal relations are likely to hold between these observed variables?"

# ╔═╡ 2a4caee4-f64a-4f2d-9b82-44df111c2c8b
md"To see how the same concepts apply in a domain that is not usually thought of as causal, consider language. The core questions of interest in the study of natural language are all at heart conditional inference problems. Given beliefs about the structure of my language, and an observed sentence, what should I believe about the syntactic structure of that sentence? This is the parsing problem. The complementary problem of speech production is related: given the structure of my language (and beliefs about others’ beliefs about that), and a particular thought I want to express, how should I encode the thought? Finally, the acquisition problem: given some data from a particular language, and perhaps general knowledge about universals of grammar, what should we believe about that language’s structure? This problem is simultaneously the problem facing the linguist and the child trying to learn a language."

# ╔═╡ 59f09e31-aa76-4b73-b841-e6192841060e
md"Parallel problems of conditional inference arise in visual perception, social cognition, and virtually every other domain of cognition. In visual perception, we observe an image or image sequence that is the result of rendering a three-dimensional physical scene onto our two-dimensional retinas. A probabilistic program can model both the physical processes at work in the world that produce natural scenes, and the imaging processes (the “graphics”) that generate images from scenes. Perception can then be seen as conditioning this program on some observed output image and inferring the scenes most likely to have given rise to it."

# ╔═╡ bbbac3fa-3708-4d4e-87e1-01143a1b3eb0
md"When interacting with other people, we observe their actions, which result from a planning process, and often want to guess their desires, beliefs, emotions, or future actions. Planning can be modeled as a program that takes as input an agent’s mental states (beliefs, desires, etc.) and produces action sequences—for a rational agent, these will be actions that are likely to produce the agent’s desired states reliably and efficiently. A rational agent can plan their actions by conditional inference to infer what steps would be most likely to achieve their desired state. Action understanding, or interpreting an agent’s observed behavior, can be expressed as conditioning a planning program (a “theory of mind”) on observed actions to infer the mental states that most likely gave rise to those actions, and to predict how the agent is likely to act in the future."

# ╔═╡ 60be7683-0b4c-467b-ba72-4d687bff9a1b
<<<<<<< HEAD
md"# Hypothetical Reasoning"

# ╔═╡ bcfd08bc-91f6-4745-aeb0-9e7ecd218388
md"Suppose that we know some fixed fact, and we wish to consider hypotheses about how a generative model could have given rise to that fact. In Omega, we can use conditional random variables to describe a distribution under some assumptions or conditions."

# ╔═╡ 70d10737-6ec4-43fc-822d-a7db70fce4d0
md"Consider the following simple generative model:"

# ╔═╡ c794ee68-86a0-49f8-9054-2f5efadd053d
A = @~ Bernoulli()

# ╔═╡ 8091bb8c-2f29-4b5c-b2b1-15c3ead9b70f
B = @~ Bernoulli()

# ╔═╡ af8e6721-0af4-42f3-9c50-2e243524260b
C = @~ Bernoulli()

# ╔═╡ 78fcf1a2-19f0-4b6a-9a45-3af4b45b20f2
model = pw(+, A, B, C)

# ╔═╡ ae9646da-2e65-4566-8953-a761864b924f
viz(randsample(model, 1000))

# ╔═╡ a6072ac1-8586-47c0-add5-f076ea6b71d8
md"The process described in model samples three numbers and adds them. The value of the final expression here is $0$, $1$, $2$ or $3$. A priori, each of the variables `A`, `B`, `C` has $0.5$ probability of being $1$ or $0$. However, suppose that we know that the sum `model` is equal to $3$. How does this change the space of possible values that variable `A` could have taken? `A` (and `B` and `C`) must be _equal_ to $1$ for this result to happen. We can see this in the following Omega inference, where we use `|ᶜ` to express the desired assumption (ie., to condition on random variables):"

# ╔═╡ 0efba943-013b-40cc-8819-ba6852214543
A_cnd = A |ᶜ (model ==ₚ 3)

# ╔═╡ ca821906-6411-43c7-bbd3-93b72978a767
viz(randsample(A_cnd, 100))

# ╔═╡ 9bc0bc9f-51f2-4b8c-8ced-eb015ef5c4de
md"""
The output here describes appropriate beliefs about the likely value of `A`, conditioned on `model` being equal to $3$.

Now suppose that we condition on `model` being greater than or equal to $2$. Then `A` need not be $1$, but it is more likely than not to be. The corresponding plot shows the appropriate distribution of beliefs for `A` conditioned on this new fact:
"""

# ╔═╡ 44be800d-abc8-476f-80d3-7f5a733f8c31
A_cnd_new = A |ᶜ (model >=ₚ 2)

# ╔═╡ aa6705f4-1c2d-4556-954d-f3b198f7f3ba
viz(randsample(A_cnd_new, 100))

# ╔═╡ b41f7e5d-61e1-4fa0-8fd1-327d0b3d4ae6
md"## Rejection Sampling"

# ╔═╡ 525fd3ab-ed0b-4d49-ba9c-6d71aec802a8
md"""
How can we imagine answering a hypothetical such as those above? We have already seen how to get a sample from a generative model. We can get conditional samples by sampling from the entire model, but only keeping the sample if the value passed to the condition is true. For instance, to sample from the above model “`A` given that `model` is greater than or equal to $2$” we could:
"""

# ╔═╡ 7fe0569f-772b-4cf6-bed2-f79a7f10ae17
A_ = @~ Bernoulli()

# ╔═╡ 8321b19d-2577-4809-aa00-f12f90a6f2c2
B_ = @~ Bernoulli()

# ╔═╡ 46f605cf-bb66-4845-b33f-1ded5fd08d75
C_ = @~ Bernoulli()

# ╔═╡ e1e88bc4-9c29-4465-b73f-52737c42ca19
D = A_ +ₚ B_ +ₚ C_

# ╔═╡ b15a1f8e-2427-42a1-a3be-ee2b8d49adf4
take_sample(ω) = (D(ω) >= 2) ? A_(ω) : take_sample(defω())

# ╔═╡ e0c9c0d1-cd53-4a0f-858b-ee60b70e2a54
viz(randsample(take_sample, 1000))

# ╔═╡ 7be5d173-d327-4126-9764-89183d23ddb1
md"Notice that we have used recursion to sample the model repeatedly until `D` >= 2 is true, and we then return `A_`: we generate and test until the condition is satisfied. This process is known as _rejection sampling_."

# ╔═╡ 6b67ec11-2e8a-414f-85ee-16a5f2f9eb7e
md"## Bayes' Rule"

# ╔═╡ ec2cecc4-0cfd-4081-b1a2-2dc0da6b6278
md"One of the most famous rules of probability is Bayes’ rule, which states:

$$P(h∣d)=\dfrac{P(d∣h) P(h)}{P(d)}$$

It is first worth noting that this follows immediately from the definition of conditional probability:

$$P(h∣d)=\dfrac{P(d,h)}{P(d)} = \dfrac{P(d,h) P(h)}{P(d)P(h)} = \dfrac{P(d∣h) P(h)}{P(d)}$$
Next, we can ask what this rule means in terms of sampling processes. Consider the program:"

# ╔═╡ bad9fc35-8d7d-4407-8e1a-f978a616c8fb
observed_data = true

# ╔═╡ f359ee3c-74c6-4d97-8e72-aaa3d23d85cd
prior = @~ Bernoulli()

# ╔═╡ abc5ca50-e65e-40a0-8e5a-bb3f95388d82
likelihood(h) = ifelseₚ(h, (@~ Bernoulli(0.9)), (@~ Bernoulli(0.1)))

# ╔═╡ 20670696-b03e-4098-ac45-5dce59d389ed
posterior = prior |ᶜ (likelihood(prior) ==ₚ observed_data)

# ╔═╡ aaedbd7a-c66e-482c-878a-2c7ce366c482
viz(randsample(posterior, 1000))

# ╔═╡ a1350291-9ed6-468e-aebf-00985d4f183b
md"""
We have generated a value, the hypothesis, from some distribution called the `prior`, then used an observation function `likelihood`, the probability of such an observation function is usually called the likelihood. Finally we have returned the hypothesis, conditioned on the observation being equal to some observed data — this conditional distribution is called the posterior. This is a typical setup in which Bayes’ rule is used.

Bayes’ rule simply says that, in special situations where the model decomposes nicely into a part “before” the value to be returned (hypothesis) and a part “after” the value to be returned, then the conditional probability can be expressed simply in terms of the prior and likelihood components of the model. This is often a useful way to think about conditional inference in simple settings. However, we will see examples as we go along where Bayes’ rule doesn’t apply in a simple way, but the conditional distribution is equally well understood in other terms.
"""

# ╔═╡ 81eea9c8-c365-4bf0-91e9-e0603034f8bc
md"## Conditions and Observations"

# ╔═╡ 60fca96c-2b8f-48e8-9d3c-4589e68743d7
md"A very common pattern is to condition directly on the value of a sample from some distribution. For instance here we try to recover a true number from a noisy observation of it:"

# ╔═╡ e76cbb9f-fbd3-4d63-8030-8d3dcc127240
true_X = @~ Normal(0, 1)

# ╔═╡ 648b4577-6464-4419-b53c-c6deebf43c10
obs_X(ω) = (0 ~ Normal(true_X(ω), 0.1))(ω)

# ╔═╡ 737a2418-1054-45c7-adb3-fa294bee458a
md"Alternatively, a more convenient way to define `obs_X` is - `obs_X = @~ Normal(true_X, 0.1)` in Omega."

# ╔═╡ f8062e02-3c7b-4b8b-a220-b211aa6864d8
obs_X_ = 0 ~ Normal(true_X, 0.1)

# ╔═╡ 261459cb-06ec-4c6b-b8ec-88121b0c7545
randsample((obs_X_, obs_X))

# ╔═╡ 48e557ae-aaf3-4d59-8728-85634242c79b
cnd_true_X = true_X |ᶜ (obs_X ==ₚ 0.2)

# ╔═╡ 5e5073bd-6866-4adb-863e-661a0a9b3bdf
# randsample(cnd_true_X)

# ╔═╡ 967c0589-e549-40d1-9ed3-8ca71a380b4e
md"You will note that when you run the above function, it never finishes. (Why? Think about what rejection sampling tries to do here…) "

# ╔═╡ b3ae8730-18a4-488e-bbda-4402576a6439
md"### Example: Reasoning about Tug of War"

# ╔═╡ 3a8aef72-4569-4b2d-b6f8-596a7ccd1113
md"Imagine a game of tug of war, where each person may be strong or weak, and may be lazy or not on each match. If a person is lazy they only pull with half their strength. The team that pulls hardest will win. We assume that strength is a continuous property of an individual, and that on any match, each person has a 1 in 3 chance of being lazy."

# ╔═╡ 07cfafb4-bc93-4c80-9c63-688f5afb8176
strength(person) = person ~ TruncatedNormal(1, 1, 0.01, Inf)

# ╔═╡ ca86dc25-90a8-49d1-b69f-b2e073bdf9f6
lazy(n, ω) = (n ~ Bernoulli(1/3))(ω)

# ╔═╡ 4509461c-6934-4cec-bd25-40334b390dcd
pulling(n, person, ω) = lazy(n, ω) ? strength(person)(ω) / 2 : strength(person)(ω)

# ╔═╡ ac581943-b6db-4e71-bd72-2de782fe6eba
function total_pulling(n, team, ω)
	s = 0.
	for (i, person) in enumerate(team)
		s += pulling(n+i, person, ω)
	end
	return s
end

# ╔═╡ 0d99389d-59dd-4c49-b603-94ad8fd731f1
begin
	function winner(team1, team2, ω)
		if total_pulling(0, team1, ω) > total_pulling(length(team1), team2, ω)
			return team1
		else
			return team2
		end
	end
	winner(team1, team2) = ω -> winner(team1, team2, ω)
end

# ╔═╡ 593c3edc-3dda-4ada-bd8a-cdf9d81baa7e
begin
	team1 = (alice = 1, bob = 2)
	team2 = (sue = 3, tom = 4)
	team1_ = (alice = 1, sue = 3)
	team2_ = (bob = 2, tom = 4)
end

# ╔═╡ bf5e6b09-47f1-475c-9a02-ba9ace529f85
 randsample(ω -> (winner(team1, team2)(ω), winner(team1_, team2_)(ω)))

# ╔═╡ b15fc51a-f0bf-43bd-9e50-abf844108e54
md"""
Notice that `strength` is a property of a person true across many matches, while lazy isn’t. Each time you run this program, however, a new “random world” will be created: people’s strengths will be randomly re-generated, then used in all the matches.

We can use this to ask a variety of different questions. For instance, how likely is it that Bob is strong, given that he’s been on a series of winning teams? (Note that we have added the helper function beat as in “team1 beat team2”; this just makes for more compact conditioning statements.)
"""

# ╔═╡ 28f2db2a-2c93-41ff-986e-2f48a374a90e
beat(team1, team2) = winner(team1, team2) ==ₚ team1

# ╔═╡ 5cc66ffc-9751-47d6-b9a9-5c37747b0a63
cnd_str = strength(team1.bob) |ᶜ beat(team1, team2)

# ╔═╡ 7e8efa1e-9bb7-494b-9120-97eedc5777fb
randsample(cnd_str)

# ╔═╡ a51f14db-1c6d-441d-b4bb-d9fe7fc90b21
md"""
A model very similar to this was used in [Gerstenberg and Goodman (2012)](http://www.stanford.edu/~ngoodman/papers/GerstenbergGoodman2012.pdf) to predict human judgements about the strength of players in ping-pong tournaments. It achieved very accurate quantitative predictions without many free parameters.

We can form many complex queries from this simple model. We could ask how likely a team of Bob and Mary is to beat a team of Jim and Sue, given that Mary is at least as strong as sue, and Bob beat Jim in a previous direct match up:
"""

# ╔═╡ 3d6a5835-356c-45ee-b3b7-c25b6d5da4b8
begin
	team_A = (bob = 2, mary = 5)
	team_B = (jim = 6, sue = 3)
end

# ╔═╡ 1e9f74fd-a19c-4a2b-8065-5dd44be6092a
condition = 
	(strength(team_A.mary) >=ₚ strength(team_B.sue)) &ₚ beat((bob = 2, ), (jim = 6, ))

# ╔═╡ b3dad899-f286-4145-9725-afce161d61f7
cnd_beat = beat(team_A, team_B) |ᶜ condition

# ╔═╡ 6d9b2966-05d1-4468-8e53-36ccfd07bf75
randsample(cnd_beat)

# ╔═╡ e3d5606f-7d01-44db-8449-81fa67c7209d
md"### Example: Causal Inference in Medical Diagnosis"

# ╔═╡ 0538557f-737a-4673-8db3-07c2a736a4af
md"This classic Bayesian inference task is a special case of conditioning. Kahneman and Tversky, and Gigerenzer and colleagues, have studied how people make simple judgments like the following:"

# ╔═╡ e4276339-e6bf-4781-8657-e2ebfb50ebfa
md"""
_The probability of breast cancer is $1\%$ for a woman at $40$ who participates in a routine screening. If a woman has breast cancer, the probability is $80\%$ that she will have a positive mammography. If a woman does not have breast cancer, the probability is $9.6\%$ that she will also have a positive mammography. A woman in this age group had a positive mammography in a routine screening. What is the probability that she actually has breast cancer?_
"""

# ╔═╡ f1f17f23-43f6-457c-a6a1-844c43bda1f3
md"What is your intuition? Many people without training in statistical inference judge the probability to be rather high, typically between $0.7$ and $0.9$. The correct answer is much lower, less than $0.1$, as we can see by running the following:"

# ╔═╡ b46b5f0d-cf71-46a3-890c-839841262cb3
breast_cancer = @~ Bernoulli(0.01)

# ╔═╡ 86bbdeb9-4aa4-4355-bc7c-31b2b3948c5a
positive_mammogram(ω) = 
	breast_cancer(ω) ? (@~ Bernoulli(0.8))(ω) : (@~ Bernoulli(0.096))(ω)

# ╔═╡ 3fe0fbb3-5033-4e29-9906-a8f098bd6243
breast_cancer_cond = breast_cancer |ᶜ positive_mammogram

# ╔═╡ e91df32b-96ad-497a-b6fb-bbc81ea7a848
viz(randsample(breast_cancer_cond, 1000))

# ╔═╡ 7fd959ec-c6a4-43f8-b6a8-4124a843e816
md"[Tversky and Kahneman (1974)](https://scholar.google.com/scholar?q=%22Judgment%20under%20uncertainty%3A%20Heuristics%20and%20biases%22) named this kind of judgment _error base rate neglect_, because in order to make the correct judgment, one must realize that the key contrast is between the _base rate_ of the disease, $0.01$ in this case, and the false alarm rate or probability of a positive mammogram given no breast cancer, $0.096$. The false alarm rate (or FAR for short) seems low compared to the probability of a positive mammogram given breast cancer (the likelihood), but what matters is that it is almost ten times higher than the base rate of the disease. All three of these quantities are needed to compute the probability of having breast cancer given a positive mammogram using Bayes’ rule for posterior conditional probability:"

# ╔═╡ 23a934b7-9373-42a8-b016-9c61ee41a06a
md"$P(cancer ∣ positive  mammogram) = \dfrac{P(positive   mammogram∣cancer)×P(cancer)}{P(positive mammogram)}$"

# ╔═╡ 3f3bc3ff-cefa-4322-9e8f-f76fe10c4f1a
md"$= \dfrac{0.8 × 0.01}{0.8 × 0.01 + 0.096 × 0.99} = 0.078$"

# ╔═╡ 6d0d1a4f-f818-48e7-bdfd-7ac1d5b5112e
md"[Gigerenzer and Hoffrage (1995)](https://scholar.google.com/scholar?q=%22How%20to%20improve%20Bayesian%20reasoning%20without%20instruction%3A%20Frequency%20formats.%22) showed that this kind of judgment can be made much more intuitive to untrained reasoners if the relevant probabilities are presented as “natural frequencies”, or the sizes of subsets of relevant possible outcomes:"

# ╔═╡ 7ca9ef97-deea-4007-87da-c675fceb731e
md"_On average, ten out of every $1000$ women at age $40$ who come in for a routine screen have breast cancer. Eight out of those ten women will get a positive mammography. Of the $990$ women without breast cancer, $95$ will also get a positive mammography. We assembled a sample of $1000$ women at age $40$ who participated in a routine screening. How many of those who got a positive mammography do you expect to actually have breast cancer?_"

# ╔═╡ 7e57f398-ce81-4027-9104-8e0e1e9ee730
md"""
Now one can practically read off the answer from the problem formulation: $8$ out of $103$ ($95$ + $8$) women in this situation will have breast cancer.

Gigerenzer (along with Cosmides, Tooby and other colleagues) has argued that this formulation is easier because of evolutionary and computational considerations: human minds have evolved to count and compare natural frequencies of discrete events in the world, not to add, multiply and divide decimal probabilities. But this argument alone cannot account for the very broad human capacity for causal reasoning. We routinely make inferences for which we haven’t stored up sufficient frequencies of events observed _in the world_. (And often for which no one has told us the relevant frequencies, although perhaps we have been told about degrees of causal strength or base rates in the form of probabilities or other linguistic encoding).

However, the basic idea that the mind is good at manipulating frequencies of situations, but bad at arithmetic on continuous probability values, can be extended to cope with novel situations if the frequencies that are manipulated can be frequencies of _imagined_ situations.
"""

# ╔═╡ 2e0d73cd-59a1-4588-a7a8-d8847a340156
md"""
Recall that probabilistic programs explicitly give instructions for sampling imagined situations, and only implicitly specify probability distributions. If human inference is similar to an Omega inference then it would readily create and manipulate imagined situations, and this could explain both why the frequency framing of Bayesian probability judgment is natural to people and how people cope with rarer and more novel situations.

Selecting just the 106 hypothetical cases of women with a positive mammogram, and computing the fraction of those who also have breast cancer (7/106), corresponds exactly to rejection sampling (used in `randsample`). Thus, we have used the causal representation in the above program to manufacture frequencies which can be used to arrive at the inference that relatively few women with positive mammograms actually have breast cancer.
"""

# ╔═╡ 3dc46597-1ca5-4d58-9532-2f67f5b1a28b
md"Yet unlike rejection sampler, people are quite bad at reasoning in this scenario. Why? One answer is that people don’t represent their knowledge in quite the form of this simple program. Indeed, [Krynski and Tenenbaum (2007)](https://scholar.google.com/scholar?q=%22The%20role%20of%20causality%20in%20judgment%20under%20uncertainty.%22) have argued that human statistical judgment is fundamentally based on conditioning more explicit causal models: they suggested that “base rate neglect” and other judgment errors may occur when people are given statistical information that cannot be easily mapped to the parameters of the causal models they intuitively adopt to describe the situation. In the above example, they suggested that the notion of a false alarm rate is not intuitive to many people—particularly when the false alarm rate is ten times higher than the base rate of the disease that the test is intended to diagnose! They showed that “base rate neglect” could be eliminated by reformulating the breast cancer problem in terms of more intuitive causal models. For example, consider their version of the breast cancer problem (the exact numbers and wording differed slightly):"

# ╔═╡ bfd2f1dd-f8ee-4a04-9790-7cf4c65f0b32
md"_$1\%$ of women at age $40$ who participate in a routine screening will have breast cancer. Of those with breast cancer, $80\%$ will receive a positive mammogram. $20\%$ of women at age $40$ who participate in a routine screening will have a benign cyst. Of those with a benign cyst, $50\%$ will receive a positive mammogram due to unusually dense tissue of the cyst. All others will receive a negative mammogram. Suppose that a woman in this age group has a positive mammography in a routine screening. What is the probability that she actually has breast cancer?_"

# ╔═╡ d139a7ad-67d2-4186-b4dc-8e0988676379
md"This question is easy for people to answer—empirically, just as easy as the frequency-based formulation given above. We may conjecture this is because the relevant frequencies can be computed from a simple inference on the following more intuitive causal model:"

# ╔═╡ 863f8857-537e-47f0-b0e9-2c5f8d388bef
breast_cancer_ = @~ Bernoulli(0.01)

# ╔═╡ bd2379b7-f017-4ede-8ca7-bd7167fe0ea3
benign_cyst = @~ Bernoulli(0.2)

# ╔═╡ 85ecb534-af6d-468f-83f8-a26684080bb8
positive_mammogram_ = 
		(breast_cancer_ &ₚ @~ Bernoulli(0.8)) |ₚ (benign_cyst &ₚ @~ Bernoulli())

# ╔═╡ 08a67559-33e6-479a-932f-d868b638dd6e
breast_cancer_cond_ = breast_cancer_ |ᶜ positive_mammogram_

# ╔═╡ f7d7f3b0-4ed0-49f1-95cb-92980addc556
viz(randsample(breast_cancer_cond_, 1000))

# ╔═╡ cf392238-64aa-4b3e-bdca-cb9191e4b73d
md"Because this causal model is more intuitive to people, they can imagine the appropriate situations, despite having been given percentages rather than frequencies. What makes this causal model more intuitive than the one above with an explicitly specified false alarm rate? Essentially we have replaced probabilistic dependencies on the “non-occurrence” of events (e.g., the dependence of a positive mammogram on _not_ having breast cancer) with dependencies on explicitly specified alternative causes for observed effects (e.g., the dependence of a positive mammogram on having a benign cyst).

A causal model framed in this way can scale up to significantly more complex situations. Recall our more elaborate medical diagnosis network from the previous section, which was also framed in this way using noisy-logical functions to describe the dependence of symptoms on disease:"

# ╔═╡ d33a4d7a-655c-4e0d-8577-269b3c788471
begin
	lung_cancer = @~ Bernoulli(0.01)
	TB = @~ Bernoulli(0.005)
	stomach_flu = @~ Bernoulli(0.1)
	cold = @~ Bernoulli(0.2)
	other = @~ Bernoulli(0.1)
end

# ╔═╡ d438dd9c-5f2c-4417-956d-62e7b7b863d0
cough = pw(|, 
		(cold &ₚ @~ Bernoulli()), 
		(lung_cancer &ₚ @~ Bernoulli(0.3)), 
		(TB &ₚ @~ Bernoulli(0.7)), 
		(other &ₚ @~ Bernoulli(0.01))
)

# ╔═╡ 1458c2a1-bacf-4433-9984-16be0b76eed3
fever = pw(|, 
	(cold &ₚ @~ Bernoulli(0.3)), 
	(stomach_flu &ₚ @~ Bernoulli()), 
	(TB &ₚ @~ Bernoulli(0.1)), 
	(other &ₚ @~ Bernoulli(0.01))
)

# ╔═╡ db5b3112-9ab0-4f53-9f5a-0c6f6714a87e
chest_pain = pw(|, 
	(lung_cancer &ₚ @~ Bernoulli()), 
	(TB &ₚ @~ Bernoulli()), 
	(other &ₚ @~ Bernoulli(0.01))
)

# ╔═╡ 4596dd12-94d6-4c5f-a813-93681cdca973
shortness_of_breath = pw(|, 
	(lung_cancer &ₚ @~ Bernoulli()), 
	(TB &ₚ @~ Bernoulli(0.2)), 
	(other &ₚ @~ Bernoulli(0.01))
)

# ╔═╡ 3ad98347-598b-4b61-8a63-461cd98e1f89
lung_cancer_cond = lung_cancer |ᶜ pw(&, cough, chest_pain, shortness_of_breath)

# ╔═╡ 45700e49-1d29-41f6-89ef-629bb0001b21
TB_cond = TB |ᶜ pw(&, cough, chest_pain, shortness_of_breath)

# ╔═╡ 9c7f207d-d169-4a5c-8f84-7da82a8a7a45
viz(randsample(lung_cancer_cond, 1000))

# ╔═╡ 58ae52e2-8826-42bd-8e20-d58a15537a6e
viz(randsample(TB_cond, 1000))

# ╔═╡ e6d89bab-589a-4c9b-b912-b27d414b5954
md"""
You can use this model to infer conditional probabilities for any subset of diseases conditioned on any pattern of symptoms. Try varying the symptoms in the conditioning set or the diseases in the inference, and see how the model’s inferences compare with your intuitions. For example, what happens to inferences about lung cancer and TB in the above model if you remove chest pain and shortness of breath as symptoms? (Why? Consider the alternative explanations.) More generally, we can condition on any set of events – any combination of symptoms and diseases – and query any others. We can also condition on the negation of an event: how does the probability of lung cancer (versus TB) change if we observe that the patient does not have a fever (i.e. condition on `!ₚ(fever)`), does not have a cough, or does not have either symptom?

As we discussed above, Omega thus effectively encodes the answers to a very large number of possible questions in a very compact form. In the program above, there are $3^9=19683$ possible simple conditions corresponding to conjunctions of events or their negations (because the program has $9$ stochastic Boolean-valued functions, each of which can be observed true, observed false, or not observed). Then for each of those conditions there are a roughly comparable number of queries, corresponding to all the possible conjunctions of variables that can be in the return value expression. This makes the total number of simple questions encoded on the order of $100$ million. We are beginning to see the sense in which probabilistic programming provides the foundations for constructing a _language of thought_: a finite system of knowledge that compactly and efficiently supports an infinite number of inference and decision tasks.

Expressing our knowledge as a probabilistic program of this form also makes it easy to add in new relevant knowledge we may acquire, without altering or interfering with what we already know. For instance, suppose we decide to consider behavioral and demographic factors that might contribute causally to whether a patient has a given disease:
"""

# ╔═╡ f7578fd6-4928-4d95-8bb2-bd68e68e3744
begin
	works_in_hospital = @~ Bernoulli(0.01)
    smokes = @~ Bernoulli(0.2)
    lung_cancer_ = (@~ Bernoulli(0.01)) |ₚ (smokes &ₚ @~ Bernoulli(0.02))
    TB_ = (@~ Bernoulli(0.005)) |ₚ (works_in_hospital &ₚ @~ Bernoulli(0.01))
    cold_ = (@~ Bernoulli(0.2)) |ₚ (works_in_hospital &ₚ @~ Bernoulli(0.25))
end

# ╔═╡ 72d53f12-d2a1-4ddc-9c8b-5694c85a6d7b
cough_ = pw(|, 
	(cold_ &ₚ @~ Bernoulli()), 
	(lung_cancer_ &ₚ @~ Bernoulli(0.3)), 
	(TB_ &ₚ @~ Bernoulli(0.7)), 
	(other &ₚ @~ Bernoulli(0.01))
)

# ╔═╡ d94c1ee5-e729-4abe-9e84-68a1816cc886
fever_ = pw(|, 
	(cold_ &ₚ @~ Bernoulli(0.3)), 
	(stomach_flu &ₚ @~ Bernoulli()), 
	(TB_ &ₚ @~ Bernoulli(0.1)), 
	(other &ₚ @~ Bernoulli(0.01))
)

# ╔═╡ ffa7d097-16ea-4e17-8aae-6e36302fe6cc
chest_pain_ = pw(|, 
	(lung_cancer_ &ₚ @~ Bernoulli()), 
	(TB_ &ₚ @~ Bernoulli()), 
	(other &ₚ @~ Bernoulli(0.01))
)

# ╔═╡ 8796daf8-ed11-4131-9e2f-c629cf65d02b
shortness_of_breath_ = pw(|, 
	(lung_cancer_ &ₚ @~ Bernoulli()), 
	(TB_ &ₚ @~ Bernoulli(0.2)), 
	(other &ₚ @~ Bernoulli(0.01))
)

# ╔═╡ 488000ac-4d99-436d-91eb-af526773ca40
lung_cancer_cond_ = lung_cancer_ |ᶜ pw(&, cough_, chest_pain_, shortness_of_breath_)

# ╔═╡ 3025af44-0eab-4fcb-bc4f-5f1a25434184
TB_cond_ = TB_ |ᶜ pw(&, cough_, chest_pain_, shortness_of_breath_)

# ╔═╡ 3fee9f6a-87b9-4097-8e66-42aab40f9e17
viz(randsample(lung_cancer_cond_, 1000))

# ╔═╡ 960755a2-138d-45a0-a0d7-872208e36023
viz(randsample(TB_cond_, 1000))

# ╔═╡ d6d61f0f-9ec7-4200-bdd6-7f3d3ee99d55
md"Under this model, a patient with coughing, chest pain and shortness of breath is likely to have either lung cancer or TB. Modify the above code to see how these conditional inferences shift if you also know that the patient smokes or works in a hospital (where they could be exposed to various infections, including many worse infections than the typical person encounters). More generally, the causal structure of knowledge representation in a probabilistic program allows us to model intuitive theories that can grow in complexity continually over a lifetime, adding new knowledge without bound."
=======
md"## Hypothetical Reasoning"

# ╔═╡ bcfd08bc-91f6-4745-aeb0-9e7ecd218388

>>>>>>> dd838e4 (Add ch 2)

# ╔═╡ Cell order:
# ╠═f532f3b0-5293-11ec-104c-dba9836ec3d1
# ╟─711c87ea-9ec0-4957-bc00-641e2dd6eaec
# ╟─877ff248-596c-4755-8085-281d1752ec5b
# ╟─a0d93e64-92ca-4d32-905f-b99e5f3780d5
# ╟─2a4caee4-f64a-4f2d-9b82-44df111c2c8b
# ╟─59f09e31-aa76-4b73-b841-e6192841060e
# ╟─bbbac3fa-3708-4d4e-87e1-01143a1b3eb0
# ╟─60be7683-0b4c-467b-ba72-4d687bff9a1b
<<<<<<< HEAD
# ╟─bcfd08bc-91f6-4745-aeb0-9e7ecd218388
# ╟─70d10737-6ec4-43fc-822d-a7db70fce4d0
# ╠═c794ee68-86a0-49f8-9054-2f5efadd053d
# ╠═8091bb8c-2f29-4b5c-b2b1-15c3ead9b70f
# ╠═af8e6721-0af4-42f3-9c50-2e243524260b
# ╠═78fcf1a2-19f0-4b6a-9a45-3af4b45b20f2
# ╠═ae9646da-2e65-4566-8953-a761864b924f
# ╟─a6072ac1-8586-47c0-add5-f076ea6b71d8
# ╠═0efba943-013b-40cc-8819-ba6852214543
# ╠═ca821906-6411-43c7-bbd3-93b72978a767
# ╟─9bc0bc9f-51f2-4b8c-8ced-eb015ef5c4de
# ╠═44be800d-abc8-476f-80d3-7f5a733f8c31
# ╠═aa6705f4-1c2d-4556-954d-f3b198f7f3ba
# ╟─b41f7e5d-61e1-4fa0-8fd1-327d0b3d4ae6
# ╟─525fd3ab-ed0b-4d49-ba9c-6d71aec802a8
# ╠═7fe0569f-772b-4cf6-bed2-f79a7f10ae17
# ╠═8321b19d-2577-4809-aa00-f12f90a6f2c2
# ╠═46f605cf-bb66-4845-b33f-1ded5fd08d75
# ╠═e1e88bc4-9c29-4465-b73f-52737c42ca19
# ╠═b15a1f8e-2427-42a1-a3be-ee2b8d49adf4
# ╠═e0c9c0d1-cd53-4a0f-858b-ee60b70e2a54
# ╟─7be5d173-d327-4126-9764-89183d23ddb1
# ╟─6b67ec11-2e8a-414f-85ee-16a5f2f9eb7e
# ╟─ec2cecc4-0cfd-4081-b1a2-2dc0da6b6278
# ╠═bad9fc35-8d7d-4407-8e1a-f978a616c8fb
# ╠═f359ee3c-74c6-4d97-8e72-aaa3d23d85cd
# ╠═abc5ca50-e65e-40a0-8e5a-bb3f95388d82
# ╠═20670696-b03e-4098-ac45-5dce59d389ed
# ╠═aaedbd7a-c66e-482c-878a-2c7ce366c482
# ╟─a1350291-9ed6-468e-aebf-00985d4f183b
# ╟─81eea9c8-c365-4bf0-91e9-e0603034f8bc
# ╟─60fca96c-2b8f-48e8-9d3c-4589e68743d7
# ╠═e76cbb9f-fbd3-4d63-8030-8d3dcc127240
# ╠═648b4577-6464-4419-b53c-c6deebf43c10
# ╟─737a2418-1054-45c7-adb3-fa294bee458a
# ╠═f8062e02-3c7b-4b8b-a220-b211aa6864d8
# ╠═261459cb-06ec-4c6b-b8ec-88121b0c7545
# ╠═48e557ae-aaf3-4d59-8728-85634242c79b
# ╠═5e5073bd-6866-4adb-863e-661a0a9b3bdf
# ╟─967c0589-e549-40d1-9ed3-8ca71a380b4e
# ╟─b3ae8730-18a4-488e-bbda-4402576a6439
# ╟─3a8aef72-4569-4b2d-b6f8-596a7ccd1113
# ╠═07cfafb4-bc93-4c80-9c63-688f5afb8176
# ╠═ca86dc25-90a8-49d1-b69f-b2e073bdf9f6
# ╠═4509461c-6934-4cec-bd25-40334b390dcd
# ╠═ac581943-b6db-4e71-bd72-2de782fe6eba
# ╠═0d99389d-59dd-4c49-b603-94ad8fd731f1
# ╠═593c3edc-3dda-4ada-bd8a-cdf9d81baa7e
# ╠═bf5e6b09-47f1-475c-9a02-ba9ace529f85
# ╟─b15fc51a-f0bf-43bd-9e50-abf844108e54
# ╠═28f2db2a-2c93-41ff-986e-2f48a374a90e
# ╠═5cc66ffc-9751-47d6-b9a9-5c37747b0a63
# ╠═7e8efa1e-9bb7-494b-9120-97eedc5777fb
# ╟─a51f14db-1c6d-441d-b4bb-d9fe7fc90b21
# ╠═3d6a5835-356c-45ee-b3b7-c25b6d5da4b8
# ╠═1e9f74fd-a19c-4a2b-8065-5dd44be6092a
# ╠═b3dad899-f286-4145-9725-afce161d61f7
# ╠═6d9b2966-05d1-4468-8e53-36ccfd07bf75
# ╟─e3d5606f-7d01-44db-8449-81fa67c7209d
# ╟─0538557f-737a-4673-8db3-07c2a736a4af
# ╟─e4276339-e6bf-4781-8657-e2ebfb50ebfa
# ╟─f1f17f23-43f6-457c-a6a1-844c43bda1f3
# ╠═b46b5f0d-cf71-46a3-890c-839841262cb3
# ╠═86bbdeb9-4aa4-4355-bc7c-31b2b3948c5a
# ╠═3fe0fbb3-5033-4e29-9906-a8f098bd6243
# ╠═e91df32b-96ad-497a-b6fb-bbc81ea7a848
# ╟─7fd959ec-c6a4-43f8-b6a8-4124a843e816
# ╟─23a934b7-9373-42a8-b016-9c61ee41a06a
# ╟─3f3bc3ff-cefa-4322-9e8f-f76fe10c4f1a
# ╟─6d0d1a4f-f818-48e7-bdfd-7ac1d5b5112e
# ╟─7ca9ef97-deea-4007-87da-c675fceb731e
# ╟─7e57f398-ce81-4027-9104-8e0e1e9ee730
# ╟─2e0d73cd-59a1-4588-a7a8-d8847a340156
# ╟─3dc46597-1ca5-4d58-9532-2f67f5b1a28b
# ╟─bfd2f1dd-f8ee-4a04-9790-7cf4c65f0b32
# ╟─d139a7ad-67d2-4186-b4dc-8e0988676379
# ╠═863f8857-537e-47f0-b0e9-2c5f8d388bef
# ╠═bd2379b7-f017-4ede-8ca7-bd7167fe0ea3
# ╠═85ecb534-af6d-468f-83f8-a26684080bb8
# ╠═08a67559-33e6-479a-932f-d868b638dd6e
# ╠═f7d7f3b0-4ed0-49f1-95cb-92980addc556
# ╟─cf392238-64aa-4b3e-bdca-cb9191e4b73d
# ╠═d33a4d7a-655c-4e0d-8577-269b3c788471
# ╠═d438dd9c-5f2c-4417-956d-62e7b7b863d0
# ╠═1458c2a1-bacf-4433-9984-16be0b76eed3
# ╠═db5b3112-9ab0-4f53-9f5a-0c6f6714a87e
# ╠═4596dd12-94d6-4c5f-a813-93681cdca973
# ╠═3ad98347-598b-4b61-8a63-461cd98e1f89
# ╠═45700e49-1d29-41f6-89ef-629bb0001b21
# ╠═9c7f207d-d169-4a5c-8f84-7da82a8a7a45
# ╠═58ae52e2-8826-42bd-8e20-d58a15537a6e
# ╟─e6d89bab-589a-4c9b-b912-b27d414b5954
# ╠═f7578fd6-4928-4d95-8bb2-bd68e68e3744
# ╠═72d53f12-d2a1-4ddc-9c8b-5694c85a6d7b
# ╠═d94c1ee5-e729-4abe-9e84-68a1816cc886
# ╠═ffa7d097-16ea-4e17-8aae-6e36302fe6cc
# ╠═8796daf8-ed11-4131-9e2f-c629cf65d02b
# ╠═488000ac-4d99-436d-91eb-af526773ca40
# ╠═3025af44-0eab-4fcb-bc4f-5f1a25434184
# ╠═3fee9f6a-87b9-4097-8e66-42aab40f9e17
# ╠═960755a2-138d-45a0-a0d7-872208e36023
# ╟─d6d61f0f-9ec7-4200-bdd6-7f3d3ee99d55
=======
# ╠═bcfd08bc-91f6-4745-aeb0-9e7ecd218388
>>>>>>> dd838e4 (Add ch 2)
