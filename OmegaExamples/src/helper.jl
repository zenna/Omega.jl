### A Pluto.jl notebook ###
# v0.17.6

using Markdown
using InteractiveUtils

# ╔═╡ a572afa6-eee7-4ddc-a8d8-11c60d5ab3d2
using Pkg


# ╔═╡ 5e329272-ea44-4b7f-b6b3-e129a2ec5506
Pkg.activate(Base.current_project())

# ╔═╡ 1cb94c62-7548-4c14-ad1b-18bf30e0ed60
using Omega

# ╔═╡ 140d776d-e21c-4102-98fb-1e88d378b0f1
using Distributions

# ╔═╡ 76cf0b42-7412-4bdc-b382-2ffcd9b11cb7
using UnicodePlots

# ╔═╡ 55a19f1f-77b5-4599-b551-617b03509e7c
Pkg.instantiate()

# ╔═╡ d0ea3dd4-04b7-4a97-bee0-558b8aec58f6
struct GridMap{T,U}
	features::Array{Array{U}}
	x_lim::T
	y_lim::T
	feature
end

# ╔═╡ b2f98dc0-ade4-4b29-87ad-79c294c0248a
begin
	mutable struct State
		loc
		time_left
		terminate_after_action
		previous_loc
		time_at_restaurant
	end

	function State(loc::Vector{Int64})
		return State(loc, 10, false, [0,0], 0)
	end
	
	# State(loc=[0,0], time_left=10, terminate_after_action= false, previous_loc=[0,0]) = State(loc, time_left, terminate_after_action, previous_loc)
end

# ╔═╡ c78e4f11-d342-4142-8f31-279f2fd5d186
begin
	mutable struct Options
		no_reverse
		max_time_at_restaurant
		transition_noise_probability
		start
		total_time
	end
end

# ╔═╡ c9a4ac3f-6c24-4df7-98c9-5f7bf0ee10da
function make_grid_map(rfeatures)
	features = reverse(rfeatures)
	feature(state::State) = features[state.loc[1]][state.loc[2]]
	return GridMap(
		features, 
		length(features[1]), 
		length(features[2]),
		feature
	)
end

# ╔═╡ 45d43f2c-84ad-11ec-364c-d12d9a8e1ebb
function in_grid_(grid_map, loc)
	return (loc[1] >= 1 && loc[1] < grid_map.x_lim && 
	loc[1] >= 1 && loc[1] < grid_map.y_lim )
end

# ╔═╡ 1f19e7d5-bf60-4c12-b781-c5b48c99f577
function is_blocked_loc(grip_map, loc)
	get_feature = grid_map.feature
	state = State(loc)
	feature = get_feature(
		state
	)
	return feature == "#"
end

# ╔═╡ c473ce9f-605b-488e-b40d-2d82e08ce513
function is_allowed_state_(grip_map, loc)
	return (in_grid_(grid_map,loc)) && !(is_blocked(grid_map, loc))
end

# ╔═╡ a8860163-ef19-485b-b956-d804a115d021
function advance_state_time!(state::State)
	state.time_left -= 1
	state.terminate_after_action = (state.time_left - 1) > 1 ? state.terminate_after_action : true
	state.previous_loc = state.loc
	return state
end

# ╔═╡ e92a8b18-dad3-4830-96a9-b4205aed0550
function add_previous!(state::State)
	state.previous_loc = state.loc
	return state
end

# ╔═╡ 5a7ec7a8-86dc-468b-b2a8-07bc851a8b8f
function advance_restaurant!(state, max_time_at_restaurant)
	state.time_at_restaurant = state.time_at_restaurant + 1
	if (state.time_at_restaurant < max_time_at_restaurant)
		return state
	else
		state.terminate_after_action = true
		return state
	end
end

# ╔═╡ 3acd5309-28b7-47e7-9417-848de664a359
function move_state(grip_map, state, action)
	loc = state.loc
	grid_transition = Dict(
		"l" => [loc[0] - 1, loc[1]], 
		"r" => [loc[0] + 1, loc[1]], 
		"u" => [loc[0], loc[1] + 1],
		"d" => [loc[0], loc[1] - 1]
		)
	possible_next_loc = grid_transition[action]
	next_loc = is_allowed_state(grid_map, possible_next_loc) ? possible_next_loc : loc
	state.loc = next_loc
	return state
end

# ╔═╡ 38b8c6a8-15dc-4e7d-b455-22d45a8d52d5


# ╔═╡ 4d99d409-cc8b-43b6-99d5-5fa92ef4f7e9
function make_grid_transition_(grid_map, options)
	function a!(state, action)
		get_feature = grid_map.feature
		options.no_reverse ? add_previous!(state) : state
		!get_feature(state).name ? advance_state_time(state) : state
		!get_feature(state).name ? move_state(grid_map, state, action) : state
		get_feature(state).name ? advance_restaurant(state, options.max_time_at_restaurant) : state
		return state
	end
	return a!
end

# ╔═╡ 6f69b871-fda9-47aa-9ed0-df03278103ab


# ╔═╡ 34654b7f-f8cf-4ef9-9d33-600af49b0f82
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

# ╔═╡ 4e27842f-a2d9-43a0-9b4b-0c3f9541d394
function make_noisy_grid_transition_(grid_map, options, transition_noise_prob)
	deterministic_transition = make_grid_transition_(grid_map, options)
	# If agent selects *key*, with *transitionNoiseProb* they do one of the two
	# orthogonal actions
	noise_action_table = Dict(
		"u" => ["l","r"],
		"d" => ["l","r"],
		"l" => ["u","d"],
		"r" => ["u","d"]
	)

	function a!(ω,state, action)
		dist = @~ Bernoulli(1 - transition_noise_prob)
		action_rand = @~ UniformDraw(noise_action_table[action])
		return dist(ω) ? deterministic_transition(state, action) : deterministic_transition(state, action_rand(ω))
	end
	return a!
end

# ╔═╡ 7fc91f80-5c40-4159-88b8-4cdee730c822
UniformDraw

# ╔═╡ Cell order:
# ╠═a572afa6-eee7-4ddc-a8d8-11c60d5ab3d2
# ╠═5e329272-ea44-4b7f-b6b3-e129a2ec5506
# ╠═55a19f1f-77b5-4599-b551-617b03509e7c
# ╠═1cb94c62-7548-4c14-ad1b-18bf30e0ed60
# ╠═140d776d-e21c-4102-98fb-1e88d378b0f1
# ╠═76cf0b42-7412-4bdc-b382-2ffcd9b11cb7
# ╠═d0ea3dd4-04b7-4a97-bee0-558b8aec58f6
# ╠═b2f98dc0-ade4-4b29-87ad-79c294c0248a
# ╠═c78e4f11-d342-4142-8f31-279f2fd5d186
# ╠═c9a4ac3f-6c24-4df7-98c9-5f7bf0ee10da
# ╠═45d43f2c-84ad-11ec-364c-d12d9a8e1ebb
# ╠═1f19e7d5-bf60-4c12-b781-c5b48c99f577
# ╠═c473ce9f-605b-488e-b40d-2d82e08ce513
# ╠═a8860163-ef19-485b-b956-d804a115d021
# ╠═e92a8b18-dad3-4830-96a9-b4205aed0550
# ╠═5a7ec7a8-86dc-468b-b2a8-07bc851a8b8f
# ╠═3acd5309-28b7-47e7-9417-848de664a359
# ╠═38b8c6a8-15dc-4e7d-b455-22d45a8d52d5
# ╠═4d99d409-cc8b-43b6-99d5-5fa92ef4f7e9
# ╠═4e27842f-a2d9-43a0-9b4b-0c3f9541d394
# ╠═6f69b871-fda9-47aa-9ed0-df03278103ab
# ╠═7fc91f80-5c40-4159-88b8-4cdee730c822
# ╟─34654b7f-f8cf-4ef9-9d33-600af49b0f82
