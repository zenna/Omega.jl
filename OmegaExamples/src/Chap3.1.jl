### A Pluto.jl notebook ###
# v0.17.6

using Markdown
using InteractiveUtils

# ╔═╡ 3ddf69be-4c35-4b0b-83a1-924878b0c539
using Pkg

# ╔═╡ ccda30a3-c569-4756-96e2-3a777fb937e7
Pkg.activate(Base.current_project())

# ╔═╡ 1fc71e72-ab61-42b7-a3a6-ccf2ea687029
using Random

# ╔═╡ 9f00e14b-2ba6-47aa-892f-19d0e5819db1
using Memoize

# ╔═╡ fb5ce5c3-6741-4903-a9fa-68b9b746c7b6
using Omega

# ╔═╡ d17a298c-3a5f-4212-99fc-fda8decb1bc7
using Distributions

# ╔═╡ dc47f83f-5d7b-42cf-aca1-c0861005f358
using UnicodePlots

# ╔═╡ 6035dc7e-f50f-4c70-aade-f756ef53f9a8
Pkg.instantiate()

# ╔═╡ 49fb02ac-92d1-11ec-3ecc-b77df9024aed
md"# Sequential decision problems: MDPs"

# ╔═╡ 8708b9e2-403b-4171-83a9-03a37622734c
md"## Introduction"

# ╔═╡ 2c7b594e-f2f0-4327-b002-ab821842123e
md"The previous chapter introduced agent models for solving simple, one-shot decision problems. The next few sections introduce sequential problems, where an agent’s choice of action now depends on the actions they will choose in the future. As in game theory, the decision maker must coordinate with another rational agent. But in sequential decision problems, that rational agent is their future self.

As a simple illustration of a sequential decision problem, suppose that an agent, Bob, is looking for a place to eat. Bob gets out of work in a particular location (indicated below by the blue circle). He knows the streets and the restaurants nearby. His decision problem is to take a sequence of actions such that (a) he eats at a restaurant he likes and (b) he does not spend too much time walking. Here is a visualization of the street layout. The labels refer to different types of restaurants: a chain selling Donuts, a Vegetarian Salad Bar and a Noodle Shop."

# ╔═╡ 2107f5c0-1aa7-4586-a2e6-69130d40196c


# ╔═╡ cde27e2b-0b3c-4464-962e-67e996d7747b
md"## Markov Decision Processes: Definition"

# ╔═╡ 63379ccd-62f7-4ea5-b19b-54d2c84b04ea
md"We represent Bob’s decision problem as a Markov Decision Process (MDP) and, more specifically, as a discrete “Gridworld” environment. An MDP is a tuple $\left\langle S,A(s),T(s,a),U(s,a) \right\rangle$, including the states, the actions in each state, the transition function that maps state-action pairs to successor states, and the utility or reward function. In our example, the states SS are Bob’s locations on the grid. At each state, Bob selects an action a $\in \{ \text{up}, \text{down}, \text{left}, \text{right} \}$, which moves Bob around the grid (according to transition function TT). In this example we assume that Bob’s actions, as well as the transitions and utilities, are all deterministic. However, our approach generalizes to noisy actions, stochastic transitions and stochastic utilities.

As with the one-shot decisions of the previous chapter, the agent in an MDP will choose actions that maximize expected utility. This depends on the total utility of the sequence of states that the agent visits. Formally, let $EU_{s}[a]$
be the expected (total) utility of action $a$ in state $s$. The agent’s choice is a softmax function of this expected utility:

$C(a; s) \propto e^{\alpha EU_{s}[a]}$
The expected utility depends on both immediate utility and, recursively, on future expected utility:"

# ╔═╡ bf3d374c-b032-4ee4-8861-6378cd4b7ee9
md"#### Expected Utility Recursion:"

# ╔═╡ a57f1bcf-41a9-4710-b41c-3754e0246786
md"$EU_{s}[a] = U(s, a) + \mathbb{E}_{s', a'}(EU_{s'}[a'])$
with the next state $s' \sim T(s,a)$
 and $a' \sim C(s')$
. The decision problem ends either when a terminal state is reached or when the time-horizon is reached. (In the next few chapters the time-horizon will always be finite).

The intuition to keep in mind for solving MDPs is that the expected utility propagates backwards from future states to the current action. If a high utility state can be reached by a sequence of actions starting from action aa, then action aa will have high expected utility – provided that the sequence of actions is taken with high probability and there are no low utility steps along the way.

"

# ╔═╡ abf88e93-72ba-49ac-b0d6-d805c9a0c5a3
md"## Markov Decision Processes: Implementation"

# ╔═╡ 9b8442f4-6e36-4f7f-bba4-ad20a370e146
md"The recursive decision rule for MDP agents can be directly translated into Omega. The act function takes the agent’s state as input, evaluates the expectation of actions in that state, and returns a softmax distribution over actions. The expected utility of actions is computed by a separate function expectedUtility. Since an action’s expected utility depends on future actions, expectedUtility calls act in a mutual recursion, bottoming out when a terminal state is reached or when time runs out.

We illustrate this “MDP agent” on a simple MDP:"

# ╔═╡ 37a65832-80eb-40fe-b581-c8ba2651c370
md"### Integer Line MDP"

# ╔═╡ ff8c19d5-b3df-4891-a9ca-4181c12b94ce
md"- **States**: Points on the integer line (e.g -1, 0, 1, 2).

- **Actions/transitions**: Actions “left”, “right” and “stay” move the agent deterministically along the line in either direction.

- **Utility**: The utility is 11 for the state corresponding to the integer 33 and is 00 otherwise.

Here is a WebPPL agent that starts at the origin (state === 0) and that takes a first step (to the right):

"

# ╔═╡ c22de25e-9006-4ba5-9991-eb3c077dcd35
ω = defω()

# ╔═╡ 3b9cf8fe-a934-4a35-b460-ea9d360ae5ea
function transition(state, action)
	return ω -> (state(ω) + action(ω))
end

# ╔═╡ 85d9e825-b482-40ff-bcbb-24492317292e
function utility(state)
	if (state == 3)
		return 1
	else
		return 0
	end
end

# ╔═╡ 192f1939-db26-4615-bd89-5ba6a50edfab
@memoize function 𝔼(x)
	Random.seed!(0)
	@show "Calculating Expectations"
	mean(randsample(x,1000))
end

# ╔═╡ 345d357e-0c38-4f2f-8212-9a6294c20201
@memoize function 𝔼_withkernel(x)
	Random.seed!(0)
	@show "Calculating Expectations"
	withkernel(Omega.kseα(15)) do
		mean(randsample(x,1000))
	end
end

# ╔═╡ cc99bbc6-cccf-40e0-b9c0-6de269ca4b8b


# ╔═╡ cecf0fe9-5a14-4b14-95a8-2344fde2ba6d
dist4 = @~Normal()

# ╔═╡ 7034bd97-370b-4fb2-976a-56bfcc83035c
randsample(dist4)

# ╔═╡ 58db6264-e702-41c8-b0df-efb1f8cae6ff
distsome = ω->@~Bernoulli(pw(err,(1.0 <=ₛ dist4(ω))))

# ╔═╡ 16057439-1dee-4c50-9615-bd34e47c462a
𝔼(pw(err,ω->(1.0 <=ₛ dist4(ω))))

# ╔═╡ e90bf9ea-36fa-454b-94b6-856c00578ac7
randsample(distsome)

# ╔═╡ a7e555b4-1e87-4a8b-af20-1e1d7423bd41
trip = ω->(@~Bernoulli(err(withkernel(Omega.kseα(10)) do
(1 <=ₛ dist4(ω))
end)))

# ╔═╡ 7f4bbb89-e8c9-48b1-b4d9-369751542852
trip2 = withkernel(Omega.kseα(10)) do
	@~Bernoulli(ω->(err(1.0 <=ₛ dist4(ω))))
	end

# ╔═╡ 4e93f5a4-dd05-4ef9-97a7-fe5398cfbba1


# ╔═╡ b9d6374c-d6d0-43f1-b91d-05bd6b5e066f
𝔼(trip(ω))

# ╔═╡ 178ad31b-2147-44db-a090-3bd2f80125a6
sone_cond = dist4 |ᶜ trip2

# ╔═╡ 4286953b-54dd-4003-a59f-db3eb7a678d4
𝔼(sone_cond)

# ╔═╡ c73ce385-eeb2-45a9-8602-f725ae94556b
trip_cond = ω->(dist4 |ᶜ trip(ω))

# ╔═╡ 9ddcba63-7302-4fa2-9000-b195f7478d8a
𝔼(randsample(trip_cond))

# ╔═╡ bd65ee7d-f6bb-4b19-93ea-fa15970c3bda
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

# ╔═╡ 62c5a031-fa6d-427f-b29c-e517afffa134
state_s = @~UniformDraw([0, 1, 2])

# ╔═╡ 0ec5835a-02c9-4740-925a-c34c1a04d817
action_s = @~UniformDraw([-1, 0, 1])

# ╔═╡ 089b72f7-f957-45c4-b47d-39457c4b9fcb
action_s1 = @~UniformDraw([-1, 0, 1])

# ╔═╡ 5b635a24-f6e0-4208-8b99-aa3fdf23a282
begin
	@memoize function act1(state, time_left)
		@show "action_block"
		action = (9+time_left)~UniformDraw([-1, 0, 1])
		eu = expected_utility(state, action, time_left)
		eu_rid = rid(eu, action)
		cond = @~Bernoulli(pw(err,pw(>=ₛ, ω->𝔼(eu_rid(ω)), 0.4)))
		action_cond = action |ᶜ cond
		return Variable(action_cond)
	end
	
	@memoize function expected_utility(state, action, time_left)
		u = ω->utility(state(ω))
		new_time_left = time_left - 1
		@show new_time_left
		if (new_time_left == 0)
			@show "block 1"
			return u
			# return state
		else
			@show "block 2"
			next_state = pw(+, state, action)
			next_action = act1(next_state, new_time_left)
			eu = expected_utility(next_state, next_action, new_time_left)
			return pw(+,u,eu)
			# return eu
		end
	end
end

# ╔═╡ c10a2ec0-ff46-4193-972c-6ea5a5d4f982
withkernel(Omega.kseα(15)) do
randsample(act1(ω->0, 4))
end

# ╔═╡ c1d88509-a9b7-4870-9a1e-ca66eccd5ba3
𝔼_withkernel(expected_utility(ω->1,action_s,5))

# ╔═╡ c388c6b2-9aa7-4eb6-9d80-1e6efa39659c
withkernel(Omega.kseα(15)) do
	randsample(expected_utility(ω->1,action_s,5))
end

# ╔═╡ bba1b93b-007e-463a-8694-0604a3c1650b
randsample(act1(ω->2, 2))

# ╔═╡ 03e305b4-11ea-4cc5-a486-a9e72030fbc7
withkernel(Omega.kseα(15)) do
viz(randsample(act1(ω->0,3),1000))
end

# ╔═╡ 392cad7c-340d-40ad-ab39-0d862003fc4d
action1 = @~UniformDraw([-1, 0, 1])

# ╔═╡ 76de3859-6b66-40c5-a2c5-5d7070b0db9f
action2 = @~UniformDraw([-1, 0, 1])

# ╔═╡ 35aa050b-c520-4366-a0d4-a51e63a7aec2
action3 = @~UniformDraw([-1, 0, 1])

# ╔═╡ 0224a926-5d89-47de-be51-7fb94e7fe7c2
state_final = pw(+, ω->0, action1, action2, action3)

# ╔═╡ 56a341d6-4071-45be-9997-711e5fcd3f2d
u1 = ω->utility(state_final(ω))

# ╔═╡ f446f101-33d9-4dce-a2ec-0f9535435660
𝔼(u1)

# ╔═╡ b6b5e314-94a7-42ff-9f99-6b8b6063732a
trip1= @~Bernoulli(err(withkernel(Omega.kseα(1)) do
((𝔼(u1)) >=ₛ 0.4)
end))

# ╔═╡ 8b0c0ee2-4c7f-4004-b8d9-19e1fd47bdc1
mean(randsample(trip1,10))

# ╔═╡ 3513d805-65cc-480b-964c-cc2f90117fcb
histogram(randsample(state_final, 1000))

# ╔═╡ dca93ffb-5ea2-43cb-9360-c30bdc8c500d
histogram(randsample(ω->utility(state_final(ω)),100))

# ╔═╡ Cell order:
# ╠═3ddf69be-4c35-4b0b-83a1-924878b0c539
# ╠═1fc71e72-ab61-42b7-a3a6-ccf2ea687029
# ╠═9f00e14b-2ba6-47aa-892f-19d0e5819db1
# ╠═ccda30a3-c569-4756-96e2-3a777fb937e7
# ╠═6035dc7e-f50f-4c70-aade-f756ef53f9a8
# ╠═fb5ce5c3-6741-4903-a9fa-68b9b746c7b6
# ╠═d17a298c-3a5f-4212-99fc-fda8decb1bc7
# ╠═dc47f83f-5d7b-42cf-aca1-c0861005f358
# ╟─49fb02ac-92d1-11ec-3ecc-b77df9024aed
# ╟─8708b9e2-403b-4171-83a9-03a37622734c
# ╟─2c7b594e-f2f0-4327-b002-ab821842123e
# ╠═2107f5c0-1aa7-4586-a2e6-69130d40196c
# ╟─cde27e2b-0b3c-4464-962e-67e996d7747b
# ╟─63379ccd-62f7-4ea5-b19b-54d2c84b04ea
# ╟─bf3d374c-b032-4ee4-8861-6378cd4b7ee9
# ╟─a57f1bcf-41a9-4710-b41c-3754e0246786
# ╟─abf88e93-72ba-49ac-b0d6-d805c9a0c5a3
# ╟─9b8442f4-6e36-4f7f-bba4-ad20a370e146
# ╟─37a65832-80eb-40fe-b581-c8ba2651c370
# ╟─ff8c19d5-b3df-4891-a9ca-4181c12b94ce
# ╠═c22de25e-9006-4ba5-9991-eb3c077dcd35
# ╠═3b9cf8fe-a934-4a35-b460-ea9d360ae5ea
# ╠═85d9e825-b482-40ff-bcbb-24492317292e
# ╠═62c5a031-fa6d-427f-b29c-e517afffa134
# ╠═0ec5835a-02c9-4740-925a-c34c1a04d817
# ╠═089b72f7-f957-45c4-b47d-39457c4b9fcb
# ╠═192f1939-db26-4615-bd89-5ba6a50edfab
# ╠═345d357e-0c38-4f2f-8212-9a6294c20201
# ╠═5b635a24-f6e0-4208-8b99-aa3fdf23a282
# ╠═cc99bbc6-cccf-40e0-b9c0-6de269ca4b8b
# ╠═c10a2ec0-ff46-4193-972c-6ea5a5d4f982
# ╠═c1d88509-a9b7-4870-9a1e-ca66eccd5ba3
# ╠═c388c6b2-9aa7-4eb6-9d80-1e6efa39659c
# ╠═03e305b4-11ea-4cc5-a486-a9e72030fbc7
# ╠═cecf0fe9-5a14-4b14-95a8-2344fde2ba6d
# ╠═7034bd97-370b-4fb2-976a-56bfcc83035c
# ╠═58db6264-e702-41c8-b0df-efb1f8cae6ff
# ╠═16057439-1dee-4c50-9615-bd34e47c462a
# ╠═e90bf9ea-36fa-454b-94b6-856c00578ac7
# ╠═a7e555b4-1e87-4a8b-af20-1e1d7423bd41
# ╠═7f4bbb89-e8c9-48b1-b4d9-369751542852
# ╠═4e93f5a4-dd05-4ef9-97a7-fe5398cfbba1
# ╠═b9d6374c-d6d0-43f1-b91d-05bd6b5e066f
# ╠═178ad31b-2147-44db-a090-3bd2f80125a6
# ╠═4286953b-54dd-4003-a59f-db3eb7a678d4
# ╠═c73ce385-eeb2-45a9-8602-f725ae94556b
# ╠═9ddcba63-7302-4fa2-9000-b195f7478d8a
# ╠═bba1b93b-007e-463a-8694-0604a3c1650b
# ╠═392cad7c-340d-40ad-ab39-0d862003fc4d
# ╠═76de3859-6b66-40c5-a2c5-5d7070b0db9f
# ╠═35aa050b-c520-4366-a0d4-a51e63a7aec2
# ╠═0224a926-5d89-47de-be51-7fb94e7fe7c2
# ╠═56a341d6-4071-45be-9997-711e5fcd3f2d
# ╠═f446f101-33d9-4dce-a2ec-0f9535435660
# ╠═b6b5e314-94a7-42ff-9f99-6b8b6063732a
# ╠═8b0c0ee2-4c7f-4004-b8d9-19e1fd47bdc1
# ╠═3513d805-65cc-480b-964c-cc2f90117fcb
# ╠═dca93ffb-5ea2-43cb-9360-c30bdc8c500d
# ╟─bd65ee7d-f6bb-4b19-93ea-fa15970c3bda
