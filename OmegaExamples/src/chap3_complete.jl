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

# ╔═╡ 19b5d039-e201-4e27-a3ec-633bcfaddba2
using FreqTables

# ╔═╡ 4c512b4b-dec8-4985-81a5-38c6701fbb45
using Random

# ╔═╡ a1a3bcf4-7270-4e89-9c44-69ca1a9c0d63
using Memoize

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

This section begins with agents that solve the very simplest decision problems. These are trivial one-shot problems, where the agent selects a single action (not a sequence of actions). We use Omega to solve these problems in order to illustrate the core concepts that are necessary for the more complex problems in later chapters."

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
function transitions_soft(action)
	
	nextStates = ["bad", "good", "spectacular"]
	nextProbs = (action == "italian") ? [0.2, 0.6, 0.2] : [0.05, 0.9, 0.05]
	z = @~Categorical(nextProbs)
	
	return ω->nextStates[z(ω)]
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

# ╔═╡ adacf3b8-8fd1-405a-a770-60d95a5ee8e0
md"The inferenceAgent, which uses the planning-as-inference idiom, can also be extended using expectation. Previously, the agent’s action was conditioned on leading to the best consequence (“pizza”). This time, Tom is not aiming to choose the action most likely to have the best outcome. Instead, he wants the action with better outcomes on average. This can be represented in inferenceAgent by switching from a condition statement to a factor statement. The condition statement expresses a “hard” constraint on actions: actions that fail the condition are completely ruled out. The factor statement, by contrast, expresses a “soft” condition. Technically, factor(x) adds x to the unnormalized log-probability of the program execution within which it occurs.

To illustrate factor, consider the following variant of the twoHeads example above. Instead of placing a hard constraint on the total number of Heads outcomes, we give each setting of a, b and c a score based on the total number of heads. The score is highest when all three coins are Heads, but even the “all tails” outcomes is not ruled out completely."

# ╔═╡ 6b636814-9317-4535-ad2b-91d706eaee5a
r = @~Bernoulli(pw(err,(pw(==ₛ,pw(+,a,b,c),2))))

# ╔═╡ c2bdd457-1e32-4df0-ac4d-eb4a8589065b
a_soft_condition = a |ᶜ r

# ╔═╡ 488545b2-a6d1-4d26-b60e-74c68f90c54f
md"As another example, consider the following short program:"

# ╔═╡ ca1bb7d1-9c59-48f2-bdeb-09fa1280061c
md"Without the factor statement, each value of the variable n has equal probability. Adding the factor statements adds n*n to the log-score of each value. To get the new probabilities induced by the factor statement we compute the normalizing constant given these log-scores. The resulting probability $P(y=2)$ is:

$P(y=2) = \frac {e^{2 \cdot 2}} { (e^{0 \cdot 0} + e^{1 \cdot 1} + e^{2 \cdot 2}) }$
Returning to our implementation as planning-as-inference for maximizing expected utility, we use a factor statement to implement soft conditioning:

"

# ╔═╡ 6d3b6072-d408-4229-8e82-bc4d641aa445
ω = defω()

# ╔═╡ d536e409-eeb2-4dcb-ac05-150c0d3658e7
md"The softMaxAgent differs in two ways from the maxEUAgent above. First, it uses the planning-as-inference idiom. Second, it does not deterministically choose the action with maximal expected utility. Instead, it implements soft maximization, selecting actions with a probability that depends on their expected utility. Formally, let the agent’s probability of choosing an action be $C(a;s)$ for $a \in A$ when in state $s \in S$. Then the softmax decision rule is:

$C(a; s) \propto e^{\alpha \mathbb{E}(U(T(s,a))) }$

The noise parameter $\alpha$ modulates between random choice (\alpha=0)(α=0) and the perfect maximization $(\alpha = \infty)$ of the maxEUAgent.

Since rational agents will always choose the best action, why consider softmax agents? One of the goals of this tutorial is to infer the preferences of agents (e.g. human beings) from their choices. People do not always choose the normatively rational actions. The softmax agent provides a simple, analytically tractable model of sub-optimal choice1, which has been tested empirically on human action selection (Luce, 2005). Moreover, it has been used extensively in Inverse Reinforcement Learning as a model of human errors (Kim et al., 2014), (Zheng et al., 2014). For this reason, we employ the softmax model throughout this tutorial. When modeling an agent assumed to be optimal, the noise parameter $\alpha$ can be set to a large value"

# ╔═╡ 5141dc4d-628b-4ee9-a796-a743092506af
md"Exercise: Monty Hall. In this exercise inspired by ProbMods, we will approach the classical statistical puzzle from the perspective of optimal decision-making. Here is a statement of the problem:

Alice is on a game show and she’s given the choice of three doors. Behind one door is a car; behind the others, goats. She picks door 1. The host, Monty, knows what’s behind the doors and opens another door, say No. 3, revealing a goat. He then asks Alice if she wants to switch doors. Should she switch?

Use the tools introduced above to determine the answer. Here is some code to get you started:"

# ╔═╡ d26a52ec-de29-4fc0-8795-ca156297e00d
mutable struct state_type
	prize_door
	monty_door
	alice_door
end

# ╔═╡ f6c15353-7a59-4ff0-9cda-15c59efc5c9a
doors = [1,2,3]

# ╔═╡ f09797b3-1791-4df6-b1b6-7be7a0c12f1f
md"Monty chooses a door that is neither Alice's door
nor the prize door"

# ╔═╡ 3ef019ba-3b5b-4db7-ad8b-b0e896f35a79
actions_mh = ["switch", "stay"]

# ╔═╡ 01e8ddf2-bc12-4525-8b09-15ce75e69385
state = state_type(1,2,3)

# ╔═╡ b51552a9-cdfe-4a56-a39a-db115123671e
md"If Alice switches, she randomly chooses a door that is
neither the one Monty showed nor her previous door"

# ╔═╡ f7d9ce97-f4e6-4998-a694-ab5a7d699605
md"Utility is high (say 10) if Alice's door matches the
prize door, 0 otherwise."

# ╔═╡ 29f238af-30d1-4591-bd6a-bcde4e92ba1c
function utility_mh(state)
	if (state.alice_door == state.prize_door)
		return 10
	else
		return 0
	end
end

# ╔═╡ 8b3be05c-b03a-43f9-9159-99d4eb4825ba


# ╔═╡ 74e914b2-8b06-4f84-84b0-ccde60ee3cf7
@memoize function 𝔼(x)
	Random.seed!(0)
	@show "Calculating Expectations"
	mean(randsample(x,1000))
end

# ╔═╡ bbc44566-2cc9-4f11-b65d-38133e563c05
function maxEUAgent(ω)
	return actions[argmax([
		𝔼(ω->utility_soft(transitions_soft(a)(ω))) for a in actions
	])]
end

# ╔═╡ 170f9e54-43c5-4365-bdad-1a67751a59f9
randsample(ω->maxEUAgent(ω))

# ╔═╡ 8cfb178a-7be2-4852-afa1-0485cfb8f08b
md"*Exercise*: Adjust the transition probabilities such that the agent chooses the Italian Restaurant."

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

# ╔═╡ 0913d477-35ad-4799-b3b2-dea8d592f2f7
viz(randsample(a_,1000))

# ╔═╡ 2453eb89-01f2-4663-9e2d-3758b3e205d5
function inference_agent(state)
	action = @~UniformDraw(actions)
	action_ = action |ᶜ pw(==,pw(transitions, state, action),"pizza")
	return action_
end

# ╔═╡ b8b16f86-524d-4186-9e8c-f84b88a11f7e
randsample(inference_agent("initialState"))

# ╔═╡ 2143b3c5-d904-4671-911d-0cdaed00c648
withkernel(Omega.kseα(0.4)) do
	viz(randsample(a_soft_condition,1000))
end

# ╔═╡ 0c7e381a-b9a5-4e4b-9678-c5ad27497cbb
n = @~UniformDraw([0,1,2])

# ╔═╡ 2cf4b780-0f09-4a3e-8a89-6582340bf950
r3 = @~Bernoulli(pw(err,pw(==ₛ,pw(*,n,n),4)))

# ╔═╡ 76b47737-2e32-4480-85ab-617a22c0aade
n_cond = n |ᶜ r3

# ╔═╡ b6b41129-e53c-4ddc-85ad-262d0dcdd529
withkernel(Omega.kseα(0.2)) do
viz(randsample(n_cond,1000))
end

# ╔═╡ 68eeec07-7609-4284-8f4e-4d576c0d4968
function soft_max_agent(state)
	action = @~UniformDraw(actions)
	function expected_utility(action)
		utility = ω->pw(utility_soft,pw(transitions_soft, action)(ω))(ω)
		utility_rid = rid(utility, action)
		return (ω->𝔼(utility_rid(ω)))
	end
	cond_uts = @~Bernoulli(pw(err,pw(>=ₛ,expected_utility(action), 4)))
	action_cond = action |ᶜ cond_uts
	return action_cond
end
	

# ╔═╡ 194efb61-2d02-49a5-aba1-7c7983bf384d
withkernel(Omega.kseα(2)) do
viz(randsample(soft_max_agent("initial_state"),1000))
end

# ╔═╡ 1cb9c65b-c467-40ca-86e0-7ef238e3f6de
function monty(alice_door, prize_door)
	door = @~UniformDraw(doors)
	monty_door = door |ᶜ pw(&,pw(!=,door,prize_door),pw(!=,door,alice_door))
	return monty_door
end

# ╔═╡ f0ab5eb6-2e56-40b8-b07b-8599a8c55154
door = @~UniformDraw(doors)

# ╔═╡ 33b5439c-0b86-4610-8de4-59604dbbb8b2
function transitions_mh(state, action)
	if (action == "switch")
		door = @~UniformDraw(doors) 
		alice_door = door |ᶜ pw(&,pw(!=,door,state.monty_door),pw(!=,door,state.alice_door))
		state.alice_door = alice_door
	end
	return state
end

# ╔═╡ 93fa9613-85e2-4776-a81e-6b39c351a9f8
function sample_state()
	alice_door = @~UniformDraw(doors)
	prize_door = @~UniformDraw(doors)
	monty_door = monty(alice_door, prize_door)
	state = state_type(prize_door, monty_door, alice_door)
	return state
end

# ╔═╡ d7cf1ee6-645a-47b2-ae74-0c0876ba1d48
state_o1 = sample_state()

# ╔═╡ 1ce8fb55-8106-4a15-88b2-8dcbe9a1dd51
function agent_mh(actions)
	action = @~UniformDraw(actions)
	state = sample_state()
	util = pw(utility_mh,pw(transitions_mh,state,action))
	util_rid = rid(util,action)
	expected_utility = ω->𝔼(util_rid(ω))
	conds = @~Bernoulli(pw(err,pw(>=ₛ, expected_utility, 4)))
	action_cond = action |ᶜ conds
	return action_cond
end

# ╔═╡ 6c5614f2-fd42-4049-97f8-ab80ad9d31a6
alice_door = @~UniformDraw(doors)

# ╔═╡ 962f242a-857c-4cce-8864-216608a9326d
prize_door = @~UniformDraw(doors)

# ╔═╡ 75b53cd6-33a5-4d64-a26a-2a627733eead
monty_door = monty(alice_door, prize_door)

# ╔═╡ 094e5d20-9e86-49eb-8648-0fac3f6494b8
action_o1 = @~UniformDraw(actions_mh)

# ╔═╡ 59375634-3a96-4bf5-8a13-d2dbfba678b2
new_state_o1 = pw(transitions_mh,state_o1,action_o1)

# ╔═╡ 750fdc60-c157-440b-a909-d037370603ec
util_o1 = pw(utility_mh, new_state_o1)

# ╔═╡ 2483c9fe-7f74-4e12-b4cd-bdd0b33d83a1
util_rid_o1 = rid(util_o1, action_o1)

# ╔═╡ 5109c9d4-5758-4920-982f-2f45b2f7a1b3
expected_utility_o1 = ω->𝔼(util_rid_o1(ω))

# ╔═╡ Cell order:
# ╟─69f5f64e-7ae3-11ec-2649-111a12da3b87
# ╟─b6705156-3d39-44d4-80dd-4794b1f0b0e6
# ╟─d8972d9c-f8a7-40e1-829f-0012dbf992a6
# ╟─020a088e-d753-4030-8a21-d3be00a2d551
# ╟─400c3307-6adb-49a5-b083-dffee6f60223
# ╟─2b3e6015-5a91-4fa6-8efc-eadc121a0a07
# ╟─19b5d039-e201-4e27-a3ec-633bcfaddba2
# ╟─4c512b4b-dec8-4985-81a5-38c6701fbb45
# ╟─a1a3bcf4-7270-4e89-9c44-69ca1a9c0d63
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
# ╟─adacf3b8-8fd1-405a-a770-60d95a5ee8e0
# ╠═6b636814-9317-4535-ad2b-91d706eaee5a
# ╠═c2bdd457-1e32-4df0-ac4d-eb4a8589065b
# ╠═2143b3c5-d904-4671-911d-0cdaed00c648
# ╟─488545b2-a6d1-4d26-b60e-74c68f90c54f
# ╠═0c7e381a-b9a5-4e4b-9678-c5ad27497cbb
# ╠═2cf4b780-0f09-4a3e-8a89-6582340bf950
# ╠═76b47737-2e32-4480-85ab-617a22c0aade
# ╠═b6b41129-e53c-4ddc-85ad-262d0dcdd529
# ╟─ca1bb7d1-9c59-48f2-bdeb-09fa1280061c
# ╠═6d3b6072-d408-4229-8e82-bc4d641aa445
# ╟─d536e409-eeb2-4dcb-ac05-150c0d3658e7
# ╠═68eeec07-7609-4284-8f4e-4d576c0d4968
# ╠═194efb61-2d02-49a5-aba1-7c7983bf384d
# ╟─5141dc4d-628b-4ee9-a796-a743092506af
# ╠═d26a52ec-de29-4fc0-8795-ca156297e00d
# ╠═f6c15353-7a59-4ff0-9cda-15c59efc5c9a
# ╟─f09797b3-1791-4df6-b1b6-7be7a0c12f1f
# ╠═1cb9c65b-c467-40ca-86e0-7ef238e3f6de
# ╠═3ef019ba-3b5b-4db7-ad8b-b0e896f35a79
# ╠═01e8ddf2-bc12-4525-8b09-15ce75e69385
# ╟─b51552a9-cdfe-4a56-a39a-db115123671e
# ╠═f0ab5eb6-2e56-40b8-b07b-8599a8c55154
# ╠═33b5439c-0b86-4610-8de4-59604dbbb8b2
# ╟─f7d9ce97-f4e6-4998-a694-ab5a7d699605
# ╠═29f238af-30d1-4591-bd6a-bcde4e92ba1c
# ╠═93fa9613-85e2-4776-a81e-6b39c351a9f8
# ╠═1ce8fb55-8106-4a15-88b2-8dcbe9a1dd51
# ╠═6c5614f2-fd42-4049-97f8-ab80ad9d31a6
# ╠═962f242a-857c-4cce-8864-216608a9326d
# ╠═75b53cd6-33a5-4d64-a26a-2a627733eead
# ╠═094e5d20-9e86-49eb-8648-0fac3f6494b8
# ╠═d7cf1ee6-645a-47b2-ae74-0c0876ba1d48
# ╠═59375634-3a96-4bf5-8a13-d2dbfba678b2
# ╠═750fdc60-c157-440b-a909-d037370603ec
# ╠═8b3be05c-b03a-43f9-9159-99d4eb4825ba
# ╠═2483c9fe-7f74-4e12-b4cd-bdd0b33d83a1
# ╠═5109c9d4-5758-4920-982f-2f45b2f7a1b3
# ╠═74e914b2-8b06-4f84-84b0-ccde60ee3cf7
# ╟─8cfb178a-7be2-4852-afa1-0485cfb8f08b
# ╟─b628689f-03e5-4867-82ee-23b6ef5dffbf
