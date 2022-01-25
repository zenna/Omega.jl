### A Pluto.jl notebook ###
# v0.17.6

using Markdown
using InteractiveUtils

# ╔═╡ 69f5f64e-7ae3-11ec-2649-111a12da3b87
using Pkg

# ╔═╡ b6705156-3d39-44d4-80dd-4794b1f0b0e6
Pkg.activate(Base.current_project())

# ╔═╡ 020a088e-d753-4030-8a21-d3be00a2d551
using Omega

# ╔═╡ 400c3307-6adb-49a5-b083-dffee6f60223
using Distributions

# ╔═╡ 2b3e6015-5a91-4fa6-8efc-eadc121a0a07
using UnicodePlots

# ╔═╡ d8972d9c-f8a7-40e1-829f-0012dbf992a6
Pkg.instantiate()

# ╔═╡ 709ad29c-9c48-4c5a-aeff-b6ddaee6cbdf
md"## Agents as Probabilistic Programs"

# ╔═╡ 0ee2ac6a-5616-4804-b648-ccc76e421dbf
md"### Introduction"

# ╔═╡ c59223df-0dd5-4776-8fd8-53b0269357ae
md"Our goal is to implement agents that compute rational policies. Policies are plans for achieving good outcomes in environments where:

* The agent makes a sequence of distinct choices, rather than choosing once.

* The environment is stochastic (or “random”).

* Some features of the environment are initially unknown to the agent. (So the agent may choose to gain information in order to improve future decisions.)

This section begins with agents that solve the very simplest decision problems. These are trivial one-shot problems, where the agent selects a single action (not a sequence of actions). We use WebPPL to solve these problems in order to illustrate the core concepts that are necessary for the more complex problems in later chapters."

# ╔═╡ 6721abb4-24fd-425c-ae6a-e7c676c17d49
md"### One shot decisions in a deterministic world"

# ╔═╡ 6a90dea1-7eb0-4e2e-8275-d68fa507ee11
md" In a one-shot decision problem an agent makes a single choice between a set of actions, each of which has potentially distinct consequences. A rational agent chooses the action that is best in terms of his or her own preferences. Often, this depends not on the action itself being preferred, but only on its consequences.

For example, suppose Tom is choosing between restaurants and all he cares about is eating pizza. There’s an Italian restaurant and a French restaurant. Tom would choose the French restaurant if it offered pizza. Since it does not offer pizza, Tom will choose the Italian.

Tom selects an action $a \in A$ from the set of all actions. The actions in this case are {“eat at Italian restaurant”, “eat at French restaurant”}. The consequences of an action are represented by a transition function $T \colon S \times A \to S$ from state-action pairs to states. In our example, the relevant state is whether or not Tom eats pizza. Tom’s preferences are represented by a real-valued utility function $U \colon S \to \mathbb{R}$, which indicates the relative goodness of each state.

Tom’s *decision* rule is to take action aa that maximizes utility, i.e., the action

${\arg \max}_{a \in A} U(T(s,a))$
In Omega, we can implement this utility-maximizing agent as a function maxAgent that takes a state $s \in S$ as input and returns an action. For Tom’s choice between restaurants, we assume that the agent starts off in a state \"initialState\", denoting whatever Tom does before going off to eat. The program directly translates the decision rule above using the higher-order function argmax."



# ╔═╡ 87e761dc-4568-4aa0-9727-fcfecbc308b8
actions = ["italian", "french"]

# ╔═╡ 6a5410b6-6554-470d-aead-441e27a6fba3
function transitions(state, action)
	if (action == "italian")
		return "pizza"
	else
		return "steak frites"
	end
end

# ╔═╡ 51001065-d985-4a04-8636-43c75c5d502e
function utility(state)
	if (state == "pizza")
		return 10
	else
		return 0
	end
end

# ╔═╡ 69ccad80-cc34-474c-b680-99667eefde7a
function max_agent(state)
	return actions[argmax([utility(transitions(state,a)) for a in actions])]
end

# ╔═╡ 391efe20-4df7-4ad7-adf8-05e7a58d6e09
R = max_agent("initial_state")

# ╔═╡ a3971c71-7649-46ec-8167-35df041a7a51
md"Choice in initial state: $R"

# ╔═╡ 78ef3e4a-ec06-40ab-9497-459b2a2cbffe
md"**Exercise**: Which parts of the code can you change in order to make the agent choose the French restaurant?"

# ╔═╡ e4d938c3-7b5a-4e58-8210-1aeea20eeafd
md"There is an alternative way to compute the optimal action for this problem. The idea is to treat choosing an action as an inference problem. The previous chapter showed how we can infer the probability that a coin landed Heads from the observation that two of three coins were Heads."

# ╔═╡ 64e4a6d3-a1eb-46af-b5d3-10d242f19431
a = @~Bernoulli() 

# ╔═╡ fee11783-344c-4bce-a2d5-878c077d223a
b = @~Bernoulli()

# ╔═╡ 3e35aec1-2d38-4bfb-aa8f-0e6d58d2fa68
c = @~Bernoulli()

# ╔═╡ 38b3425d-0210-4cd4-aef3-bec2f8ca42cb
a_ = a |ᶜ (a +ₚ b +ₚ c ==ₚ 2)

# ╔═╡ 0913d477-35ad-4799-b3b2-dea8d592f2f7
histogram(randsample(a_,1000))

# ╔═╡ dec711eb-38b6-4b0b-99f9-aec119b9f17a
md" The same inference machinery can compute the optimal action in Tom’s decision problem. We sample random actions with uniformDraw and condition on the preferred outcome happening. Intuitively, we imagine observing the consequence we prefer (e.g. pizza) and then infer from this the action that caused this consequence.

This idea is known as “planning as inference” (Botvinick and Toussaint, 2012). It also resembles the idea of “backwards chaining” in logical inference and planning. The inferenceAgent solves the same problem as maxAgent, but uses planning as inference:"

# ╔═╡ eeb681e0-6076-4db4-9af0-55bafc2a6d18
md"**Exercise**: Change the agent’s goals so that they choose the French restaurant."

# ╔═╡ bf4c19ea-324b-4a42-aa35-e3a2ef589001
md"### One-shot decisions in a stochastic world"

# ╔═╡ d0013c7d-8c5c-41c9-abde-acee0a6206eb
md" In the previous example, the transition function from state-action pairs to states was deterministic and so described a deterministic world or environment. Moreover, the agent’s actions were deterministic; Tom always chose the best action (“Italian”). In contrast, many examples in this tutorial will involve a stochastic world and a noisy “soft-max” agent.

Imagine that Tom is choosing between restaurants again. This time, Tom’s preferences are about the overall quality of the meal. A meal can be “bad”, “good” or “spectacular” and each restaurant has good nights and bad nights. The transition function now has type signature $T\colon S \times A \to \Delta S$, where $\Delta S$ represents a distribution over states. Tom’s decision rule is now to take the action a \in Aa∈A that has the highest average or expected utility, with the expectation $\mathbb{E}$ taken over the probability of different successor states $s' \sim T(s,a)s$

$\max_{a \in A} \mathbb{E}( U(T(s,a)) )$

To represent this in Omega, we extend maxagent using the expectation function, which maps a distribution with finite support to its (real-valued) expectation:
"


# ╔═╡ b98d669a-9de9-42f2-a470-c52fb51c4538
function transitions_soft(ω, action)
	
	nextStates = ["bad", "good", "spectacular"]
	nextProbs = (action == "italian") ? [0.2, 0.6, 0.2] : [0.05, 0.9, 0.05]
	z = @~Categorical(nextProbs)
	
	return nextStates[z(ω)]
end
	

# ╔═╡ 35572f02-c5db-4c87-b1b8-c1efcfaacec0
function utility_soft(state)
	table = Dict(
    "bad" => -10, 
    "good" => 6, 
    "spectacular" => 8
	)
	return table[state]
end

# ╔═╡ b402f49f-5f3f-45fb-8382-18ef33c86368
alpha = 1

# ╔═╡ bbc44566-2cc9-4f11-b65d-38133e563c05
function maxEUAgent(ω)
	return actions[argmax([
		mean(randsample(ω->utility_soft(transitions_soft(ω, a)),1000)) for a in actions
	])]
end

# ╔═╡ 170f9e54-43c5-4365-bdad-1a67751a59f9
randsample(ω->maxEUAgent(ω))

# ╔═╡ 9594eca1-6a8f-4cef-bdd6-066ff1912ebb
a_1 = a|ᶜ(a *ₚ b *ₚ c)

# ╔═╡ 56d185c5-80af-4f8d-8b1b-caf089a32735
histogram(randsample(a_1,1000))

# ╔═╡ 8cfb178a-7be2-4852-afa1-0485cfb8f08b
md"*Exercise*: Adjust the transition probabilities such that the agent chooses the Italian Restaurant."

# ╔═╡ 6be5b68a-71ca-4527-8bb1-a9ea76d3d7ef
function factorₚ(op, x, y, z...)
	return pw(^,2.718,pw(op, x, y, z...))
end

# ╔═╡ e10389c0-4947-4988-b446-f8c3eb29f2e5
a


# ╔═╡ 10027387-d3d2-448b-8209-b065b00030af
ω = defω()

# ╔═╡ b628689f-03e5-4867-82ee-23b6ef5dffbf
begin
	# Helper functions for probmods
	
	"To visualize the generated samples of a random variable"
	viz(var::Vector{T} where {T<:Union{String,Char}}) =
	    barplot(Dict(freqtable(var)))
	viz(var::Vector{<:Real}) = histogram(var, symbols = ["■"])
	viz(var::Vector{Bool}) = viz(string.(var))
	viz(var::Vector{NamedTuple{U, V}}) where {U, V} = 
	    barplot(Dict(freqtable(var)), ylabel = string(U[1], ", ", U[2]), xlabel = "Frequency")
	
	function viz_marginals(var::Vector{NamedTuple{U, V}}) where {U, V}
	    c = barplot(Dict(freqtable(string.(U[1], "_", map(x -> x[U[1]], var)))))
	    for i in 2:length(U)
	        barplot!(c, Dict(freqtable(string.(U[i], "_", map(x -> x[U[i]], var)))))
	    end
	    c
	end
	
	# Required aditional distributions -
	struct UniformDraw{T}
	    elem::T
	end
	(u::UniformDraw)(i, ω) =
	    u.elem[(i ~ DiscreteUniform(1, length(u.elem)))(ω)]
	
	struct Dirichlet{V}
	    α::V
	end
	Dirichlet(k::Int64, a::Real) = Dirichlet(a .* ones(k))
	
	function (d::Dirichlet)(i, ω)
	    gammas = [((i..., j) ~ Gamma(αj))(ω) for (j, αj) in enumerate(d.α)]
	    Σ = sum(gammas)
	    [gamma / Σ for gamma in gammas]
	end
	
	# Other utility functions
	pget(x) = i -> x[i]
end

# ╔═╡ 2453eb89-01f2-4663-9e2d-3758b3e205d5
function inference_agent(state)
	action = UniformDraw(actions)
	action_ = action |ᶜ transitions(state, action) ==ₚ "pizza"
	return action_
end

# ╔═╡ b8b16f86-524d-4186-9e8c-f84b88a11f7e
histogram(randsample(inference_agent("initialState"),1000))

# ╔═╡ Cell order:
# ╟─69f5f64e-7ae3-11ec-2649-111a12da3b87
# ╟─b6705156-3d39-44d4-80dd-4794b1f0b0e6
# ╟─d8972d9c-f8a7-40e1-829f-0012dbf992a6
# ╟─020a088e-d753-4030-8a21-d3be00a2d551
# ╟─400c3307-6adb-49a5-b083-dffee6f60223
# ╟─2b3e6015-5a91-4fa6-8efc-eadc121a0a07
# ╟─709ad29c-9c48-4c5a-aeff-b6ddaee6cbdf
# ╟─0ee2ac6a-5616-4804-b648-ccc76e421dbf
# ╟─c59223df-0dd5-4776-8fd8-53b0269357ae
# ╟─6721abb4-24fd-425c-ae6a-e7c676c17d49
# ╟─6a90dea1-7eb0-4e2e-8275-d68fa507ee11
# ╠═87e761dc-4568-4aa0-9727-fcfecbc308b8
# ╠═6a5410b6-6554-470d-aead-441e27a6fba3
# ╠═51001065-d985-4a04-8636-43c75c5d502e
# ╠═69ccad80-cc34-474c-b680-99667eefde7a
# ╠═391efe20-4df7-4ad7-adf8-05e7a58d6e09
# ╟─a3971c71-7649-46ec-8167-35df041a7a51
# ╟─78ef3e4a-ec06-40ab-9497-459b2a2cbffe
# ╟─e4d938c3-7b5a-4e58-8210-1aeea20eeafd
# ╠═64e4a6d3-a1eb-46af-b5d3-10d242f19431
# ╠═fee11783-344c-4bce-a2d5-878c077d223a
# ╠═3e35aec1-2d38-4bfb-aa8f-0e6d58d2fa68
# ╠═38b3425d-0210-4cd4-aef3-bec2f8ca42cb
# ╠═0913d477-35ad-4799-b3b2-dea8d592f2f7
# ╟─dec711eb-38b6-4b0b-99f9-aec119b9f17a
# ╠═2453eb89-01f2-4663-9e2d-3758b3e205d5
# ╠═b8b16f86-524d-4186-9e8c-f84b88a11f7e
# ╟─eeb681e0-6076-4db4-9af0-55bafc2a6d18
# ╟─bf4c19ea-324b-4a42-aa35-e3a2ef589001
# ╟─d0013c7d-8c5c-41c9-abde-acee0a6206eb
# ╠═b98d669a-9de9-42f2-a470-c52fb51c4538
# ╠═35572f02-c5db-4c87-b1b8-c1efcfaacec0
# ╠═b402f49f-5f3f-45fb-8382-18ef33c86368
# ╠═bbc44566-2cc9-4f11-b65d-38133e563c05
# ╠═170f9e54-43c5-4365-bdad-1a67751a59f9
# ╠═9594eca1-6a8f-4cef-bdd6-066ff1912ebb
# ╠═56d185c5-80af-4f8d-8b1b-caf089a32735
# ╟─8cfb178a-7be2-4852-afa1-0485cfb8f08b
# ╠═6be5b68a-71ca-4527-8bb1-a9ea76d3d7ef
# ╠═e10389c0-4947-4988-b446-f8c3eb29f2e5
# ╠═10027387-d3d2-448b-8209-b065b00030af
# ╟─b628689f-03e5-4867-82ee-23b6ef5dffbf
