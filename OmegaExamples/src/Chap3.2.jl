### A Pluto.jl notebook ###
# v0.17.6

using Markdown
using InteractiveUtils

# ╔═╡ f10e6294-6a1c-453e-adea-15204d8a6d46
using Pkg

# ╔═╡ fa943222-657d-4f7c-b553-2ea77b17f271
Pkg.activate(Base.current_project())

# ╔═╡ a8eead09-7565-452b-8b54-231f528f7283
using Memoize

# ╔═╡ c79780db-bf6d-448d-8c87-bdb480fd958d
using Random

# ╔═╡ 7fe0df3f-f3d3-4b6b-b345-779391bce2f1
using Omega

# ╔═╡ 421bfaad-4026-451d-8b5d-17acfb2e97f1
using Distributions

# ╔═╡ 57ceb8b7-b87f-4bfc-97fd-7fea1ec4b3d4
using UnicodePlots

# ╔═╡ 32ceb46e-afb6-49d3-a724-d201d56842df
using POMDPs

# ╔═╡ c4f4fb3a-4c73-43eb-90d2-22698f48dac5
Pkg.instantiate()

# ╔═╡ 2ee64627-e85f-40fa-b51c-623b0af1f4fd
function get_reward_dist(θ, n)
	n~Bernoulli(1-θ)
end

# ╔═╡ 2a986c7b-8f94-4e62-b188-5e39b141a792
arm_to_reward_dist = Dict(
	1 => get_reward_dist(0.7, 1),
	2 => get_reward_dist(0.8, 2)
)

# ╔═╡ 75508030-b27f-4797-97a0-467fe8652b8c
alternate_arm_to_reward_dist = Dict(
	1 => get_reward_dist(0.7, 3),
	2 => get_reward_dist(0.2, 4)
)

# ╔═╡ 47a287d2-0d5c-4b11-90e7-2c30a910a1f5
ω = defω()

# ╔═╡ 39c2e216-eabd-4d49-9e23-8740257d40ce
!isinf(1)

# ╔═╡ 8621926a-be95-43be-9eac-9ee7e17bb6bb
@memoize function 𝔼(x)
	Random.seed!(0)
	@show "Calculating Expectations"
	mean(randsample(x,2))
end

# ╔═╡ 0d4bbd56-6cec-4537-a56b-118def1c8135
mutable struct manifestState
	loc
	time_left
	terminate_after_action
end

# ╔═╡ 7c9e8f51-f8d3-4553-b71c-70e3747eb037
mutable struct State
	manifest_state::manifestState
	latent_state
end

# ╔═╡ 4b92341c-a88e-46fa-9406-1196fef6639f
mutable struct Bandits <: POMDP{State, Any, Any}
	number_of_arms::Int64
	arm_to_prize_dist
	number_of_trials::Int64
	numerical_prizes
	prize_to_utility
end

# ╔═╡ 152918fb-f5db-4736-9bdd-48502bcb7367
mutable struct Observation
	manifest_state::manifestState
	observation
end

# ╔═╡ 4d9b2a4a-190c-4cf8-b3a8-635ce3b7ccd1
function advance_time(state::manifestState)
	@show "advance_time"
	state.time_left = state.time_left - 1
	state.terminate_after_action = (state.time_left <= 1)
	state
end

# ╔═╡ ebfaaf1e-f11e-46da-a6fa-5ddafae3e4e8
POMDPs.isterminal(p::POMDP, s) = s.manifest_state.terminate_after_action

# ╔═╡ 42b3adb1-7317-4814-b5e8-5eea5815fa00
function manifest_state_to_actions(pomdp::Bandits, state::manifestState)
	return pomdp.actions
end

# ╔═╡ 3a81aff1-2f29-491c-9fd7-55d57413330b
function POMDPs.initialstate(m::Bandits)
	manifest_state = manifestState(:start, m.number_of_trials, false)
	latent_state = m.arm_to_prize_dist
	State(manifest_state, latent_state)
end

# ╔═╡ 763a7713-5fea-4cc3-b7a7-a269fe89a2b2
md"Make POMDP Agent Starts here"

# ╔═╡ b924c0c2-d3ec-4fc6-a2b4-46ace6209ce7
callable(o) = !isempty(methods(o))

# ╔═╡ 129d8cb9-92d3-4647-9625-66b1a4931f5a
function has_utility_prior_belief(agent_params)
	if hasproperty(agent_params, :utility) && hasproperty(agent_params, :prior_belief)
		utility = agent_params.utility
		prior_belief = agent_params.prior_belief
		callable(utility)
	else
		false
	end
end

# ╔═╡ 4e25ab3b-1784-49a6-aeb4-beaf9a595ad9
function is_dist_over_latent(belief)
	hasproperty(belief, :manifest_state) &&
	hasproperty(belief, :latent_state) &&
	
	!hasproperty(belief, :id) &&
	hasproperty(belief.latent_state, :id)
end

# ╔═╡ d0e6f235-e5aa-479a-bfeb-6e69ab1d0ce5
#returns action space given POMDP and belief
begin
	POMDPs.actions(pomdp::Bandits) = vcat([act for act in 1:pomdp.number_of_arms],[:no_action])
	POMDPs.actions(pomdp::Bandits, belief::State) = vcat([act for act in 1:pomdp.number_of_arms],[:no_action])
end

# ╔═╡ adacce2e-967f-40e5-9383-df55ea98972a
# takes in POMDP, state, action(Integer) and returns new state
function POMDPs.transition(m::Bandits, state::State, action::Integer)
	@show "transition"
	prize = state.latent_state[action]
	manifest_state = state.manifest_state
	manifest_state.loc = prize
	new_manifest_state = advance_time(manifest_state)
	State(new_manifest_state, state.latent_state)
end

# ╔═╡ d666457f-7031-46cb-99a4-6d5671592909
function get_full_observe(observe_latent)
	function(pomdp, state)
		@show "observe"
		manifest_state = state.manifest_state
		observation = observe_latent(pomdp, state)
		Observation(manifest_state, observation)
	end
end

# ╔═╡ 28b6da7b-16c5-4524-87ec-ed681fdaa3df
observe_latent(p::Bandits, s) = 0

# ╔═╡ ff27d75f-babf-49af-99a9-46a360d5ea1a
POMDPs.observation(m::Bandits, state) = get_full_observe(observe_latent)(m, state)

# ╔═╡ 4bfabcb0-c170-4bb7-8293-f6ac15fa8153
function has_transition_observe(bandit)
	callable(transition) && callable(observation)
end

# ╔═╡ 953da4ec-5af4-4161-807a-82ec02da6051
bandit = Bandits(2,arm_to_reward_dist, 3, true, nothing)

# ╔═╡ 4b8e92da-d587-4682-bc4f-e2c57098bd88
start_state = initialstate(bandit)

# ╔═╡ 67e45f2b-ae77-434c-ad8a-78a488be0df8
observation1 = observation(bandit, start_state)

# ╔═╡ dd0cb92e-ca1c-4e8b-b0ff-41dfe43944f5
start_state

# ╔═╡ 59ca8c63-9669-41fa-a890-7dca250d3d7f
observed = observation(bandit, start_state)

# ╔═╡ 3228ff0a-fc05-4d5a-b32d-a3d446a8e17d
observed

# ╔═╡ 21782a16-ea9a-47e1-8c77-16fedfdcbbb5
observed

# ╔═╡ 0bdfb4a0-92bd-4ae9-ae2e-c3382eb25880
state = initialstate(bandit)

# ╔═╡ 4304b2b6-4524-4615-8a66-3aa122f69872
state.latent_state[2]

# ╔═╡ 91718788-bae6-4f7e-81da-838331d3fb8d


# ╔═╡ 6ff162be-ab05-4805-a0cd-e466d3a44576


# ╔═╡ eb364ddb-bff2-4a13-b30d-e35e3e6acd12
function is_manual_POMDP_agent(agent_params)
	false #for the time being will be changed later
end

# ╔═╡ 13d017df-a9f6-49ae-bb5d-ae8b1b5aa2ea
function is_optimal_POMDP_agent(agent_params)
	function optimal_properties()
		!(hasproperty(agent_params, :no_delays) || hasproperty(agent_params, :discount) || hasproperty(agent_params, :myopic_observations))
	end
	!isdefined(agent_params, optimal) ? optimal_properties() : agent_params.optimal
end

# ╔═╡ 0412b276-e069-45da-abbb-fc614a3289e3
mutable struct Params
	alpha
	recurse_on_state_or_belief
	discount
	sophisticated_or_naive
	no_delays
	update_myopic
	reward_myopic
end

# ╔═╡ a23a0435-9b46-4345-9770-e7cf01c28be3
function Base.isequal(x::manifestState, y::manifestState)
	x.loc == y.loc && x.time_left == y.time_left && x.terminate_after_action == y.terminate_after_action 
end

# ╔═╡ 0800fb3f-53f4-4db8-8f21-006e033f3e98
function Base.isequal(x::Observation, y::Observation)
	x.manifest_state == y.manifest_state && x.observation == y.observation
end

# ╔═╡ 10573a52-9eaf-4288-87b6-636793c10fac
function Base.isequal(x::State, y::State)
	x.manifest_state == y.manifest_state && x.latent_state == y.latent_state
end

# ╔═╡ 93e50e9c-a87e-478e-9d45-180caa00a847
Base.:(==)(x::manifestState, y::manifestState) = Base.isequal(x,y)

# ╔═╡ 7f98a6a2-3af1-4764-b452-6828b1743e1d
Base.:(==)(x::Observation, y::Observation) = Base.isequal(x,y)

# ╔═╡ 4eb0a69b-3e9b-43f9-bf2e-841715d96d55
Base.:(==)(x::State, y::State) = Base.isequal(x,y)

# ╔═╡ e5645334-45fe-423b-882e-d557219adccb
function is_delta_dist(dist)
	Random.seed!(0)
	length(unique(randsample(dist,100))) == 1
end

# ╔═╡ 85c9c0c6-44d2-4bb0-92fa-75e5780876a9
function in_support(x, dist)
	!isinf(𝔼(ω->(dist(ω) == x)))
end

# ╔═╡ cc5e3dad-dfc4-4a53-9e1a-09e5d13eb010
function POMDPs.reward(m::Bandits, state::State, action)
	@show "reward"
	reward = state.manifest_state.loc
	reward == :start ? (ω->0) : reward
end

# ╔═╡ 5b32a494-d50d-4e51-a3cc-4ec0828e4335
 # takes in updater, POMDP, belief, action, observation and returns a new belief State(manifest_state, distribution)

@memoize function POMDPs.update(u::Updater, p::Bandits, belief_old::State, action::Union{Symbol, Integer}, obs::Observation)

	@show "update"
	
	# belief = is_dist_over_latent(belief_old) ? belief_old : State(belief_old(ω).manifest_state, ω -> belief_old(ω).latent_state)

	belief = typeof(belief_old) == State ? belief_old : State(belief_old(ω).manifest_state, ω -> belief_old(ω).latent_state)

	new_manifest_state = obs.manifest_state

	if(obs.observation == nothing || is_delta_dist(belief.latent_state))
		
		belief.manifest_state = new_manifest_state
		
		belief
		
	else

		latent_state = belief.latent_state

		state = ω -> State(belief.manifest_state, latent_state(ω))

		predicted_next_state = action == :no_action ? state : ω -> transition(p, state(ω), action)

		predicted_next_observation = ω -> observation(p, predicted_next_state(ω))
		
		condition = pw(==, ω -> obs, predicted_next_observation)

		new_latent_state = latent_state |ᶜ condition

		State(new_manifest_state, new_latent_state)

	end
	
end

# ╔═╡ 0e29773f-a0d4-4e30-95ac-c970daeb38a0
a = manifestState(1,1,1)

# ╔═╡ 9951fdd0-864a-4c03-9442-185bd00e0215
b = manifestState(1,1,1)

# ╔═╡ 2d1b14a4-02f3-4f5e-99a7-8987c0e611dc
a == b

# ╔═╡ a038f07b-33c3-4737-a44d-54ae6a622c69
struct BanditUpdater <: POMDPs.Updater end

# ╔═╡ 91dab6a2-a285-466b-9c4f-cd694d56dad1
up = BanditUpdater()

# ╔═╡ a33d38e1-5b85-45aa-8230-43ecff4ea498
struct NaiveSolver <: POMDPs.Solver end

# ╔═╡ e0df712f-8ba5-4cba-a960-7e0f47d390dd
struct SophisticatedSolver <: POMDPs.Solver end

# ╔═╡ a0c2dafa-2496-4972-a5d6-7aef8372a054
struct NaivePlanner{M,U} <: POMDPs.Policy
	m::M
	u::U
end

# ╔═╡ eccb5744-ec80-4015-a339-03997e3aa15c
np = NaivePlanner(bandit, up)

# ╔═╡ f907709d-4fca-4047-a325-66b5725d80ed
struct SophisticatedPlanner{M} <: POMDPs.Policy 
	m::M
end

# ╔═╡ 34d1cabc-3f0b-49b1-a71a-398045b8e2d1
struct temporaryp <: POMDPs.Policy end

# ╔═╡ 7fa4ccc9-a65a-4a40-bc4e-c18bf53ab28f
POMDPs.initialize_belief(up::BanditUpdater, belief) = belief

# ╔═╡ 6d59b0fd-d4c8-4367-97e1-df28290e9c1c
initialize_belief(up, @~Categorical([0.5, 0.5]))

# ╔═╡ 5f0a1df6-0f5c-4b7b-8bd2-67c7c3cd9d33
r_total = 0.0

# ╔═╡ 67b78765-28d4-40d2-a92f-0f7a0c56023f


# ╔═╡ be5eddd3-a689-48fb-b734-9dac9ed5d728
pomdp = Bandits(2, arm_to_reward_dist, 11, true, nothing)

# ╔═╡ 8d09d542-2917-41fc-bb30-476b32376eba
POMDPs.actions(pomdp)

# ╔═╡ 66172d26-a137-4d97-b91d-0942e76af4c3
is = POMDPs.initialstate(pomdp)

# ╔═╡ 978d4f39-adc6-4611-9e9d-bcc09f048bdd


# ╔═╡ 19b5eece-aba6-4c81-bfb3-4c8f95559ac6
transition(pomdp, is, 1)

# ╔═╡ 9e3bc8e0-cf7f-462f-aa7f-16c8fbb3b50a
reward(pomdp, is, 1)

# ╔═╡ 642c9a7a-bcfb-4b51-9454-08cb0cad8f46


# ╔═╡ 0cbef536-feac-47d5-9c81-b5d7a3a10f35


# ╔═╡ 142a11cf-7aa0-4145-84e1-77aa34f402e3
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

# ╔═╡ 258ce194-ad54-4228-9bb8-e20e4bdb5e6f
arm_to_reward_dist_main = @~UniformDraw([arm_to_reward_dist, alternate_arm_to_reward_dist])

# ╔═╡ 40153654-a0a5-4a03-b6f5-22eca3a379eb
arm_to_reward_dist_prior = @~ UniformDraw([arm_to_reward_dist, alternate_arm_to_reward_dist])

# ╔═╡ 92e7dabc-679e-4714-8107-ac1201873973
prior_belief = State(start_state.manifest_state, arm_to_reward_dist_prior)

# ╔═╡ c32a8bff-7c3c-4d39-82e9-439f251793a5
belief = POMDPs.update(up, pomdp, prior_belief, :no_action, observation1)

# ╔═╡ 7354fe36-713f-418a-be47-3f4b931e142b
is_dist_over_latent(prior_belief)

# ╔═╡ ed4446ec-2d83-45e4-a3d1-de1767f4252e
state_new = ω -> State(prior_belief.manifest_state, prior_belief.latent_state(ω))

# ╔═╡ 73f5503f-43d4-49cb-b76b-7baae9c7b670
randsample(pw(==, (ω -> observed),(ω -> observation(bandit, state_new(ω)))),1)

# ╔═╡ 0a035f31-3f74-4441-b671-404937934d68
randsample(ω -> observation(bandit, state_new(ω)))

# ╔═╡ 49755d8e-0750-4400-ae93-c74e9c6c8983
lat_state = prior_belief.latent_state

# ╔═╡ c7592d33-67e8-4a31-8c1e-c9d5dd84fd1a
believed = POMDPs.update(up, bandit, prior_belief, :no_action, observed)

# ╔═╡ 134b2852-c2df-4972-aace-dc704aff5307
state_n = ω -> State(believed.manifest_state, believed.latent_state(ω))

# ╔═╡ ca36f8a4-3545-4483-9042-9cffc4f3a628
randsample(state_n)

# ╔═╡ c6a98ecb-ed79-44f4-997a-e36d54d226b1
randsample(believed.latent_state)

# ╔═╡ acda1315-f69b-48a1-b0af-ad2fd6927d69
#takes in belief (Policy chooses which function to be dispatched) returns action conditioned on factor

@memoize function POMDPs.action(p::Policy, belief::State)

	@show "action"
	
	action = @~UniformDraw(actions(p.m, belief))

	eu = value(p, belief, action)

	eu_rid = rid(eu, action)

	soft_condition = pw(err,pw(>=ₛ, ω -> 𝔼(eu_rid(ω)), ω -> 0.5))
	
	factor = @~Bernoulli(soft_condition)
	
	action |ᶜ factor
end	

# ╔═╡ 2cdafd92-f519-4963-9dc2-88611c04d3dd
#takes in belief, action (Policy chooses which function to be dispatched) returns a distribution over states

@memoize function POMDPs.value(p::Policy, belief::State, actin)

	@show "value"
	
	state = ω -> State(belief.manifest_state, belief.latent_state(ω))

	function state_conditional(state, act)
		
		@show "state_conditional"
		
		u = reward(p.m, state, act)
		
		if isterminal(p.m, state)
			@show "is_terminal"
			return u
			
		else
			@show "not_terminal"
			next_state = transition(p.m, state, act)
			next_observation = observation(p.m, next_state)
			next_belief = POMDPs.update(p.u, p.m, belief, act,  next_observation)
			next_action = action(p, next_belief)

			futureU = value(p, next_belief, next_action)
			return pw(+, u, futureU)
			
		end
	end

	Variable(ω -> state_conditional(state(ω), actin(ω))(ω))
end

# ╔═╡ cec5ed27-0524-42de-9a77-9dd87cc2e615
act = action(np, believed)

# ╔═╡ 21a872a8-1d8f-43f3-b999-33e8a7e554d5
acti = @~UniformDraw(actions(pomdp, believed))

# ╔═╡ 98df5a88-b9c1-4348-a8fb-ba3dd4fd7b84
reward_n = ω -> reward(bandit, state_n(ω), acti(ω))

# ╔═╡ c7d77fd5-8df1-4ee1-900a-a68f2810a627
v_rid = rid(value(np, believed, acti), acti)

# ╔═╡ e085ff3d-b08d-49a6-861f-74b25427145b
cvr = randsample(v_rid)

# ╔═╡ ebdd103f-148e-4750-a146-628c06d8e4a2
𝔼(cvr)

# ╔═╡ c1551dc5-787c-42aa-878c-154faf8b81d8
function make_POMDP_agent_delay(params, world)
	@assert(has_utility_prior_belief(params) && has_transition_observe(world), "makePOMDPAgent params and world")
	params = Params(1000, "belief", 0, "naive", true, false, false) #may have to replace this with a named function
	if params.reward_myopic || params.update_myopic
		@assert(params.no_delays == false && params.sophisticated_or_naive == "naive", "rewardMyopic and updateMyopic require Naive agent with delays")
	end

	@assert (params.reward_myopic == false || params.update_myopic == false, "one of rewardMyopic and updateMyopic must be false")

	transitions = world.transition
	utility = world.utility

	POMDP_functions = get_POMDP_functions(params, world)
	observe = POMDP_functions.observe
	belief_to_actions = POMDP_functions.belief_to_actions
	sample_belief = POMDP_functions.sample_belief
	_update_belief = POMDP_functions.update_belief

	function update_belief(belief, observation, action, delay)
		if params.update_myopic && (delay > params.update_myopic.bound)
			# update manifestState (assuming no possibility that isNullAction(action))
			state = sample_belief(belief)
			next_belief = transition(state, action)
			POMDP_functions.use_manifest_latent ? to_dist_over_latent(next_belief) : next_belief
		else
			return _update_belief(belief, observation, action)
		end
	end
	#Update the *delay* parameter in *expectedUtility* for sampling actions and future utilities
	function transform_delay(delay)
		table = Dict(
			"naive" => delay + 1,
			"sophisticated" => 0
		)
		return params.no_delays ? 0 : table[params.sophisticated_or_naive]
	end

	function increment_delay(delay)
		params.no_delay ? 0 : delay + 1
	end

	discount_function = isdefined(params, :discount_function) ? params.discount_function : delay -> 
		1.0 / (1 + params.discount * delay)

	function should_terminate(state, delay)
		terminate_after_action = POMDPs_functions.use_manifest_latent ? state.manifest_state.terminate_after_action : state.terminate_after_action
		if terminate_after_action
			return true
		end

		if params.reward_myopic
			return delay >= params.reward_myopic_bound
		end

		return false
	end

	@memoize function act(belief, delay)
		action = @~UniformDraw(belief_to_actions(belief))
		eu = expected_utility_belief(belief, action, delay)
		soft_condition = pw(==ₛ, 𝔼(eu), 1.0)
		factor = @~Bernoulli(soft_condition)
		actions |ᶜ factor
	end

	@memoize function expected_utility_belief(belief, action, delay)
		state = sample_belief(belief)
		#add check for if utility is finite
		u = discount_factor(delay) * utility(state, action)

		if should_terminate(state, delay)
			return u
		else
			next_state = transition(state, action)
			next_observation = observe(next_state)
			transform_delay = transform_delay(delay)
			next_belief = update_belief(belief, next_observation)
			next_action = act(next_belief, transform_delay)

			futureU = expected_utility_belief(next_belief, next_action, increment_delay(delay))
			return pw(+, u, futureU)
		end
	end

	@memoize function act_rec_state(belief, delay)
		action = @~UniformDraw(belief_to_actions(belief))
		eu = expected_utility_belief_rec_state(belief, action, delay)
		soft_condition = pw(==ₛ, 𝔼(eu), 1.0)
		factor = @~Bernoulli(soft_condition)
		actions |ᶜ factor
	end

	@memoize function expected_utility_belief_rec_state(belief, action, delay)
		state = sample_belief(belief)
		expected_utility_state_rec_state(belief, state, action, delay)
	end

	@memoize function expected_utility_state_rec_state(belief, state, action, delay)
		u = discount_factor(delay) * utility(state, action)
		if should_terminate(state, delay)
			u
		else
			next_state = transition(state, action)
			next_observation = observe(next_state)
			transformed_delay = transform_delay(delay)
			next_belief = updated_belief(belief, next_observation, action, transformed_delay)
			next_action = act_rec_state(next_belief, transformed_delay)
			future_u = expected_utility_state_rec_state(next_belief, next_state, next_action, increment_delay(delay))
			pw(+,u,future_u)
		end

		act = params.recurse_on_state_or_belief == "belief" ? act : act_rec_state
		expected_utility = params.recurse_on_state_or_belief == "belief" ? expected_utility_belief : expected_utility_belief_rec_state

		return (act, updated_belief, expected_utility, params, POMDP_functions)
	end
end
		

# ╔═╡ c19acb2a-4de4-4dde-bee8-077e39010d4b
function make_pomdp_agent(params, world)
	if is_manual_POMDP_agent(params)
		params.POMDPFunctions = get_POMDP_functions(params.params, world)
	else
		is_optimal_POMDP_agent(params) ? make_POMDP_agent_optimal(params, world) : make_POMDP_agent_delay(params, world)
	end
end

# ╔═╡ Cell order:
# ╠═f10e6294-6a1c-453e-adea-15204d8a6d46
# ╠═fa943222-657d-4f7c-b553-2ea77b17f271
# ╠═c4f4fb3a-4c73-43eb-90d2-22698f48dac5
# ╠═a8eead09-7565-452b-8b54-231f528f7283
# ╠═c79780db-bf6d-448d-8c87-bdb480fd958d
# ╠═7fe0df3f-f3d3-4b6b-b345-779391bce2f1
# ╠═421bfaad-4026-451d-8b5d-17acfb2e97f1
# ╠═57ceb8b7-b87f-4bfc-97fd-7fea1ec4b3d4
# ╠═32ceb46e-afb6-49d3-a724-d201d56842df
# ╠═e5645334-45fe-423b-882e-d557219adccb
# ╠═2ee64627-e85f-40fa-b51c-623b0af1f4fd
# ╠═2a986c7b-8f94-4e62-b188-5e39b141a792
# ╠═75508030-b27f-4797-97a0-467fe8652b8c
# ╠═258ce194-ad54-4228-9bb8-e20e4bdb5e6f
# ╠═85c9c0c6-44d2-4bb0-92fa-75e5780876a9
# ╠═40153654-a0a5-4a03-b6f5-22eca3a379eb
# ╠═cc5e3dad-dfc4-4a53-9e1a-09e5d13eb010
# ╠═67e45f2b-ae77-434c-ad8a-78a488be0df8
# ╠═c32a8bff-7c3c-4d39-82e9-439f251793a5
# ╠═7354fe36-713f-418a-be47-3f4b931e142b
# ╠═47a287d2-0d5c-4b11-90e7-2c30a910a1f5
# ╠═39c2e216-eabd-4d49-9e23-8740257d40ce
# ╠═8621926a-be95-43be-9eac-9ee7e17bb6bb
# ╠═4b92341c-a88e-46fa-9406-1196fef6639f
# ╠═7c9e8f51-f8d3-4553-b71c-70e3747eb037
# ╠═152918fb-f5db-4736-9bdd-48502bcb7367
# ╠═0d4bbd56-6cec-4537-a56b-118def1c8135
# ╠═4d9b2a4a-190c-4cf8-b3a8-635ce3b7ccd1
# ╠═ebfaaf1e-f11e-46da-a6fa-5ddafae3e4e8
# ╠═42b3adb1-7317-4814-b5e8-5eea5815fa00
# ╠═3a81aff1-2f29-491c-9fd7-55d57413330b
# ╟─763a7713-5fea-4cc3-b7a7-a269fe89a2b2
# ╠═b924c0c2-d3ec-4fc6-a2b4-46ace6209ce7
# ╠═129d8cb9-92d3-4647-9625-66b1a4931f5a
# ╠═4bfabcb0-c170-4bb7-8293-f6ac15fa8153
# ╠═4e25ab3b-1784-49a6-aeb4-beaf9a595ad9
# ╠═d0e6f235-e5aa-479a-bfeb-6e69ab1d0ce5
# ╠═adacce2e-967f-40e5-9383-df55ea98972a
# ╠═5b32a494-d50d-4e51-a3cc-4ec0828e4335
# ╠═acda1315-f69b-48a1-b0af-ad2fd6927d69
# ╠═2cdafd92-f519-4963-9dc2-88611c04d3dd
# ╠═d666457f-7031-46cb-99a4-6d5671592909
# ╠═28b6da7b-16c5-4524-87ec-ed681fdaa3df
# ╠═ff27d75f-babf-49af-99a9-46a360d5ea1a
# ╠═4b8e92da-d587-4682-bc4f-e2c57098bd88
# ╠═dd0cb92e-ca1c-4e8b-b0ff-41dfe43944f5
# ╠═59ca8c63-9669-41fa-a890-7dca250d3d7f
# ╠═3228ff0a-fc05-4d5a-b32d-a3d446a8e17d
# ╠═92e7dabc-679e-4714-8107-ac1201873973
# ╠═ed4446ec-2d83-45e4-a3d1-de1767f4252e
# ╠═49755d8e-0750-4400-ae93-c74e9c6c8983
# ╠═73f5503f-43d4-49cb-b76b-7baae9c7b670
# ╠═21782a16-ea9a-47e1-8c77-16fedfdcbbb5
# ╠═0a035f31-3f74-4441-b671-404937934d68
# ╠═c7592d33-67e8-4a31-8c1e-c9d5dd84fd1a
# ╠═21a872a8-1d8f-43f3-b999-33e8a7e554d5
# ╠═134b2852-c2df-4972-aace-dc704aff5307
# ╠═ca36f8a4-3545-4483-9042-9cffc4f3a628
# ╠═98df5a88-b9c1-4348-a8fb-ba3dd4fd7b84
# ╠═953da4ec-5af4-4161-807a-82ec02da6051
# ╠═91dab6a2-a285-466b-9c4f-cd694d56dad1
# ╠═eccb5744-ec80-4015-a339-03997e3aa15c
# ╠═0bdfb4a0-92bd-4ae9-ae2e-c3382eb25880
# ╠═4304b2b6-4524-4615-8a66-3aa122f69872
# ╠═c7d77fd5-8df1-4ee1-900a-a68f2810a627
# ╠═e085ff3d-b08d-49a6-861f-74b25427145b
# ╠═ebdd103f-148e-4750-a146-628c06d8e4a2
# ╠═91718788-bae6-4f7e-81da-838331d3fb8d
# ╠═c6a98ecb-ed79-44f4-997a-e36d54d226b1
# ╠═cec5ed27-0524-42de-9a77-9dd87cc2e615
# ╟─8d09d542-2917-41fc-bb30-476b32376eba
# ╠═6ff162be-ab05-4805-a0cd-e466d3a44576
# ╠═c19acb2a-4de4-4dde-bee8-077e39010d4b
# ╠═eb364ddb-bff2-4a13-b30d-e35e3e6acd12
# ╠═13d017df-a9f6-49ae-bb5d-ae8b1b5aa2ea
# ╠═0412b276-e069-45da-abbb-fc614a3289e3
# ╠═c1551dc5-787c-42aa-878c-154faf8b81d8
# ╠═a23a0435-9b46-4345-9770-e7cf01c28be3
# ╠═93e50e9c-a87e-478e-9d45-180caa00a847
# ╠═0800fb3f-53f4-4db8-8f21-006e033f3e98
# ╠═7f98a6a2-3af1-4764-b452-6828b1743e1d
# ╠═10573a52-9eaf-4288-87b6-636793c10fac
# ╠═4eb0a69b-3e9b-43f9-bf2e-841715d96d55
# ╠═0e29773f-a0d4-4e30-95ac-c970daeb38a0
# ╠═9951fdd0-864a-4c03-9442-185bd00e0215
# ╠═2d1b14a4-02f3-4f5e-99a7-8987c0e611dc
# ╠═a038f07b-33c3-4737-a44d-54ae6a622c69
# ╠═a33d38e1-5b85-45aa-8230-43ecff4ea498
# ╠═e0df712f-8ba5-4cba-a960-7e0f47d390dd
# ╠═a0c2dafa-2496-4972-a5d6-7aef8372a054
# ╠═f907709d-4fca-4047-a325-66b5725d80ed
# ╠═34d1cabc-3f0b-49b1-a71a-398045b8e2d1
# ╠═6d59b0fd-d4c8-4367-97e1-df28290e9c1c
# ╠═7fa4ccc9-a65a-4a40-bc4e-c18bf53ab28f
# ╠═5f0a1df6-0f5c-4b7b-8bd2-67c7c3cd9d33
# ╠═67b78765-28d4-40d2-a92f-0f7a0c56023f
# ╠═be5eddd3-a689-48fb-b734-9dac9ed5d728
# ╠═66172d26-a137-4d97-b91d-0942e76af4c3
# ╠═978d4f39-adc6-4611-9e9d-bcc09f048bdd
# ╠═19b5eece-aba6-4c81-bfb3-4c8f95559ac6
# ╠═9e3bc8e0-cf7f-462f-aa7f-16c8fbb3b50a
# ╠═642c9a7a-bcfb-4b51-9454-08cb0cad8f46
# ╠═0cbef536-feac-47d5-9c81-b5d7a3a10f35
# ╟─142a11cf-7aa0-4145-84e1-77aa34f402e3
