### A Pluto.jl notebook ###
# v0.17.6

using Markdown
using InteractiveUtils

# ╔═╡ baa8189c-7d01-11ec-04a8-fbc26bfa45e1
using Pkg

# ╔═╡ 83a5a411-f64a-4d38-b859-a733494dedc7
Pkg.activate(Base.current_project())

# ╔═╡ ccda2fed-7382-4b00-823f-a374ad372eba
using Omega

# ╔═╡ c98f6ea9-8834-443d-a85f-97495befb2f2
using Distributions

# ╔═╡ 92ba821b-ac86-466c-a7c2-a0c3a8f56a6c
using UnicodePlots

# ╔═╡ 2021f2e8-c8af-44d3-ae4a-a9c214887d1b
Pkg.instantiate()

# ╔═╡ edc5ca10-a06a-47c2-993a-3ddcb097ee5c
md"## Introduction"

# ╔═╡ 3c299c8c-5951-484a-baa3-a03bc26737fd
md"Imagine a dataset that records how individuals move through a city. The figure below shows what a datapoint from this set might look like. It depicts an individual, who we’ll call Bob, moving along a street and then stopping at a restaurant. This restaurant is one of two nearby branches of a chain of Donut Stores. Two other nearby restaurants are also shown on the map." 

# ╔═╡ 8b3e5c76-016f-4fc8-9928-496bb5903aec


# ╔═╡ 8f27ede7-a8fd-4632-9e30-a31d6af157ed
md"Given Bob’s movements alone, what can we infer about his preferences and beliefs? Since Bob spent a long time at the Donut Store, we infer that he bought something there. Since Bob could easily have walked to one of the other nearby eateries, we infer that Bob prefers donuts to noodles or salad.

Assuming Bob likes donuts, why didn’t he choose the store closer to his starting point (“Donut South”)? The cause might be Bob’s beliefs and knowledge rather than his preferences. Perhaps Bob doesn’t know about “Donut South” because it just opened. Or perhaps Bob knows about Donut South but chose Donut North because it is open later.

A different explanation is that Bob intended to go to the healthier “Vegetarian Salad Bar”. However, the most efficient route to the Salad Bar takes him directly past Donut North, and once outside, he found donuts more tempting than salad.

We have described a variety of inferences about Bob which would explain his behavior. This tutorial develops models for inference that represent these different explanations and allow us to compute which explanations are most plausible. These models can also simulate an agent’s behavior in novel scenarios: for example, predicting Bob’s behavior if he looked for food in a different part of the city."

# ╔═╡ 7018a00e-75da-4664-a6ff-b6f5c735b72a
md"## Agents as programs"

# ╔═╡ ce729190-1e88-4c15-a784-36c5827d6f7c
md"### Making rational plans"

# ╔═╡ 5d5e61ac-7220-40df-bf92-8fe35111957c
md"Formal models of rational agents play an important role in economics (Rubinstein, 2012) and in the cognitive sciences (Chater and Oaksford, 2003) as models of human or animal behavior. Core components of such models are expected-utility maximization, Bayesian inference, and game-theoretic equilibria. These ideas are also applied in engineering and in artificial intelligence (Russell and Norvig, 1995) in order to compute optimal solutions to problems and to construct artificial systems that learn and reason optimally.

This tutorial implements utility-maximizing Bayesian agents as functional probabilistic programs. These programs provide a concise, intuitive translation of the mathematical specification of rational agents as code. The implemented agents explicitly simulate their own future choices via recursion. They update beliefs by exact or approximate Bayesian inference. They reason about other agents by simulating them (which includes simulating the simulations of others).

The first section of the tutorial implements agent models for sequential decision problems in stochastic environments. We introduce a program that solves finite-horizon MDPs, then extend it to POMDPs. These agents behave optimally, making rational plans given their knowledge of the world. Human behavior, by contrast, is often sub-optimal, whether due to irrational behavior or constrained resources. The programs we use to implement optimal agents can, with slight modification, implement agents with biases (e.g. time inconsistency) and with resource bounds (e.g. bounded look-ahead and Monte Carlo sampling)."

# ╔═╡ 6bdc00f4-349c-4939-88ed-96a285b0a78e
md"### Learning preferences from behavior"

# ╔═╡ 2d527865-0bb8-4872-bd05-f64e493e90d9
md"The example of Bob was not primarily about simulating a rational agent, but rather about the problem of learning (or inferring) an agent’s preferences and beliefs from their choices. This problem is important to both economics and psychology. Predicting preferences from past choices is also a major area of applied machine learning; for example, consider the recommendation systems used by Netflix and Facebook.

One approach to this problem is to assume the agent is a rational utility-maximizer, to assume the environment is an MDP or POMDP, and to infer the utilities and beliefs and predict the observed behavior. This approach is called “structural estimation” in economics (Aguirregabiria and Mira, 2010), “inverse planning” in cognitive science (Ullman et al., 2009), and “inverse reinforcement learning” (IRL) in machine learning and AI (Ng and Russell, 2000). It has been applied to inferring the perceived rewards of education from observed work and education choices, preferences for health outcomes from smoking behavior, and the preferences of a nomadic group over areas of land (see cites in Evans et al. (2015)).

Section IV shows how to infer the preferences and beliefs of the agents modeled in earlier chapters. Since the agents are implemented as programs, we can apply probabilistic programming techniques to perform this sort of inference with little additional code. We will make use of both exact Bayesian inference and sampling-based approximations (MCMC and particle filters)."

# ╔═╡ 68cb6272-03ad-47bc-afdd-53c81eb06e1e
md"## Taster: probabilistic programming"

# ╔═╡ 902c6c64-08e1-4ca8-a868-da40e4e9bff3
md"Our models of agents, and the corresponding inferences about agents, all run in “code boxes” in the browser, accompanied by animated visualizations of agent behavior. The language of the tutorial is WebPPL, an easy-to-learn probabilistic programming language based on Javascript (Goodman and Stuhlmüller, 2014). As a taster, here are two simple code snippets in WebPPL:"

# ╔═╡ 2778f538-2652-4662-956b-06ae6ae52d06
function coin()
	return randsample(@~Bernoulli()) ? "H" : "T"
end

# ╔═╡ d40106a2-9bf8-4bdd-ab7c-a894cf668d98
flips = [coin(), coin(), coin()]

# ╔═╡ 13bd0bed-9d1d-444f-9c0d-d042077efac2
function geometric(p, ω, i=0)
	flip = i~Bernoulli(p)
	return (flip(ω)) ? (1 + geometric(p,ω, i+1)) : 1
end

# ╔═╡ c560f336-4300-43bb-aa4a-d37cf07d4cf6
#The default version of Geometric implemented in Distributions
x = @~Geometric(0.3)

# ╔═╡ 9ca088e5-8b8f-44f2-bd8e-5fa1fd2e9e52
histogram(randsample(x,1000))

# ╔═╡ 3d0089ec-0965-4e49-a002-402aa8f10fa1
ω = defω()

# ╔═╡ Cell order:
# ╟─baa8189c-7d01-11ec-04a8-fbc26bfa45e1
# ╟─83a5a411-f64a-4d38-b859-a733494dedc7
# ╟─2021f2e8-c8af-44d3-ae4a-a9c214887d1b
# ╟─ccda2fed-7382-4b00-823f-a374ad372eba
# ╟─c98f6ea9-8834-443d-a85f-97495befb2f2
# ╟─92ba821b-ac86-466c-a7c2-a0c3a8f56a6c
# ╟─edc5ca10-a06a-47c2-993a-3ddcb097ee5c
# ╟─3c299c8c-5951-484a-baa3-a03bc26737fd
# ╠═8b3e5c76-016f-4fc8-9928-496bb5903aec
# ╟─8f27ede7-a8fd-4632-9e30-a31d6af157ed
# ╟─7018a00e-75da-4664-a6ff-b6f5c735b72a
# ╟─ce729190-1e88-4c15-a784-36c5827d6f7c
# ╟─5d5e61ac-7220-40df-bf92-8fe35111957c
# ╟─6bdc00f4-349c-4939-88ed-96a285b0a78e
# ╟─2d527865-0bb8-4872-bd05-f64e493e90d9
# ╟─68cb6272-03ad-47bc-afdd-53c81eb06e1e
# ╟─902c6c64-08e1-4ca8-a868-da40e4e9bff3
# ╠═2778f538-2652-4662-956b-06ae6ae52d06
# ╠═d40106a2-9bf8-4bdd-ab7c-a894cf668d98
# ╠═13bd0bed-9d1d-444f-9c0d-d042077efac2
# ╠═c560f336-4300-43bb-aa4a-d37cf07d4cf6
# ╠═9ca088e5-8b8f-44f2-bd8e-5fa1fd2e9e52
# ╟─3d0089ec-0965-4e49-a002-402aa8f10fa1
