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
function transitions_soft(ω,action)
	
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

# ╔═╡ 6b636814-9317-4535-ad2b-91d706eaee5a
r = ω->(@~Bernoulli(pw(+,1,pw(/,pw(logerr,pw(==ₛ,pw(+,a,b,c),2)), 4000))(ω)))(ω)

# ╔═╡ c2bdd457-1e32-4df0-ac4d-eb4a8589065b
a_3 = a |ᶜ ω->r(ω)

# ╔═╡ 2143b3c5-d904-4671-911d-0cdaed00c648
histogram(randsample(a_3,1000))

# ╔═╡ aca5cc72-babf-4870-a3de-446bbb4fea70
𝔼(x; nsamples = 10000) = sum(randsample(x, nsamples)) / nsamples

# ╔═╡ 6d3b6072-d408-4229-8e82-bc4d641aa445
ω = defω()

# ╔═╡ 3e83594c-c069-468f-a3a4-0e7ad37907a1
ω2 = defω(34432)

# ╔═╡ f4a13805-5184-4800-afdb-e6219916f766
randsample(conditional_𝔼,100)

# ╔═╡ 7c24c7c6-556d-4841-8f94-030c2de2bc1b
𝔼1(ω,x) = mean(manynth(iid(x),1:10000)(ω))

# ╔═╡ c5c03382-20fa-4ff9-ab95-32ca0f72b636
𝔼2(x) = mean(manynth(iid(x),1:10000)(ω2))

# ╔═╡ c138d70b-ce91-42af-b3c0-26b63936e728
test𝔼2(x) = mean(x(defω()) for _ in 1:1000)

# ╔═╡ e410c28b-84d4-43d0-a2cf-acbe84bdfcdf
@memoize function 𝔼3(x)
	Random.seed!(0)
	@show "ayo someone called"
	# mean(manynth(iid(x),1:1000)(ω))
	mean(randsample(x,100))
end

# ╔═╡ 20018471-5049-4f1b-9c89-fa7e3a4b09f5
err(conditional_𝔼(ω) >=ₛ 5.3)

# ╔═╡ bd1bc8b4-7133-4976-a86d-89ce92408305
randsample(conditional_𝔼)

# ╔═╡ 44864cbc-b484-499b-bf49-76e266eb4158
expec = ω -> (@~Bernoulli(pw(err,(pw(>ₛ,conditional_𝔼(ω),5.29)))))(ω)

# ╔═╡ 9e580c10-7968-4fc3-afd9-c3371b496c59
randsample(expec,10)

# ╔═╡ 8fdf5419-5171-475f-9cef-a23c5f9c8728
randsample(conditional_𝔼)

# ╔═╡ 2a8aaa1f-f077-42ce-aa54-9530237d6a33


# ╔═╡ e93e63d7-bee8-4f8b-819a-3b0fb11da1c5
test_dist = @~Normal()

# ╔═╡ 6b67965c-70d5-48bd-86d1-2450a24905d6
test_cond = test_dist |ᶜ (test_dist >ₚ 0.5)

# ╔═╡ 55cf2ac0-1f71-4d53-8984-9b0cd70ca38a
randsample(ω->(test_cond(ω),(test_dist >ₚ 0.5)(ω)))

# ╔═╡ 8d094ba0-9fbb-44bf-b164-e53660e9fe9c
randsample(ω->transitions_soft(ω,actions),10)

# ╔═╡ a48e2815-0f11-4c01-ac5c-2b6572076fad
mean(randsample(ω->utility_soft(transitions_soft(ω,"italian")),100000))

# ╔═╡ 1aed2ba2-a510-4f26-885b-d7fc1b5b3e11
mean(randsample(ω->utility_soft(transitions_soft(ω,"french")),100000))

# ╔═╡ 975fa9f5-c2d1-4e5d-b211-37df20099ff1
𝔼1(ω->utility_soft(transitions_soft(ω,actions)))

# ╔═╡ 36d01d69-3b73-4311-992f-4e1eeeaa01b5


# ╔═╡ d66403d3-3571-48d3-a9fb-016c9e1a598d
so_tru = @~Bernoulli()

# ╔═╡ 60785294-a0bd-4927-97b5-b1f8330c7d48
inp_prob = ω->so_tru(ω) ? [0.2, 0.6, 0.2] : [0.05, 0.9, 0.05]

# ╔═╡ 232d356f-33aa-40ef-b62e-0e33e7fd25b2
prob_rid = rid(inp_prob, so_tru)

# ╔═╡ 0b8b8198-49ec-4465-9690-d4c9e4b167c8
rews = [-10, 6, 8]

# ╔═╡ 35386c5b-5965-461b-85fa-119d1a92aa69
a1 = ω->@~Categorical(inp_prob(ω))

# ╔═╡ f717ae56-e85d-49e8-ae2e-35d4682dad08
uti = ω->rews[a1(ω)(ω)]

# ╔═╡ 85df0f28-d22c-4a42-8d2d-630f032b967d
mean(randsample(uti,10000))

# ╔═╡ 40b2d753-52a5-4714-af68-725b92cb1b91
uti_rid = rid(uti, so_tru)

# ╔═╡ 368ed857-89ab-4926-a3ab-34d85dfe969a
mean(randsample(randsample(uti_rid),10000))

# ╔═╡ ed1559f0-c4a2-4359-bf64-2741045258e7
some_func = so_tru |ᶜ ω->(𝔼2(uti_rid(ω)) > 4)

# ╔═╡ 1d123e46-36a9-4f66-834f-b994b9dc8d97
randsample(ω->(some_func(ω),(𝔼2(uti_rid(ω)) > 4)),10)

# ╔═╡ 523e99c5-7fb6-4e2c-9429-e8f99c030853
a2 = ω->@~Bernoulli(a1(ω)/3)

# ╔═╡ f6c15353-7a59-4ff0-9cda-15c59efc5c9a


# ╔═╡ 2befe493-b414-406b-9dd1-96229fbf0ee8
randsample(a2)

# ╔═╡ 78682280-c577-49d1-889c-4cf631821121
a3 = rid(a2, a1)

# ╔═╡ cbca81ce-30ef-44bd-9327-f2bb8e62bf75
a3(ω2)(ω2)

# ╔═╡ c597767e-4eff-4af6-b56f-62bb13f4f830
mean(randsample(a3(ω2)(ω2),10000))

# ╔═╡ f3c518a1-b446-4c3b-b587-2795fcc94e0c
mean(randsample(a3(ω)(ω),10000))

# ╔═╡ 878c1af4-38b9-4682-a407-21a4d104bea3
randsample(a3(ω),10)

# ╔═╡ 7ff70516-3070-49ad-926f-3ba6266bb89c
function example(t)
	new_t = t - 1
	if new_t == 0
		@show "block1"
		u = @~Normal()
		return u
	else
		@show "block2"
		u = ω->𝔼2(example(new_t))
		return u
	end
end

# ╔═╡ 304e1e50-e68b-4c7c-a586-459385973211
randsample(example(4))

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

# ╔═╡ 2453eb89-01f2-4663-9e2d-3758b3e205d5
function inference_agent(state)
	action = UniformDraw(actions)
	action_ = action |ᶜ transitions(state, action) ==ₚ "pizza"
	return action_
end

# ╔═╡ b8b16f86-524d-4186-9e8c-f84b88a11f7e
histogram(randsample(inference_agent("initialState"),1000))

# ╔═╡ 0c7e381a-b9a5-4e4b-9678-c5ad27497cbb
n = @~UniformDraw([0,1,2])

# ╔═╡ 6933e394-ce61-4a0b-9722-650524c6b395
r2 = @~Bernoulli(ω->(pw(+,1,pw(/,pw(logerr,pw(==ₛ,pw(^,ω->n(ω),2),4)),20000)))(ω))

# ╔═╡ 40e170d0-cb29-4f8b-8805-4ef8ef043aae
randsample(r2)

# ╔═╡ 82e20a50-2671-4809-b6b0-046e03762dba
randsample(ω->r2(ω))

# ╔═╡ 42d0a19f-cb97-4f23-a767-f2b889420171
n_c = n |ᶜ ω->r2(ω)

# ╔═╡ a6d027b0-d5a0-472f-a4a8-7b9b6e192155
histogram(randsample(ω->n_c(ω),1000))

# ╔═╡ e21877ac-1439-4fd9-b24c-d6166cb1f8ec
action = @~ UniformDraw(actions)


# ╔═╡ 15653ded-cc36-4b71-810b-10265f7dee50
utility_(ω) = utility_soft(transitions_soft(ω, action))

# ╔═╡ c9e88113-e030-4273-a704-b6b370bc1b23
utility_rid = rid(utility_, action)

# ╔═╡ 89361836-21b1-4fa3-8e66-cbbb56703310
𝔼3(utility_rid(ω2))

# ╔═╡ e4a0664b-69b8-4cba-b788-261f1e83b7f4
mean(randsample(ω->utility_rid(ω2)(ω),1000))

# ╔═╡ 65d961b9-d28a-4c8f-be39-d1b64c479c4a
mean(randsample(ω2->utility_rid(ω)(ω2),1000))

# ╔═╡ 101c8e14-5eb1-4965-b36f-f093a3c005a3
mean(randsample(ω2->utility_rid(ω)(ω2),1000))

# ╔═╡ 46162731-541c-48b1-bf1f-4d3dc7e14a44
randsample(utility_rid)

# ╔═╡ 3937c486-8569-4b9f-9795-f3f76102868d
action(ω)

# ╔═╡ 88287ae6-edea-44e6-8320-cfb538fabda8
randsample(ω->(action(ω),𝔼3(utility_rid(ω))),10)

# ╔═╡ 5951a953-3fb4-4941-8e8d-23dbf963f2ad
randsample(ω->(𝔼1(ω,utility_rid(ω)),action(ω)),10)

# ╔═╡ 023f4d4d-8c6b-4f37-9475-fa2deee7741b
randsample(ω->(𝔼2(utility_rid(ω)),action(ω)),10)

# ╔═╡ e4be56f8-ca16-4e3c-9ddc-7038960c171b
choose_action = action |ᶜ (ω -> expec(ω))

# ╔═╡ 471efa1c-f144-446b-ad45-6d847f0a3b1b
choose_action2 = action |ᶜ (conditional_𝔼 >ₚ 5.37)

# ╔═╡ e48a47df-90db-4f48-9d87-d80d5bca848e
randsample(ω->  (a = choose_action2(ω), b =(conditional_𝔼 >ₚ 5.37)(ω)),1000)

# ╔═╡ a21848e5-ed64-4d22-b2f4-2021940efb6f
utility_2(ω) = utility_soft(transitions_soft(ω,action))

# ╔═╡ 7fe03684-9cec-4bab-9f85-45f500373a7d
randsample(ω->utility_2(ω),10)

# ╔═╡ 7e201ee9-4e6e-452d-95b4-db125675527e
ω->𝔼1(utility_2)

# ╔═╡ e599ecac-21ef-4aab-8ee4-ebcf06878a81
randsample(ω->(action(ω),𝔼1(ω,utility_2)),10)

# ╔═╡ 295e6ea2-a258-4b26-9de8-69e6a54a8a82
conditional_𝔼2 = ω->(action(ω),𝔼1(ω,utility_2)) |ᶜ ω -> (𝔼1(ω,utility_2) > 4)

# ╔═╡ e5d53794-4a9e-4424-8654-00510c5dc932
randsample(conditional_𝔼2,10)

# ╔═╡ 794dac55-4227-4e25-8025-2e1cc8999856
randsample(ω->(action(ω),𝔼2(uti_rid(ω))),10)

# ╔═╡ 8a1da081-1544-4067-83e2-83acf9222eae
#not used right now
utility_rid2 = rid(utility_2, action)

# ╔═╡ 5b96408c-e5db-486d-8e35-3d621c1b2344
randsample(utility_rid2(ω))

# ╔═╡ c4710ca5-470b-47c3-8743-86d789deb16f
unique(randsample(utility_rid2(ω),100))

# ╔═╡ 93c7b125-0f6c-4de7-bba4-2c28e3a1b2a0
randsample(ω->𝔼1(ω,utility_rid2),10)

# ╔═╡ ba72f674-0976-45a6-b1f0-83e312d2dce2
cond_𝔼 = action |ᶜ 𝔼(utility_rid2(ω)) > 5.3

# ╔═╡ d224009c-1c36-4dd9-b6bb-341d8a4813d3
mean(randsample(utility_rid2(ω2),1000))

# ╔═╡ 69aa3484-0d2c-43c3-a1a7-8cd7d614537e
mean(randsample(randsample(utility_rid2),100))

# ╔═╡ 191363b1-ecb9-40b9-8db7-79892b206d63
mean(randsample(utility_rid2(ω2),1000))

# ╔═╡ 5af895bd-669e-4050-8abe-849fd12f1e7f
mean(randsample(utility_rid2(ω2)(ω2),1000))

# ╔═╡ Cell order:
# ╠═69f5f64e-7ae3-11ec-2649-111a12da3b87
# ╠═b6705156-3d39-44d4-80dd-4794b1f0b0e6
# ╠═d8972d9c-f8a7-40e1-829f-0012dbf992a6
# ╠═020a088e-d753-4030-8a21-d3be00a2d551
# ╠═400c3307-6adb-49a5-b083-dffee6f60223
# ╠═2b3e6015-5a91-4fa6-8efc-eadc121a0a07
# ╠═19b5d039-e201-4e27-a3ec-633bcfaddba2
# ╠═4c512b4b-dec8-4985-81a5-38c6701fbb45
# ╠═a1a3bcf4-7270-4e89-9c44-69ca1a9c0d63
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
# ╠═6b636814-9317-4535-ad2b-91d706eaee5a
# ╠═c2bdd457-1e32-4df0-ac4d-eb4a8589065b
# ╠═2143b3c5-d904-4671-911d-0cdaed00c648
# ╠═0c7e381a-b9a5-4e4b-9678-c5ad27497cbb
# ╠═6933e394-ce61-4a0b-9722-650524c6b395
# ╠═40e170d0-cb29-4f8b-8805-4ef8ef043aae
# ╠═42d0a19f-cb97-4f23-a767-f2b889420171
# ╠═82e20a50-2671-4809-b6b0-046e03762dba
# ╠═e21877ac-1439-4fd9-b24c-d6166cb1f8ec
# ╠═aca5cc72-babf-4870-a3de-446bbb4fea70
# ╠═a6d027b0-d5a0-472f-a4a8-7b9b6e192155
# ╠═6d3b6072-d408-4229-8e82-bc4d641aa445
# ╠═3e83594c-c069-468f-a3a4-0e7ad37907a1
# ╠═f4a13805-5184-4800-afdb-e6219916f766
# ╠═15653ded-cc36-4b71-810b-10265f7dee50
# ╠═c9e88113-e030-4273-a704-b6b370bc1b23
# ╠═7c24c7c6-556d-4841-8f94-030c2de2bc1b
# ╠═c5c03382-20fa-4ff9-ab95-32ca0f72b636
# ╠═c138d70b-ce91-42af-b3c0-26b63936e728
# ╠═3937c486-8569-4b9f-9795-f3f76102868d
# ╠═e410c28b-84d4-43d0-a2cf-acbe84bdfcdf
# ╠═89361836-21b1-4fa3-8e66-cbbb56703310
# ╠═e4a0664b-69b8-4cba-b788-261f1e83b7f4
# ╠═65d961b9-d28a-4c8f-be39-d1b64c479c4a
# ╠═101c8e14-5eb1-4965-b36f-f093a3c005a3
# ╠═88287ae6-edea-44e6-8320-cfb538fabda8
# ╠═5951a953-3fb4-4941-8e8d-23dbf963f2ad
# ╠═023f4d4d-8c6b-4f37-9475-fa2deee7741b
# ╠═20018471-5049-4f1b-9c89-fa7e3a4b09f5
# ╠═bd1bc8b4-7133-4976-a86d-89ce92408305
# ╠═44864cbc-b484-499b-bf49-76e266eb4158
# ╠═9e580c10-7968-4fc3-afd9-c3371b496c59
# ╠═e4be56f8-ca16-4e3c-9ddc-7038960c171b
# ╠═8fdf5419-5171-475f-9cef-a23c5f9c8728
# ╠═471efa1c-f144-446b-ad45-6d847f0a3b1b
# ╠═e48a47df-90db-4f48-9d87-d80d5bca848e
# ╠═2a8aaa1f-f077-42ce-aa54-9530237d6a33
# ╠═e93e63d7-bee8-4f8b-819a-3b0fb11da1c5
# ╠═6b67965c-70d5-48bd-86d1-2450a24905d6
# ╠═55cf2ac0-1f71-4d53-8984-9b0cd70ca38a
# ╠═46162731-541c-48b1-bf1f-4d3dc7e14a44
# ╠═8d094ba0-9fbb-44bf-b164-e53660e9fe9c
# ╠═a48e2815-0f11-4c01-ac5c-2b6572076fad
# ╠═1aed2ba2-a510-4f26-885b-d7fc1b5b3e11
# ╠═a21848e5-ed64-4d22-b2f4-2021940efb6f
# ╠═7fe03684-9cec-4bab-9f85-45f500373a7d
# ╠═7e201ee9-4e6e-452d-95b4-db125675527e
# ╠═e599ecac-21ef-4aab-8ee4-ebcf06878a81
# ╠═295e6ea2-a258-4b26-9de8-69e6a54a8a82
# ╠═e5d53794-4a9e-4424-8654-00510c5dc932
# ╠═5b96408c-e5db-486d-8e35-3d621c1b2344
# ╠═975fa9f5-c2d1-4e5d-b211-37df20099ff1
# ╠═36d01d69-3b73-4311-992f-4e1eeeaa01b5
# ╠═c4710ca5-470b-47c3-8743-86d789deb16f
# ╠═93c7b125-0f6c-4de7-bba4-2c28e3a1b2a0
# ╠═ba72f674-0976-45a6-b1f0-83e312d2dce2
# ╠═d66403d3-3571-48d3-a9fb-016c9e1a598d
# ╠═60785294-a0bd-4927-97b5-b1f8330c7d48
# ╠═232d356f-33aa-40ef-b62e-0e33e7fd25b2
# ╠═0b8b8198-49ec-4465-9690-d4c9e4b167c8
# ╠═35386c5b-5965-461b-85fa-119d1a92aa69
# ╠═f717ae56-e85d-49e8-ae2e-35d4682dad08
# ╠═85df0f28-d22c-4a42-8d2d-630f032b967d
# ╠═40b2d753-52a5-4714-af68-725b92cb1b91
# ╠═368ed857-89ab-4926-a3ab-34d85dfe969a
# ╠═794dac55-4227-4e25-8025-2e1cc8999856
# ╠═ed1559f0-c4a2-4359-bf64-2741045258e7
# ╠═1d123e46-36a9-4f66-834f-b994b9dc8d97
# ╠═523e99c5-7fb6-4e2c-9429-e8f99c030853
# ╠═f6c15353-7a59-4ff0-9cda-15c59efc5c9a
# ╠═2befe493-b414-406b-9dd1-96229fbf0ee8
# ╠═78682280-c577-49d1-889c-4cf631821121
# ╠═cbca81ce-30ef-44bd-9327-f2bb8e62bf75
# ╠═c597767e-4eff-4af6-b56f-62bb13f4f830
# ╠═f3c518a1-b446-4c3b-b587-2795fcc94e0c
# ╠═878c1af4-38b9-4682-a407-21a4d104bea3
# ╠═8a1da081-1544-4067-83e2-83acf9222eae
# ╠═d224009c-1c36-4dd9-b6bb-341d8a4813d3
# ╠═69aa3484-0d2c-43c3-a1a7-8cd7d614537e
# ╠═191363b1-ecb9-40b9-8db7-79892b206d63
# ╠═5af895bd-669e-4050-8abe-849fd12f1e7f
# ╠═7ff70516-3070-49ad-926f-3ba6266bb89c
# ╠═304e1e50-e68b-4c7c-a586-459385973211
# ╟─8cfb178a-7be2-4852-afa1-0485cfb8f08b
# ╟─b628689f-03e5-4867-82ee-23b6ef5dffbf
