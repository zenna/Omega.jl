### A Pluto.jl notebook ###
# v0.17.6

using Markdown
using InteractiveUtils

# ╔═╡ d875eb5c-8c1c-11ec-36a5-7b417deacc42
using Pkg

# ╔═╡ ea4f9704-e963-4a24-b0a7-cd4ce9b9cce5
Pkg.activate(Base.current_project())

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

# ╔═╡ 9feac2fb-619d-452a-813d-ca3a94ff4969
const GWPos = SVector{2,Int}

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

# ╔═╡ d7030fa1-1151-4de9-846f-26abf04cfae9
vcat(grid...)

# ╔═╡ 3f2f00f3-6815-40cb-b0e3-dedca02a85dd


# ╔═╡ 4db7dc50-7510-4b36-a5b0-991e81565c93
ω = defω()

# ╔═╡ 1ccc3e1e-9c88-4917-80fe-8f5e43cf36a9
a4 = ω ->(@~Bernoulli(0.7)(ω),1000)

# ╔═╡ e4ee460a-cf12-4d5e-9e70-602ed1dfc8b1
@with_kw struct Options
	grid::Array{Array{Any}} = [[⌒⌒⌒]]
	no_reverse::Bool = false
	max_time_at_restaurant::Int = 1
	transition_noise_probability::Float64 = 0
	start::Tuple{Int,Int} = (0,0)
	total_time::Int = 2
end

# ╔═╡ 0374afc2-6761-489a-9b01-28296ce143d1
option1 = Options(;grid = grid)

# ╔═╡ 5b9f2393-f86d-4bc2-a277-93c9cea1b46a
struct GridMap{T,U}
	features::Array{Array{U}}
	x_lim::T
	y_lim::T
	feature
end

# ╔═╡ 27e98d7a-bc6d-4a86-b6e3-082c35c0caed
@with_kw struct GridWorld <: MDP{GWPos, Symbol}
	grid::Array{Array{Any}} = [[⌒⌒⌒]]
	no_reverse::Bool = false
	max_time_at_restaurant::Int = 1
	transition_noise_probability::Float64 = 0
	start::GWPos= [1,1]
	total_time::Int = 2
end

# ╔═╡ 6bb50edd-9b71-457a-905d-ad2ed7f209bb
@with_kw struct State
	loc::GWPos = [0,0]
	time_left::Int64 = 10
	previous_loc::GWPos = [-1,-1]
	time_at_restaurant::Int64 = 0
end

# ╔═╡ e18ae6a1-7e16-4ab2-b424-6c314bd0413d
Base.copy(s::State) = State(s.loc, s.time_left, s.previous_loc, s.time_at_restaurant)

# ╔═╡ 2376b7aa-e8c7-48d1-be51-22caeb622cc4
function make_grid_map(rfeatures)
	features = reverse(rfeatures)
	feature(state::State) = features[state.loc[2]][state.loc[1]]
	return GridMap(
		features, 
		length(features[1]), 
		length(features[2]),
		feature
	)
end

# ╔═╡ f5692be6-d20a-4fcc-9e7d-14e27cb9f655
POMDPs.statetype(mdp::GridWorld) = State

# ╔═╡ 76efa48c-9394-45be-8535-8595dc1c5814
POMDPs.actions(mdp::GridWorld) = (:up, :down, :left, :right)

# ╔═╡ 3ad4e92b-6bb2-4872-b45e-82e88e47a6a0
POMDPs.initialstate(mdp::GridWorld) = State()

# ╔═╡ 502a7938-0c31-4e31-a623-093ced91c390
const dir = Dict(:up=>GWPos(0,1), :down=>GWPos(0,-1), :left=>GWPos(-1,0), :right=>GWPos(1,0))

# ╔═╡ e1cc7ce2-9a6f-402a-b822-00c0fab00583
const aind = Dict(:up=>1, :down=>2, :left=>3, :right=>4)

# ╔═╡ ad3977d5-306c-49da-a641-cf997b79a784
POMDPs.actionindex(mdp, a) = aind[a]

# ╔═╡ ffa56337-98f0-415b-9fca-85a69c19a039
POMDPs.isterminal(m, s::AbstractVector{Int}) = any(s.time_left==0)

# ╔═╡ ce17cc28-c18e-4090-81d6-6ebcfe66336e
function in_grid_(grid_map, loc)
	return (loc[1] >= 1 && loc[1] < grid_map.x_lim && 
	loc[1] >= 1 && loc[1] < grid_map.y_lim )
end

# ╔═╡ 78ffd5a7-9e04-4fe7-a78f-aaafb4808d44
function is_blocked_loc(grip_map, loc)
	get_feature = grid_map.feature
	state = State(loc)
	feature = get_feature(
		state
	)
	return feature == "#"
end

# ╔═╡ 131e8aab-b78a-47d7-9389-7375e8340d16
function is_allowed_state(grid_map, loc)
	return (in_grid_(grid_map, loc) && !is_blocked_loc(grid_map, loc))
end

# ╔═╡ 5220c5f1-c350-41d1-91ed-8e23eee82760
function advance_state_time(state_old)
	state = copy(state_old)
	state.time_left -= 1
	state.terminate_after_action = state.time_left - 1 > 1 ? state.terminate_after_action : true
	state.previous_loc = state.loc
	return state
end

# ╔═╡ 12160337-93b3-454e-ad81-27259485e1ce
function add_previous(state_old)
	state = copy(state_old)
	state.previous_loc = state.loc
	return state
end

# ╔═╡ 1085765e-e4ad-44ad-a837-935a9cb1c43c
function advance_restaurant(state_old, max_time_at_restaurant)
	state = copy(state_old)
	state.time_at_restaurant = ((state.time_at_restaurant == -1) ? 0 : state.time_at_restaurant + 1)
	if (state.time_at_restaurant >= max_time_at_restaurant - 1)
		state.terminate_after_action = true
	end
	return state
end

# ╔═╡ 7c1d74a7-7352-4aac-8dba-af57f2788939
function move_state(grid_map, state_old, action)
	state = copy(state_old)
	loc = state.loc
	grid_transition = Dict(
		l => [loc[1] - 1, loc[2]],
		r => [loc[1] + 1, loc[2]],
		u => [loc[1], loc[2] + 1],
		d => [loc[1], loc[2] - 1]
	)
	possible_next_loc = grid_transition[action]
	next_loc = is_allowed_state(grid_map, possible_next_loc) ? possible_next_loc : loc
	state.loc = next_loc
	return state
end

# ╔═╡ 18ffc90a-b7ed-4879-913f-2e30e915a101
function make_grid_transition_(grid_map, options)
	function move(state_old, action)
		state = copy(state_old)
		get_feature = grid_map.feature
		state = option.no_reverse ? add_previous(state) : state
		state = !hasproperty(get_feature(state), :name) ? advance_state_time(state) : state
		state = !hasproperty(get_feature(state), :name) ? move_state(grid_map, state, action) : state
		state = hasproperty(get_feature(state), :name) ? advance_restaurant(state, options.max_time_at_restaurant) : state
		return state
	end
	return move
end		

# ╔═╡ 06b213e8-5961-4f89-a764-7e8cbc77c9fa
function make_grid_world_deterministic(features, options)
	grid_map = make_grid_map(features)
	transition = make_grid_transition_(grid_map, options)
	actions = ["l", "r", "u", "d"]
	function state_to_actions(state)
		function cond(action)
			new_state = transition(state, action)
			if (options.no_reverse && state.previous_loc && state.previous_loc == new_state.loc)
				return false
			end
			return state.loc != new_state.loc
		end
		possible_actions = filter(cond, actions)
		if (length(possible_actions)>0)
			return possible_actions
		else
			return [actions[0]]
		end
		return
	end

	grid_map.transition = transition
	grid_map.actions = actions
	grid_map.state_to_actions = state_to_actions
	return grid_map
end	

# ╔═╡ d30ec417-243b-4410-bde4-bb9b5eb29e1d
function make_grid_world_MDP(options::Options)
	@assert all(typeof(el) == String || typeof(el) == shop for el in vcat(options.grid...)) "Grid is invalid"
	@assert options.total_time >=1 "total_time is invalid"
	@assert options.trasition_noise_probability <=1 "trasition_noise_probability is invalid"

	world = (options.transition_noise_probability == 0) ? make_grid_world_deterministic(options.grid, options) : make_noisy_grid_world(options.grid, options)

	# POMDPs.initialstate = State(;loc = options.start, terminate_after_action = false, time_left = options.total_time)

	function make_utility_function(utility)
		function reward(state, action)
			get_feature = world.feature
			feature = get_feature(state)

			if (feature.name)
				return utility_table[feature.name]
			else
				return utility_table.time_cost
			end
		end
		return reward
	end

	return (world, start_state, make_utility_function)

end

# ╔═╡ 9ed317eb-8913-4f7f-a8cb-85aabd211eca
function POMDPs.transition(mdp::GridWorld, s::State, a::Symbol, grid_map::GridMap)
	if isterminal(mdp, s)
		s.loc = GWPos(-1,-1)
		return Deterministic(s)
	end

	destinations = MVector{length(actions(mdp)) + 1, State}(undef)
	destination[1] = s
	deterministic_transition = make_grid_transition(grid_map, options)
	probs = @MVector(zeros(length(actions(mdp))+1))
	for (i,act) in enumerate(actions(mdp))
		if (act == a)
			prob = mdp.transition_noise_probability
		else
			prob = (1.0 - mdp.transition_noise_probability)/(length(actions(mdp))-1)
		end
		dest = deterministic_transition(s,a)
		destinations[i+1] = dest

		if !is_allowed_state(mdp, dest)
			probs[1] += prob
			s.loc = GWPos(-1,-1)
			s.time_left -= 1
			destinations[i+1] = s
		else
			probs[i+1] += prob
		end
	end
	return SparseCat(destinations, probs)
end

# ╔═╡ 21eee098-da90-4ad7-907c-539ae8ccc3d4
check = @~SparseCat(["a","b","c"],[0.1,0.8,0.1])

# ╔═╡ dc74d942-e9b3-4623-a7f8-a547953806e3
state1 = State()

# ╔═╡ e3230d70-4205-4bb0-8892-e2554c52d58d
state1.time_left

# ╔═╡ 004ff0b5-8ec3-4990-93c2-9d760deb0580
a::Tuple{Int,Int} = (1,2)

# ╔═╡ 2ba4cf69-e950-4d7c-b823-663efe8147e1
struct GWUniform
    size::Tuple{Int, Int}
end

# ╔═╡ 1bec9210-6eda-4bb7-99b0-772e5eb01a82
a5 = "3"

# ╔═╡ af318de9-b808-4d29-ac39-c24327ef5b42
hasproperty(a5 , :field) ? 3 : 4

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

# ╔═╡ 4438b5e0-edf5-42b9-90fc-acc59dee51a4
function POMDPs.transition(ω,grid_map, s, a, options)
	deterministic_transition = make_grid_transition(grid_map, options)
	noise_action_table = Dict(
    "u" => ["l", "r"],
    "d" => ["l", "r"],
    "l" => ["u", "d"],
    "r" => ["u", "d"]
	)
	return @~Bernoulli(1-options.transition_noise_prob)(ω) ? deterministic_transition(s, a) : deterministic_transition(s, @~UniformDraw(noise_action_table[a])(ω))
end

# ╔═╡ e96f0848-18be-472b-bca2-bf9a7c86af8d
function make_gw_(features, option)
	grid_map = make_grid_map(features)
	actions = ["l","r","u","d"]
	function state_to_actions(state)
		function cond(action)
			transition_dist = transition(options, state, action, features)
			likely_new_state = transition_dist.val[findmax(identity,  transition_dist.probs)[2]]
			if (options.no_reverse && state.previous_loc == likely_new_state.loc)
				return false
			else
				state.loc[0] != likely_new_state.loc[0] || state.loc[1] !== likely_new_state.loc[1]
			end
		end
		possible_actions = filter(cond, actions)
		if length(possible_actions) > 0
			return possible_actions
		else
			return actions[0]
		end
	end
	grid_map.transition = transition
	grid_map.actions = actions
	grid_map.state_to_actions = state_to_actions
end

# ╔═╡ b68bcb8e-073a-4dde-9cd1-0223e1bdd6db
function make_grid_world_MDP(options)
	@assert all(typeof(el) == String || typeof(el) == shop for el in vcat(options.grid...)) "Grid is invalid"
	@assert options.total_time >=1 "total_time is invalid"
	@assert options.transition_noise_probability <=1 "transition_noise_probability is invalid"
	world = make_gw_(options.grid, options)
	start_state = State(;
		loc = options.start, 
		terminate_after_action = false, 
		time_left = options.total_time)

	function make_utility_function(utility_table)
		@assert hasproperty(utility_table, :time_cost) "makeUtilityFunction utilityTable lacks timeCost"
		function a_(state, action)
			get_feature = world.feature
			feature = get_feature(state)

			if hasproperty(feature, :name)
				return utility_table[feature.name]
			else
				return utility_table["time_cost"]
			end

		end
		return a_
	end
	return (world, start_state, make_utility_function)
end

# ╔═╡ 021c39c5-91be-4c9b-81ea-b5085fb1f003
mdp = make_grid_world_MDP(GridWorld(;grid = grid, start=[3,1]))

# ╔═╡ Cell order:
# ╠═d875eb5c-8c1c-11ec-36a5-7b417deacc42
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
# ╠═9feac2fb-619d-452a-813d-ca3a94ff4969
# ╠═d99f4d57-a182-4603-8f24-46c20e1c8103
# ╠═279b5b64-5078-4b63-a661-8e01141bbe91
# ╠═03358491-7559-4525-bf7f-2123bd9c85c3
# ╠═d871defa-ffa8-46d0-bf03-9943b1d036d7
# ╠═1c6c178d-bc54-4fbf-84d1-d5d6b01a7f6a
# ╠═ac19442e-78ff-480f-a070-22fc7a0aff59
# ╠═d7030fa1-1151-4de9-846f-26abf04cfae9
# ╠═06b213e8-5961-4f89-a764-7e8cbc77c9fa
# ╠═d30ec417-243b-4410-bde4-bb9b5eb29e1d
# ╠═3f2f00f3-6815-40cb-b0e3-dedca02a85dd
# ╠═4db7dc50-7510-4b36-a5b0-991e81565c93
# ╠═1ccc3e1e-9c88-4917-80fe-8f5e43cf36a9
# ╠═0374afc2-6761-489a-9b01-28296ce143d1
# ╠═e4ee460a-cf12-4d5e-9e70-602ed1dfc8b1
# ╠═5b9f2393-f86d-4bc2-a277-93c9cea1b46a
# ╠═27e98d7a-bc6d-4a86-b6e3-082c35c0caed
# ╠═6bb50edd-9b71-457a-905d-ad2ed7f209bb
# ╠═e18ae6a1-7e16-4ab2-b424-6c314bd0413d
# ╠═2376b7aa-e8c7-48d1-be51-22caeb622cc4
# ╠═f5692be6-d20a-4fcc-9e7d-14e27cb9f655
# ╠═76efa48c-9394-45be-8535-8595dc1c5814
# ╠═3ad4e92b-6bb2-4872-b45e-82e88e47a6a0
# ╠═502a7938-0c31-4e31-a623-093ced91c390
# ╠═e1cc7ce2-9a6f-402a-b822-00c0fab00583
# ╠═ad3977d5-306c-49da-a641-cf997b79a784
# ╠═ffa56337-98f0-415b-9fca-85a69c19a039
# ╠═ce17cc28-c18e-4090-81d6-6ebcfe66336e
# ╠═78ffd5a7-9e04-4fe7-a78f-aaafb4808d44
# ╠═131e8aab-b78a-47d7-9389-7375e8340d16
# ╠═5220c5f1-c350-41d1-91ed-8e23eee82760
# ╠═12160337-93b3-454e-ad81-27259485e1ce
# ╠═1085765e-e4ad-44ad-a837-935a9cb1c43c
# ╠═7c1d74a7-7352-4aac-8dba-af57f2788939
# ╠═18ffc90a-b7ed-4879-913f-2e30e915a101
# ╠═4438b5e0-edf5-42b9-90fc-acc59dee51a4
# ╠═9ed317eb-8913-4f7f-a8cb-85aabd211eca
# ╠═21eee098-da90-4ad7-907c-539ae8ccc3d4
# ╠═e96f0848-18be-472b-bca2-bf9a7c86af8d
# ╠═b68bcb8e-073a-4dde-9cd1-0223e1bdd6db
# ╠═021c39c5-91be-4c9b-81ea-b5085fb1f003
# ╠═dc74d942-e9b3-4623-a7f8-a547953806e3
# ╠═e3230d70-4205-4bb0-8892-e2554c52d58d
# ╠═004ff0b5-8ec3-4990-93c2-9d760deb0580
# ╠═2ba4cf69-e950-4d7c-b823-663efe8147e1
# ╠═1bec9210-6eda-4bb7-99b0-772e5eb01a82
# ╠═af318de9-b808-4d29-ac39-c24327ef5b42
# ╟─f9a2c61e-37bf-44ff-ab1c-420fd895a635
