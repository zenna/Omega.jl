### A Pluto.jl notebook ###
# v0.17.6

using Markdown
using InteractiveUtils

# ╔═╡ d875eb5c-8c1c-11ec-36a5-7b417deacc42
using Pkg

# ╔═╡ ea4f9704-e963-4a24-b0a7-cd4ce9b9cce5
Pkg.activate(Base.current_project())

# ╔═╡ 5ea956cd-1bcc-486a-8e37-f34996d6bacd
using Memoize

# ╔═╡ a5473dde-a323-4974-a2fe-1651b9050279
using Random

# ╔═╡ dccd1f54-5462-4b4e-9ed3-592daff4cb5a
using Parameters

# ╔═╡ e75940b5-c673-4309-9252-cec8eaa9bb86
using Omega

# ╔═╡ 727b3ec9-4a96-40eb-a8a9-100644b62c1d
using Distributions

# ╔═╡ c518c20f-e8bd-4356-9f8a-9bd510af7732
using QuickPOMDPs: QuickPOMDP

# ╔═╡ 513f5a69-596b-4b01-b863-bac3199b696b
using POMDPs

# ╔═╡ 34eeb3ad-39e4-42f0-a76c-9cc5d79631d8
using POMDPModelTools: Deterministic, Uniform, SparseCat

# ╔═╡ 936f931e-ef9f-4a2d-acff-86264eb007a8
using StaticArrays

# ╔═╡ dad38bae-5e4a-40b1-a813-f4c1e9ebcd60
Pkg.instantiate()

# ╔═╡ 11428d83-66b8-4795-a3a3-63bcda095db4
struct shop
	name :: String
end

# ╔═╡ d99f4d57-a182-4603-8f24-46c20e1c8103
⌒⌒⌒ = " "

# ╔═╡ 279b5b64-5078-4b63-a661-8e01141bbe91
DN = shop("Donut N")

# ╔═╡ 03358491-7559-4525-bf7f-2123bd9c85c3
DS = shop("Donut S")

# ╔═╡ d871defa-ffa8-46d0-bf03-9943b1d036d7
V = shop("Veg")

# ╔═╡ 1c6c178d-bc54-4fbf-84d1-d5d6b01a7f6a
N = shop("Noodle")

# ╔═╡ ac19442e-78ff-480f-a070-22fc7a0aff59
grid = [
  ["#", "#", "#", "#",  V , "#"],
  ["#", "#", "#", ⌒⌒⌒, ⌒⌒⌒, ⌒⌒⌒],
  ["#", "#", DN , ⌒⌒⌒, "#", ⌒⌒⌒],
  ["#", "#", "#", ⌒⌒⌒, "#", ⌒⌒⌒],
  ["#", "#", "#", ⌒⌒⌒, ⌒⌒⌒, ⌒⌒⌒],
  ["#", "#", "#", ⌒⌒⌒, "#",  N ],
  [⌒⌒⌒, ⌒⌒⌒, ⌒⌒⌒, ⌒⌒⌒, "#", "#"],
  [DS , "#", "#", ⌒⌒⌒, "#", "#"]
];

# ╔═╡ 4db7dc50-7510-4b36-a5b0-991e81565c93
ω = defω()

# ╔═╡ 31673799-61d1-4a54-88f7-e4e220c1b220
begin
	mutable struct GridWorldState 
	    x::Int64 # x position
	    y::Int64 # y position
		time_at_restaurant::Int64 # time spent at restaurant
		time_left::Int64 # time spent at Gridworld
		previous_x::Int64
		previous_y::Int64
	    done::Bool # are we in a terminal state?
	end
	
	# initial state constructor
	GridWorldState(x::Int64, y::Int64) = GridWorldState(x,y,1,3,-1,-1,false)

	#modified state constructor
	GridWorldState(x::Int64, y::Int64, gw::GridWorldState)=
	GridWorldState(x, y, gw.time_at_restaurant, gw.time_left, gw.previous_x, gw.previous_y, gw.done)
end

# ╔═╡ 5220c5f1-c350-41d1-91ed-8e23eee82760
function advance_state_time(state_old::GridWorldState)
	@show "Advance State Time"
	state = deepcopy(state_old)
	state.time_left -= 1
	state.done = (state.time_left) > 1 ? state_old.done : true
	state.previous_x = state.x
	state.previous_y = state.y
	return state
end

# ╔═╡ 12160337-93b3-454e-ad81-27259485e1ce
function add_previous(state_old::GridWorldState)
	@show "Add Previous"
	state = deepcopy(state_old)
	state.previous_x = state.x
	state.previous_y = state.y
	return state
end

# ╔═╡ 160872cb-f98f-41e0-9479-1d905b3ae313
utility_table_default = Dict(
	"Donut S" => 1,
	"Donut N" => 1,
	"Veg" => 3,
	"Noodle" => 2,
	"time_cost" => -0.1
)

# ╔═╡ 0f91f1ec-a99f-47cf-b228-da4584c25efa
function Base.hash(state::GridWorldState, h::UInt)
	return hash((state.x, state.y, state.time_at_restaurant, state.time_left, state.previous_x, state.previous_y), h)
end

# ╔═╡ b93aa2d3-e7e4-4919-a3af-b244e15774c0
function Base.:(==)(obj1::GridWorldState, obj2::GridWorldState)
    return hash(obj1) == hash(obj2)
end

# ╔═╡ 4d3cd1d2-521c-4017-b878-390eb46e19e2
begin
	# the grid world mdp type
	mutable struct GridWorld_new <: MDP{GridWorldState, Symbol} # Note that our MDP is parametarized by the state and the action
		features::Vector{Vector{Any}}
	    size_x::Int64 # x size of the grid
	    size_y::Int64 # y size of the grid
		x_init::Int64
		y_init::Int64
		utility_table::Dict
	    tprob::Float64 # probability of transitioning to the desired state
	    discount_factor::Float64 # disocunt factor
		total_time::Int64 #total time
		max_time_at_restaurant::Int64
		no_reverse::Bool
		feature
	end
	#we use key worded arguments so we can change any of the values we pass in 
	function GridWorld_new(;features::Vector{Vector{Any}}=grid,
						size_x::Int64=6, # size_x
	                    size_y::Int64=8, # size_y
						x_init::Int64=3, #initial x position
						y_init::Int64=1, #initial y position
						utility_table::Dict=utility_table_default, #default util table
	                    tprob::Float64=0.7, # tprob
	                    discount_factor::Float64=0.9,
						total_time::Int64 = 3, #time
						max_time_at_restaurant::Int64 = 1, #max time at restmaaurant 
						no_reverse::Bool = true,
						feature = function (state::GridWorldState)
							features[state.y][state.x]
						end
		)
		@assert all(typeof(el) == String || typeof(el) == shop for el in vcat(features...)) "Grid is invalid"
		@assert total_time >=1 "total_time is invalid"
		@assert tprob <=1 "trasition_noise_probability is invalid"
		
	    return GridWorld_new(features, size_x, size_y, x_init, y_init, utility_table, tprob, discount_factor, total_time,  max_time_at_restaurant, no_reverse, feature)
	end
	
	# we can now create a GridWorld mdp instance like this:
	mdp_new = GridWorld_new()
end

# ╔═╡ ce17cc28-c18e-4090-81d6-6ebcfe66336e
function in_grid_(mdp::GridWorld_new, x::Int64, y::Int64)
	return (x >= 1 && x <= mdp.size_x && 
	y >= 1 && y <= mdp.size_y )
end

# ╔═╡ 3f2f00f3-6815-40cb-b0e3-dedca02a85dd
function POMDPs.reward(mdp::GridWorld_new, state::GridWorldState)
	utility_table = mdp.utility_table
	get_feature = mdp.feature
	feature = get_feature(state)

	if (hasproperty(feature, :name))
		return utility_table[feature.name]
	else
		return utility_table["time_cost"]
	end
end

# ╔═╡ f5692be6-d20a-4fcc-9e7d-14e27cb9f655
POMDPs.statetype(mdp::GridWorld_new) = GridWorldState

# ╔═╡ b8d5f312-3f3f-4aaf-99da-478048868dea
POMDPs.actions(mdp::GridWorld_new) = [:up, :down, :left, :right];

# ╔═╡ 2f709af9-187e-4e3b-a61e-376d228f9dda
POMDPs.discount(mdp::GridWorld_new) = mdp.discount_factor;

# ╔═╡ 0a190b03-8363-43f7-b51a-0ccee47a2a2f
POMDPs.initialstate(mdp::GridWorld_new) = ω->GridWorldState(mdp.x_init,mdp.y_init)

# ╔═╡ 096477c7-aa63-4ff4-b30c-418a6e1120a8
POMDPs.isterminal(mdp::GridWorld_new, state::GridWorldState) = state.done

# ╔═╡ 78ffd5a7-9e04-4fe7-a78f-aaafb4808d44
function is_blocked_loc(mdp::GridWorld_new, x::Int64, y::Int64)
	get_feature = mdp.feature
	state = GridWorldState(x, y)
	feature = get_feature(
		state
	)
	return feature == "#"
end

# ╔═╡ 131e8aab-b78a-47d7-9389-7375e8340d16
function is_allowed_state(mdp::GridWorld_new, state::GridWorldState)
	@show "is allowed"
	x = state.x
	y = state.y
	return (in_grid_(mdp, x, y) && !is_blocked_loc(mdp, x, y))
end

# ╔═╡ 7c1d74a7-7352-4aac-8dba-af57f2788939
function move_state(mdp::GridWorld_new, state_old::GridWorldState, action::Symbol)
	a = action
	x = state_old.x
	y = state_old.y
	state = deepcopy(state_old)
	neighbors = [
        GridWorldState(x+1, y, state_old), # right
        GridWorldState(x-1, y, state_old), # left
        GridWorldState(x, y-1, state_old), # down
        GridWorldState(x, y+1, state_old), # up
        ] # See Performance Note below
    
    targets = Dict(:right=>1, :left=>2, :down=>3, :up=>4)
    target = targets[a]

	possible_next_state = neighbors[target]
	
	next_state = is_allowed_state(mdp, possible_next_state) ? possible_next_state : state
	return next_state
end

# ╔═╡ 1085765e-e4ad-44ad-a837-935a9cb1c43c
function advance_restaurant(state_old::GridWorldState, max_time_at_restaurant)
	@show "Advance Restaurant"
	state = deepcopy(state_old)
	state.time_at_restaurant = ((state.time_at_restaurant == -1) ? 0 : state.time_at_restaurant + 1)
	if (state.time_at_restaurant >= max_time_at_restaurant - 1)
		state.done = true
	end
	return state
end

# ╔═╡ d1c5ecc9-f1d1-4b4b-b566-b5f064b77412
function make_grid_transition(mdp::GridWorld_new, state::GridWorldState, action::Symbol)
	get_feature = mdp.feature
	state = mdp.no_reverse ? add_previous(state) : state
	state = !hasproperty(get_feature(state), :name) ? advance_state_time(state) : state
	state = !hasproperty(get_feature(state), :name) ? move_state(mdp, state, action) : state
	state = hasproperty(get_feature(state), :name) ? advance_restaurant(state, mdp.max_time_at_restaurant) : state
	return state
end

# ╔═╡ 276720df-9cc0-4f40-a08b-173116daddca
function Base.isequal(a::GridWorldState,b::GridWorldState)
	return (a.x == b.x &&
	a.y == b.y &&
	a.time_at_restaurant == b.time_at_restaurant &&
	a.time_left == b.time_left &&
	a.previous_x == b.previous_x &&
	a.previous_y == b.previous_y &&
	a.done == b.done
	)
end

# ╔═╡ 88973ca5-0c2f-437f-9ff8-4007653daf5a
mdp_n = GridWorld_new()

# ╔═╡ 52cc844d-6905-4ffa-ad8c-fbbe628136f1
mdp_n.tprob = 0.0

# ╔═╡ 5f5b6ad7-8c94-4ad7-bd47-157c38ef274a
gws_new = initialstate(mdp_n)

# ╔═╡ ee7a4daa-c35a-46c2-a13f-df15bf3db8f8
mdp = GridWorld_new(;features = reverse(grid), x_init = 3, y_init = 1, tprob = 0.0, total_time = 9)

# ╔═╡ d8012ccc-32e2-46a7-a6fb-79bd093ae7e7
@memoize function 𝔼(x)
	Random.seed!(0)
	@show "Calculating Expectations"
	mean(randsample(x,1000))
end

# ╔═╡ e95fbba5-d01f-449a-ba6b-8aec445a7bd4
xs = randsample(initialstate(mdp_n))

# ╔═╡ 09b4b44e-e25d-4313-bad2-cbbd7b1c0f33
utilito = reward(mdp_n, xs)

# ╔═╡ 1e0141d4-4867-42c7-aa66-637f002004a1
xs.time_left = 1

# ╔═╡ 9f470749-a0ad-489a-a184-0032960e8ddb


# ╔═╡ 3387d656-9d03-43a7-8fd0-400fcfddca37
# begin
# 	@memoize function act(mdp, state)
# 		@show "action_block"
# 		action = ω->(9)~UniformDraw(statetoaction(mdp, state(ω)))
# 		eu = expected_utility(mdp, state, action)
# 		eu_rid = ω->rid(eu(ω), action(ω))
# 		cond = @~Bernoulli(pw(err, pw(>=ₛ, ω->𝔼(eu_rid(ω)(ω)), 0.4)))
# 		action_cond = action |ᶜ cond
# 		return Variable(action_cond)
# 	end
	
# 	@memoize function expected_utility(mdp, state_dist, action_dist)
		
# 		function expected_utility_singular_state(mdp::GridWorld_new, state::GridWorldState, action)
# 			u = reward(mdp, state)
# 			if (state.done)
# 				@show "block 1"
# 				u
# 				# return state
# 			else
# 				@show "block 2"
# 				next_state = ω->transition(mdp, state, action(ω))
# 				next_action = act(mdp, next_state)
# 				eu = ω->expected_utility(mdp, next_state, next_action(ω))
# 				pw(+,u,eu)
# 			# return eu
# 			end
# 		end
# 		util_state_dist = ω->expected_utility_singular_state(mdp, state_dist(ω), action_dist(ω))
		
# 	end
# end

# ╔═╡ 73df9a6f-f76d-4b80-bcb9-fe5fab0ba14f
x = randsample(initialstate(mdp_n))

# ╔═╡ fa83f1fb-537b-498e-aa8c-24c52af3215b
reward(mdp_n, x)

# ╔═╡ a0778bee-638c-4864-a20f-869ed6523634
mdp_n.x_init = 4

# ╔═╡ 99c2449b-00b9-433e-980c-9c40d20af68a
mdp_n.y_init = 2

# ╔═╡ f9a2c61e-37bf-44ff-ab1c-420fd895a635
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

# ╔═╡ dc1024c5-adbf-4cd6-8c6e-7cc2f37d6b8f
function POMDPs.transition(mdp::GridWorld_new, state::GridWorldState, action::Symbol)
    a = action
    x = state.x
    y = state.y
	noise_action_table = Dict(:right=>[:up,:down], :left=>[:up,:down], :down=>[:left,:right], :up=>[:left,:right]) 

	flip = @~Bernoulli(1- mdp.tprob) 
	noisy_action = @~UniformDraw(noise_action_table[action])
	return ω->(flip(ω) ? make_grid_transition(mdp, state, action) : make_grid_transition(mdp, state, noisy_action(ω)))
end;

# ╔═╡ 1e107529-8ccf-4ddd-88f8-c2fe2cf06f27
function statetoaction(mdp::GridWorld_new, state::GridWorldState)
	actions = POMDPs.actions(mdp)
	function cond(action::Symbol)
		transition_state_dist = randsample(POMDPs.transition(mdp, state, action),100)
		unitemp = unique(transition_state_dist)
		freq_table_states = [count(==(i), transition_state_dist) for i in unitemp]
		
		likely_new_state = unitemp[argmax(freq_table_states)]
		if(mdp.no_reverse && state.previous_x != -1 && state.x == likely_new_state.x && state.y == likely_new_state.y)
			return false
		else
			return state.x != likely_new_state.x || state.y != likely_new_state.y
		end
	end
	possible_actions = filter(cond, actions)
	if (length(possible_actions) > 0)
		return possible_actions
	else
		return [actions[1]]
	end
end

# ╔═╡ 6003a973-f40a-4bf1-a06b-33b2855f6bea
possible_actionso = ω -> statetoaction(mdp_n, xs)

# ╔═╡ 9a91fe7a-a4f5-4c51-af02-367f03c75244
possible_actions = ω -> statetoaction(mdp_n, initialstate(mdp_n)(ω))

# ╔═╡ 7bb2ba66-e1f7-4740-bd22-6c351868e920
gws_new2 = randsample(transition(mdp_n, gws_new(ω), :right))

# ╔═╡ 20c90f60-22f5-44b7-ade0-2a05f987b7bc
statetoaction(mdp_n,gws_new2)

# ╔═╡ 6a4663b9-c028-485a-a4c0-5d5b62bb2dcb
act(mdp_n, ω->gws_new2)

# ╔═╡ c1ff4215-d501-40c4-9b4c-b28f5676d48c
e = randsample(transition(mdp_n, gws_new2, :left))

# ╔═╡ 7c01717a-1eb2-4fe7-bcae-4801fab52412
reward(mdp_new,e)

# ╔═╡ 60f5ce6d-d2d3-4a7a-be09-164892030b72
begin
	@memoize function actor(mdp, state)
		possible_actions = ω -> statetoaction(mdp, state(ω)) #a distribution over states and actions possible in those states
		action = ω -> @~ UniformDraw(possible_actions(ω)) # a distribution over states and a distribution of actions in those states
		eu = ω -> expected_utility(mdp, state(ω), action(ω)) # returns a distribution of rewards over states
		eu_rid = ω -> rid(eu(ω), action(ω)) # returns a distribution of intervention over different states
		expected_val =  ω -> 𝔼(eu_rid(ω)(ω)) # eu_rid(ω) fixes the state, eu_rid(ω)(ω) gives the intervened distribution. So overall it will give a dist over states
		cond = ω -> @~ Bernoulli(pw(err, pw(>=ₛ, expected_val(ω), 0.4))) 
		action_cond = ω -> (action(ω) |ᶜ cond(ω))
		Variable(action_cond)
	end		
		
	@memoize function expected_utility(mdp, state, action)
		utility = reward(mdp, state) 
		if state.done
			@show "block1"
			ω->utility
		else
			@show "block2"
			next_state = ω -> transition(mdp, state, action(ω))(ω) # distribution of all possible next states 
			next_action = actor(mdp, next_state)
			eu = ω -> expected_utility(mdp, next_state(ω), next_action(ω))
			pw(+, ω -> utility, eu)
		end
	end
end

# ╔═╡ eea21cbb-6943-4089-b7dd-d5aa52449247
randsample(actor(mdp_n, initialstate(mdp_n)))

# ╔═╡ b2f97b05-0598-4bf7-8597-42bf7657a54c
actiono = ω -> @~UniformDraw(possible_actionso(ω))

# ╔═╡ 363cb319-73bf-48b1-8f78-1784f2868042
euo = ω -> expected_utility(mdp_n, xs, actiono(ω)) 

# ╔═╡ 81920d83-7ccf-440a-bd15-5b5c01ce203a
randsample(randsample(actiono))

# ╔═╡ c9578bfb-98eb-478f-951f-f116a80b36b8
possibleacts = @~ UniformDraw(statetoaction(mdp_n, xs))

# ╔═╡ 7d7e3b69-c0dc-419c-87a1-eda1b0a2d37c
next_stateo = ω -> transition(mdp_n, xs, possibleacts(ω))(ω)

# ╔═╡ d9bd8ead-2f3a-4558-974a-6cd0b9d74ed6
randsample(next_stateo)

# ╔═╡ 7720d154-81bd-4869-abe4-53191a823b93
possibleactionso2 = ω -> statetoaction(mdp, next_stateo(ω))

# ╔═╡ 412acb89-db2a-4667-aa14-736ecfc342a2
actionso2 = ω -> @~ UniformDraw(possibleactionso2(ω))

# ╔═╡ 99021588-af96-44da-ac68-2d010faf8dfc
euo2 = ω -> expected_utility(mdp_n, next_stateo(ω), actionso2(ω))

# ╔═╡ fc15721a-8b69-4f06-aa63-d53ce55d3dac
euo2_rid = ω -> rid(euo2(ω), actionso2(ω))

# ╔═╡ 602326db-8481-4195-865b-32faedc348ac
randsample(randsample(randsample(euo2_rid)))

# ╔═╡ 6f2caf7f-6214-47a2-9a21-decedb4ae869
expectedo = ω -> 𝔼(euo2_rid(ω)(ω))

# ╔═╡ 004fb709-36c3-4d1d-92e5-76028d5bb2ae
randsample(expectedo)

# ╔═╡ 4639f57d-5998-4a62-9f03-4cbe38f97ba3
action = ω -> @~ UniformDraw(possible_actions(ω))

# ╔═╡ c93183e8-f6cd-4f33-9ab1-598967b66c22
randsample(action)

# ╔═╡ 9a4e4221-b5f8-48cf-995c-dcfd8c893333
acs = @~UniformDraw([:up,:right])

# ╔═╡ 5c06ae23-9746-4953-9238-8ddc7e74194c
rx = randsample(randsample(ω->transition(mdp_n, x, acs(ω))))

# ╔═╡ 3244f1ca-3d82-4bc1-890c-490b9d0fc8d3
s = randsample(transition(mdp_n, rx, :up))

# ╔═╡ 32ba8762-2e6b-4edf-9ac3-9b02240c90a6
randsample(@~UniformDraw(statetoaction(mdp_n, gws_new)))

# ╔═╡ Cell order:
# ╠═d875eb5c-8c1c-11ec-36a5-7b417deacc42
# ╠═5ea956cd-1bcc-486a-8e37-f34996d6bacd
# ╠═a5473dde-a323-4974-a2fe-1651b9050279
# ╠═ea4f9704-e963-4a24-b0a7-cd4ce9b9cce5
# ╠═dad38bae-5e4a-40b1-a813-f4c1e9ebcd60
# ╠═dccd1f54-5462-4b4e-9ed3-592daff4cb5a
# ╠═e75940b5-c673-4309-9252-cec8eaa9bb86
# ╠═727b3ec9-4a96-40eb-a8a9-100644b62c1d
# ╠═c518c20f-e8bd-4356-9f8a-9bd510af7732
# ╠═513f5a69-596b-4b01-b863-bac3199b696b
# ╠═34eeb3ad-39e4-42f0-a76c-9cc5d79631d8
# ╠═936f931e-ef9f-4a2d-acff-86264eb007a8
# ╠═11428d83-66b8-4795-a3a3-63bcda095db4
# ╠═d99f4d57-a182-4603-8f24-46c20e1c8103
# ╠═279b5b64-5078-4b63-a661-8e01141bbe91
# ╠═03358491-7559-4525-bf7f-2123bd9c85c3
# ╠═d871defa-ffa8-46d0-bf03-9943b1d036d7
# ╠═1c6c178d-bc54-4fbf-84d1-d5d6b01a7f6a
# ╠═ac19442e-78ff-480f-a070-22fc7a0aff59
# ╠═4db7dc50-7510-4b36-a5b0-991e81565c93
# ╠═4d3cd1d2-521c-4017-b878-390eb46e19e2
# ╠═31673799-61d1-4a54-88f7-e4e220c1b220
# ╠═ce17cc28-c18e-4090-81d6-6ebcfe66336e
# ╠═78ffd5a7-9e04-4fe7-a78f-aaafb4808d44
# ╠═131e8aab-b78a-47d7-9389-7375e8340d16
# ╠═5220c5f1-c350-41d1-91ed-8e23eee82760
# ╠═12160337-93b3-454e-ad81-27259485e1ce
# ╠═1085765e-e4ad-44ad-a837-935a9cb1c43c
# ╠═7c1d74a7-7352-4aac-8dba-af57f2788939
# ╠═d1c5ecc9-f1d1-4b4b-b566-b5f064b77412
# ╠═1e107529-8ccf-4ddd-88f8-c2fe2cf06f27
# ╠═160872cb-f98f-41e0-9479-1d905b3ae313
# ╠═dc1024c5-adbf-4cd6-8c6e-7cc2f37d6b8f
# ╠═3f2f00f3-6815-40cb-b0e3-dedca02a85dd
# ╠═f5692be6-d20a-4fcc-9e7d-14e27cb9f655
# ╠═b8d5f312-3f3f-4aaf-99da-478048868dea
# ╠═2f709af9-187e-4e3b-a61e-376d228f9dda
# ╠═0a190b03-8363-43f7-b51a-0ccee47a2a2f
# ╠═096477c7-aa63-4ff4-b30c-418a6e1120a8
# ╠═276720df-9cc0-4f40-a08b-173116daddca
# ╠═0f91f1ec-a99f-47cf-b228-da4584c25efa
# ╠═b93aa2d3-e7e4-4919-a3af-b244e15774c0
# ╠═88973ca5-0c2f-437f-9ff8-4007653daf5a
# ╠═52cc844d-6905-4ffa-ad8c-fbbe628136f1
# ╠═5f5b6ad7-8c94-4ad7-bd47-157c38ef274a
# ╠═7bb2ba66-e1f7-4740-bd22-6c351868e920
# ╠═c1ff4215-d501-40c4-9b4c-b28f5676d48c
# ╠═20c90f60-22f5-44b7-ade0-2a05f987b7bc
# ╠═7c01717a-1eb2-4fe7-bcae-4801fab52412
# ╠═ee7a4daa-c35a-46c2-a13f-df15bf3db8f8
# ╠═d8012ccc-32e2-46a7-a6fb-79bd093ae7e7
# ╠═60f5ce6d-d2d3-4a7a-be09-164892030b72
# ╠═6003a973-f40a-4bf1-a06b-33b2855f6bea
# ╠═b2f97b05-0598-4bf7-8597-42bf7657a54c
# ╠═363cb319-73bf-48b1-8f78-1784f2868042
# ╠═09b4b44e-e25d-4313-bad2-cbbd7b1c0f33
# ╠═e95fbba5-d01f-449a-ba6b-8aec445a7bd4
# ╠═1e0141d4-4867-42c7-aa66-637f002004a1
# ╠═c9578bfb-98eb-478f-951f-f116a80b36b8
# ╠═7d7e3b69-c0dc-419c-87a1-eda1b0a2d37c
# ╠═d9bd8ead-2f3a-4558-974a-6cd0b9d74ed6
# ╠═7720d154-81bd-4869-abe4-53191a823b93
# ╠═412acb89-db2a-4667-aa14-736ecfc342a2
# ╠═99021588-af96-44da-ac68-2d010faf8dfc
# ╠═fc15721a-8b69-4f06-aa63-d53ce55d3dac
# ╠═9f470749-a0ad-489a-a184-0032960e8ddb
# ╠═602326db-8481-4195-865b-32faedc348ac
# ╠═6f2caf7f-6214-47a2-9a21-decedb4ae869
# ╠═004fb709-36c3-4d1d-92e5-76028d5bb2ae
# ╠═81920d83-7ccf-440a-bd15-5b5c01ce203a
# ╟─eea21cbb-6943-4089-b7dd-d5aa52449247
# ╠═9a91fe7a-a4f5-4c51-af02-367f03c75244
# ╠═4639f57d-5998-4a62-9f03-4cbe38f97ba3
# ╠═c93183e8-f6cd-4f33-9ab1-598967b66c22
# ╠═3387d656-9d03-43a7-8fd0-400fcfddca37
# ╠═73df9a6f-f76d-4b80-bcb9-fe5fab0ba14f
# ╠═fa83f1fb-537b-498e-aa8c-24c52af3215b
# ╠═5c06ae23-9746-4953-9238-8ddc7e74194c
# ╠═3244f1ca-3d82-4bc1-890c-490b9d0fc8d3
# ╠═9a4e4221-b5f8-48cf-995c-dcfd8c893333
# ╠═32ba8762-2e6b-4edf-9ac3-9b02240c90a6
# ╠═a0778bee-638c-4864-a20f-869ed6523634
# ╠═99c2449b-00b9-433e-980c-9c40d20af68a
# ╠═6a4663b9-c028-485a-a4c0-5d5b62bb2dcb
# ╟─f9a2c61e-37bf-44ff-ab1c-420fd895a635
