### A Pluto.jl notebook ###
# v0.18.4

using Markdown
using InteractiveUtils

# ╔═╡ 6ac11500-66e7-11ec-2275-674c73ca7b14
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    using Omega, Distributions, UnicodePlots, OmegaExamples
end

# ╔═╡ 79ff99ed-07cc-4de5-adf1-312e89bb4445
md"""
As we noted in an earlier chapter, there is an interesting parallel between `randsample`, which separates model specification from inference methods. For most of this book we are interested in the _computational_ level of describing what people know about the world and what inferences that knowledge licenses. That is, we treat the variables as the scientific hypothesis, and the optional (including `alg`) arguments as an engineering detail needed to derive predictions. We can make a great deal of progress with this abstraction.

Is it reasonable to interpret the inference algorithms that we borrow from statistics as psychological hypotheses at the algorithmic level? Which _algorithm_ does the brain use for inference? Could it be MCMC? Enumeration?

If we take the algorithms for inference as psychological hypotheses, then the approximation and resource-usage characteristics of the algorithms will be the signature phenomena of interest.

### How is uncertainty represented?

A signature of probabilistic (“Bayesian”) cognitive models is the central role of uncertainty. Generative models, our main notion of knowledge, capture uncertain causal processes. After making observations or assumptions, conditional random variables capture uncertain answers. At the computational level we work with this uncertainty by manipulating variables in Omega, without needing to explore (much) how they are created or represented. Yet cognitively there is a key algorithmic question: how is uncertainty represented in the human mind?

We have at least three very different possible answers to this question:

* Explicit representation of probabilities.
* Parametric representation of distribution families.
* Sampling-based representations.

### Explicit representations
The most straightforward interpretation of Bayesian models at the algorithmic level is that explicit probabilities for different states are computed and represented. Attempts have been made to model how neural systems might capture these representations, via ideas such as probabilistic population codes. (See [Bayesian inference with probabilistic population codes](https://www.nature.com/articles/nn1790), Ma, Beck, Latham, Pouget (2006).)

Yet it is difficult to see how these explicit representations can scale up to real-world cognition.

### Approximate distribution representations
Another possible representation of uncertainty is via the parameters of a family of distributions. For instance, the mean and covariance of a Gaussian is a flexible and popular (in statistics) way to approximate a complex distirbution. It is thus possible that all uncertainty is represented in the human mind as parameters of some family. A version of this idea can be seen in the free energy hypothesis. (See [The free-energy principle: a unified brain theory?](https://www.nature.com/articles/nrn2787), Friston (2010).)

### The sampling hypothesis
Finally, it is possible that there is no explicit representation of uncertainty in the human mind. Instead, uncertainty is implicitly represented in the tendencies of a dynamical system. This is the sampling hypothesis: that the human mind has the ability to generate samples from conditional distributions when needed. Thus the mind implicitly represents an entire distribution, but can only work explicitly with a few samples from it.

We have seen a number of methods for creating dynamical systems that can sample from any desired distribution (rejection sampling, various Markov chain Monte Carlo methods, etc). This type of representation is thus possible in principle. What behavioural or neural signatures would we expect if it were correct? And _which_ of the many sampling methods might be neurally plausible?

As a first analysis, we can assume that the human mind is always capable of drawing perfect samples from the conditional distributions of interest (e.g. via rejection sampling) but doing so is costly in terms of time or energy. If we assume that only a few samples are going to be used by any individual in answering any question, a profound behavioural prediction arises: individuals’ choice probability will match the posterior probability distribution. Note that this is a somewhat radical departure from a “fully Bayesian” agent. If we assume a choice is to be made, with 100$ reward for the correct answer and no reward for incorrect answers, a rational (that is utility-maximizing) agent that explicitly represents the answer distribution should _always_ choose the most likely answer. Across a population of such agents we would see no variation in answers (assuming a priori identical beliefs). In contrast, an agent that has only a single sample from their answer distribution will choose this answer; across a population of such agents we would see answers distributed according to the answer distribution!

Let’s see this in practice in a simple example, where each person sees a coin of unknown probability flipped five times, coming up heads four of them. Each person is asked to bet on the next outcome:
"""

# ╔═╡ 24535e9c-ad99-4366-8514-71ac69ec25fe
weight = StdUniform{Float64}()

# ╔═╡ b050357f-596c-40d5-9bb2-83b87a95b268
function agent_belief(i, ω)
	w = (i ~ weight)(ω)
	a =  ((@uid, i...)~ Bernoulli(w)) |ᶜ (Variable(ω -> (i~ Binomial(5, w))(ω)) .== 4)
	a(ω)
end

# ╔═╡ 43d1f4e9-56a0-44bd-b9ad-177654dde799
agent_belief_samples(i) = randsample(ω -> agent_belief((@uid, i), ω), 1000)

# ╔═╡ 4eaf8a19-086a-460a-b6c7-0f1ae26648f0
max_agent(i) = 
	count(x -> x == true, agent_belief_samples(i)) > count(x -> x == false, agent_belief_samples(i))

# ╔═╡ 63465f7f-d200-4440-be50-c8ff39e2690a
max_agent_samples = map(i -> max_agent(i), 1:100)

# ╔═╡ b5800ad7-8c12-40c6-8af4-243351ab13d6
viz(max_agent_samples)

# ╔═╡ f7269ff3-606d-4494-9f0c-1771941c2312
sample_agent = map(i -> randsample(ω -> agent_belief((@uid, i), ω)), 1:1000)

# ╔═╡ 123df858-97c1-475e-b908-2e83c4009a13
viz(sample_agent)

# ╔═╡ ddb1ed00-7898-4234-a392-3d2970884185
md"""
The maximizing agent chooses the most likely outcome by examining the conditional probability they assign to outcomes – the result is all such agents choosing ‘true’. In contrast, a population of agents that each represents their belief with a single sample will choose ‘false’ about $13\%$ of the time. This behavioral signature – _probability matching_ – is in fact a very old and well studied psychological phenomenon. (See for instance, Individual Choice Behavior: A Theoretical Analysis, Luce (1959).)

Vul, Goodman, Griffiths, Tenenbaum (2014) further ask how many samples a rational agent _should_ use, if they are costly. This analysis explores the trade off between expected reward increase from more precise probability estimates (more samples) with resource savings from less work (fewer samples). The, somewhat surprising, result is that for a wide range of cost and reward assumptions it is optimal to decide based on only one, or a few, samples.
"""

# ╔═╡ Cell order:
# ╠═6ac11500-66e7-11ec-2275-674c73ca7b14
# ╟─79ff99ed-07cc-4de5-adf1-312e89bb4445
# ╠═24535e9c-ad99-4366-8514-71ac69ec25fe
# ╠═b050357f-596c-40d5-9bb2-83b87a95b268
# ╠═43d1f4e9-56a0-44bd-b9ad-177654dde799
# ╠═4eaf8a19-086a-460a-b6c7-0f1ae26648f0
# ╠═63465f7f-d200-4440-be50-c8ff39e2690a
# ╠═b5800ad7-8c12-40c6-8af4-243351ab13d6
# ╠═f7269ff3-606d-4494-9f0c-1771941c2312
# ╠═123df858-97c1-475e-b908-2e83c4009a13
# ╟─ddb1ed00-7898-4234-a392-3d2970884185
