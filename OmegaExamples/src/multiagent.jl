### A Pluto.jl notebook ###
# v0.17.6

using Markdown
using InteractiveUtils

# ╔═╡ a06353a2-ecd0-11ec-1183-ed579281838e
using Pkg

# ╔═╡ 786ddf31-382c-4071-bdba-3de4e11b57ef
Pkg.activate(Base.current_project())

# ╔═╡ 7e8eb2d6-2dd2-440c-a7a3-49041637d37b
using Omega

# ╔═╡ 7a8527c0-667f-41d6-a500-4434c0ca462a
using Memoize

# ╔═╡ facc9d94-0fca-4caa-bc16-25ffbddbee89
using FreqTables

# ╔═╡ 383acc14-52f4-414d-a0ba-3568b9c60528
using Distributions

# ╔═╡ cb7f79fa-0236-4bf8-9d20-8e15ad89da15
using UnicodePlots

# ╔═╡ 20493890-2a70-4789-940e-fe78117ad8c8
using Random

# ╔═╡ 13439f0f-a070-4881-a7d9-94cd6132ab75
using Plots

# ╔═╡ c8af5d5e-8cf6-4173-b8c8-5f0071d805c0
Pkg.instantiate()

# ╔═╡ ef76bf36-b309-4ef5-910f-7b0767090c78
flip = @~ Bernoulli(.55)

# ╔═╡ 0318a23f-5081-4c79-b210-7df7ea6d2b92
flip1 = @~ Bernoulli(.55)

# ╔═╡ 52ddd073-2473-4718-9e03-4c7575399401
flip2 = @~ Bernoulli(.55)

# ╔═╡ 6035bbc3-0ca9-48d4-9c91-0dcd3430e290
location_prior() = ω -> (flip(ω) ? "popular-bar" : "unpopular-bar")

# ╔═╡ 512d75c4-3d79-4db7-aa29-611ca2334f99
md" ## Multi-agent models
In this chapter, we will look at models that involve multiple agents reasoning about each other. This chapter is based on Stuhlmüller and Goodman (2013).

### Schelling coordination games
We start with a simple Schelling coordination game. Alice and Bob are trying to meet up but have lost their phones and have no way to contact each other. There are two local bars: the popular bar and the unpopular one.

Let’s first consider how Alice would choose a bar (if she was not taking Bob into account):

"

# ╔═╡ 7034c86c-3e2d-472a-8a86-8f652d8a17a5
function location_prior1(x)
	flip = x~ Bernoulli(.55)
	ω -> (flip(ω) ? "popular-bar" : "unpopular-bar")
end

# ╔═╡ 53477fc9-3050-43b6-8fe1-18bbd1d833d2
alice = location_prior1(1)

# ╔═╡ df9eae9c-1d14-4fad-bea4-4f146d865795
md"But Alice wants to be at the same bar as Bob. We extend our model of Alice to include this:"

# ╔═╡ b520f136-dfc4-4303-944b-113708304457
bob = location_prior1(2)

# ╔═╡ f819c9c1-8395-4363-8d5f-0563e7b3232e
function alice_accounting_for_bob()
	my_location = location_prior1(3)
	bob_location = bob
	my_location |ᶜ pw(==, my_location, bob_location)
end

# ╔═╡ 7e2b6bf3-d2c7-4750-b712-d4edc0d21811
md"Now Bob and Alice are thinking recursively about each other. We add caching (to avoid repeated computations) and a depth parameter (to avoid infinite recursion):"

# ╔═╡ 30b3f2fc-e250-4869-97e9-546d96fd66bd
begin
	function alice_bob(depth)
		@show "alice-bob"
		@show depth
		my_location = location_prior1(depth)
		bob_location = bob_alice(depth-1)
		condition = ω -> (my_location(ω) == bob_location(ω))
		my_location |ᶜ condition
	end
	
	function bob_alice(depth)
		@show "bob-alice"
		my_location = location_prior1(depth+110)
		if (depth == 0)
			my_location
		else
			alice_location = alice_bob(depth)
			condition = ω -> (my_location(ω) == alice_location(ω))
			my_location |ᶜ condition
		end
	end
end

# ╔═╡ 59a3ff81-b480-462f-b75c-32bde79a499e
md"Exercise: Change the example to the setting where Bob wants to avoid Alice instead of trying to meet up with her, and Alice knows this. How do the predictions change as the reasoning depth grows? How would you model the setting where Alice doesn’t know that Bob wants to avoid her?

Exercise: Would any of the answers to the previous exercise change if recursive reasoning could terminate not just at a fixed depth, but also at random?"

# ╔═╡ 9514f4f8-b7a9-44c0-ae28-022266eec640
md"## Game playing
We’ll look at the two-player game tic-tac-toe:"

# ╔═╡ 245ab7a5-6b0e-4ca8-ba8e-c90d9b85c1a8
md"Let’s start with a prior on moves:"

# ╔═╡ 76f7738a-0d03-4e5a-87cf-235fd02bdc1a
function is_valid_move(state, x, y)
	state[x][y] == '?'
end

# ╔═╡ 7ee49143-4e29-4dd6-8600-152f6df93788
start_state = [
	['?', 'o', '?'],
  	['?', 'x', 'x'],
  	['?', '?', '?']
]

# ╔═╡ db2866c0-6785-4a69-90e9-ac3c604ad461
md"Now let’s add a deterministic transition function:"

# ╔═╡ 08e7fc23-1055-46ef-b99c-551459c86de2
function transition(state, move, player)
	new_grid = deepcopy(state)
	new_grid[move[1]][move[2]] = player
	new_grid
end

# ╔═╡ bb9c6649-1625-4ba2-a704-04bcdface009
transition(start_state, (2,1), 'o')

# ╔═╡ 01bc793c-05b0-4fe4-ab3f-51c7e1e003f5
md"We need to be able to check if a player has won:"

# ╔═╡ 218e6f4a-01e2-4466-b876-b9f681b350fc
function diag1(state)
	[state[1][1], state[2][2], state[3][3]]
end

# ╔═╡ 3aab402a-4a2d-44c3-93c4-3ceecff9b839
function diag2(state)
	[state[1][3], state[2][2], state[3][1]]
end

# ╔═╡ ca616565-e01e-4fc5-8e3c-75b44fba9c2e
function cols(state, x)
	[state[1][x], state[2][x], state[3][x]]
end

# ╔═╡ 27537de5-f689-40f6-9f29-c76243773643
@memoize function has_won(state, player)
	function check(xs)
		xs[1] == xs[2] == xs[3] == player
	end
	any([check(i) for i in [state[1], state[2], state[3], cols(state, 1), cols(state, 2), cols(state, 3), diag1(state), diag2(state)]])
end

# ╔═╡ 9787be3d-6540-467f-944e-89875aa309dd
startState = [
  ['?', 'o', '?'],
  ['x', 'x', 'x'],
  ['?', '?', '?']
]

# ╔═╡ 7732e191-cc3f-4142-b99c-4416eae0f3c4
has_won(startState, 'x')

# ╔═╡ a6da19e4-d8db-44de-844b-73762a9ea5dc
md"Now let’s implement an agent that chooses a single action, but can’t plan ahead:"

# ╔═╡ 874d43bd-e166-4651-afeb-de051030432b
function is_draw(state)
	!has_won(state, 'x') && !has_won(state, 'o')
end

# ╔═╡ 9c5a783d-3126-4164-85c8-8fa1d2f78b06
function utility(state, player)
	if has_won(state, player)
		10
	elseif is_draw(state)
		0
	else
		-10
	end
end

# ╔═╡ 3409383d-423d-41bd-9d43-5a25fddec422
startState2 = [
  ['o', '?', '?'],
  ['?', 'x', 'x'],
  ['?', '?', '?']
]

# ╔═╡ 4cda378a-c6d5-4495-9602-e1c89a1e4c10
@memoize function 𝔼(x)
	Random.seed!(0)
	@show "Calculating Expectations"
	mean(randsample(x,1000))
end

# ╔═╡ d2840b72-96a7-4fa7-97e3-5c514bd29efd
literal_meanings = Dict(
	"all_sprouted" => function(state) state == 3 end,
	"some_sprouted" => function(state) state > 0 end,
	"none_sprouted" => function(state) state == 0 end
)

# ╔═╡ d304112f-7f7f-479b-846a-869e535208f6
alpha = 2

# ╔═╡ e427b78b-d3bc-471f-81d9-86a50e5401c7
function listener(sentence)
	state = state_prior()
	soft_cond = @~Bernoulli(pw(err,pw(==ₛ,pw(/,ω -> speaker(state(ω))(ω),3),1)))

# ╔═╡ 0fce9968-e8b8-433c-81fb-659bf8d5f74f
indexing_dict = Dict(["all_sprouted" => 1, "some_sprouted" , "none_sprouted"])

# ╔═╡ 60bb62ec-f13b-4518-b09e-6f3653f9792d
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

# ╔═╡ 643ef712-f478-417d-808d-3868711afd9e
viz(randsample(alice,1000))

# ╔═╡ dc0b15bd-f957-414d-8d4f-6eb7a3b4d512
viz(randsample(alice_accounting_for_bob(), 1000))

# ╔═╡ 3b6e054c-f551-400f-a9bc-4a620c83039c
viz(randsample(alice_bob(10),100))

# ╔═╡ cd74b95b-7b60-4bbf-8eae-ee6962065a57
function move_prior(state)
	x = @~ UniformDraw([1, 2, 3])
	y = @~ UniformDraw([1, 2, 3])
	condition = ω -> is_valid_move(state, x(ω), y(ω))
	x_cond = x |ᶜ condition
	y_cond = y |ᶜ condition
	ω -> (x_cond(ω), y_cond(ω))
end

# ╔═╡ a1888e7a-28d9-4a9b-a9ca-869149044963
@memoize function act(state, player)
	move =  ω -> move_prior(state(ω))
	outcome = ω -> transition(state, move(ω), player)
	util = ω -> utility(outcome(ω), player)
	eu = 𝔼(util)
	eu_rid = rid(eu, move)
	cond = pw(>=, eu, 3.0)
	move |ᶜ cond
end

# ╔═╡ d29f8950-4462-482e-b40c-a536996e8a0c
randsample(act(startState2, 'x'))

# ╔═╡ 8f856d65-4c5f-4c3f-8b54-985543226752
move_states =  ω -> move_prior((ω -> startState2)(ω)) #a distribution of moves over states

# ╔═╡ 8136de3d-347d-47e7-9a84-4593051ce41e
outcome = ω -> pw(transition, (ω -> startState2), move_states(ω), 'x')

# ╔═╡ d826e3c0-98c7-48cb-a32b-05bacff806af
randsample(outcome)

# ╔═╡ 8bc9c775-7b0d-4af1-8e7f-9076ed03bbf1
util = ω -> pw(utility, outcome(ω), 'x')

# ╔═╡ 0dc15cee-c2ef-4eb9-9f2c-a551bc56decd
randsample(randsample(util))

# ╔═╡ 60e7516d-9b59-4114-a368-fa12eb178fe4
util_rid = rid(util, move)

# ╔═╡ 78e23d5c-6a38-4adb-82e9-aed072fab833
x = randsample(util_rid)

# ╔═╡ 53ca278c-8219-469b-938a-e7bf14b0afb2
eu_rid = ω->𝔼(util_rid(ω))

# ╔═╡ 76997273-aaae-46a5-ad59-bad85b25444a
randsample(eu_rid,11)

# ╔═╡ ccd30d53-881e-4928-81e7-6555215ce656
randsample(util,10
)

# ╔═╡ 06e970a0-e138-4bf1-b543-4751196b1f51
outcome_rid = ω->rid(outcome, move)

# ╔═╡ c3201bb6-ebd0-4c3f-931c-168767da151a
g = randsample(outcome_rid)

# ╔═╡ 57079ddc-c483-4026-839b-9c1dd920bbe1
randsample(g)

# ╔═╡ 49e5f2ba-a6a3-40df-9f30-2eaae51e910a
randsample(outcome)

# ╔═╡ 485c23ac-a8ca-4f86-8a6d-96feaf102ca2
d = randsample(outcome)

# ╔═╡ 5985f721-11a7-459a-a269-fba057c83d6b
function state_prior()
	@~ UniformDraw([0,1,2,3])
end

# ╔═╡ 1fa79b6a-51ee-485c-8601-42f85bfca6c7
function literal_listener(sentence)
	state = state_prior()
	meaning = literal_meanings[sentence]
	condition = ω -> meaning(state(ω))
	state |ᶜ condition
end

# ╔═╡ c25d0717-8c45-4524-984f-828356ea60c4
state = state_prior()

# ╔═╡ ea83dd60-d7b9-41a9-b98d-f9338fc62038
function sentence_prior()
	@~ UniformDraw(["all_sprouted", "some_sprouted", "none_sprouted"])
end

# ╔═╡ 1ba3bf5c-e4cf-44ca-9234-a10adf0d9a87
sentence = sentence_prior()

# ╔═╡ 8a4aa5ab-8ff1-44ef-95f9-6dcff92c91c7
pw(pw(/,ω -> literal_listener(sentence(ω))(ω),3))

# ╔═╡ 6228c594-cc90-40c0-ac6b-b432855d1d8a
a = pw(err,pw(==ₛ,pw(/,ω -> literal_listener(sentence(ω))(ω),3),1))

# ╔═╡ ae4c0055-a46b-4949-a162-031e1c409df9
randsample(@~Bernoulli(a))

# ╔═╡ fc720d3b-ed22-4a03-8578-cc049e976697
randsample(@~Bernoulli(a))

# ╔═╡ 9709fc6f-a832-44ad-a8c2-8f6a4bc2ff59
function speaker(state)
	sentence = sentence_prior()
	soft_cond = @~Bernoulli(pw(err,pw(==ₛ,pw(/,ω -> literal_listener(sentence(ω))(ω),state),1)))
	sentence |ᶜ soft_cond
end
	

# ╔═╡ 2c31e133-ad2f-4767-a08c-534ad4c8a9c4
e = pw(err,pw(==ₛ,pw(/,ω -> speaker(state(ω))(ω),3),1))

# ╔═╡ 5a868ac9-f56b-4f60-ad9a-fb5be1901aaa
randsample(e)

# ╔═╡ f3abfd1f-8bb1-4da0-8ca0-aa751bd79bc3
randsample(speaker(2))

# ╔═╡ 8f6a172f-ee2c-4323-a8b5-d374e676a610
viz([string(i) for i in randsample(literal_listener("some_sprouted"),1000)])

# ╔═╡ 95d8d939-8873-4af2-bb77-c83e5ab4d143
withkernel(Omega.kseα()) do
viz(randsample(speaker(3),100))
end

# ╔═╡ Cell order:
# ╠═a06353a2-ecd0-11ec-1183-ed579281838e
# ╠═786ddf31-382c-4071-bdba-3de4e11b57ef
# ╠═c8af5d5e-8cf6-4173-b8c8-5f0071d805c0
# ╠═7e8eb2d6-2dd2-440c-a7a3-49041637d37b
# ╠═7a8527c0-667f-41d6-a500-4434c0ca462a
# ╠═facc9d94-0fca-4caa-bc16-25ffbddbee89
# ╠═383acc14-52f4-414d-a0ba-3568b9c60528
# ╠═cb7f79fa-0236-4bf8-9d20-8e15ad89da15
# ╠═20493890-2a70-4789-940e-fe78117ad8c8
# ╠═13439f0f-a070-4881-a7d9-94cd6132ab75
# ╠═ef76bf36-b309-4ef5-910f-7b0767090c78
# ╠═0318a23f-5081-4c79-b210-7df7ea6d2b92
# ╠═52ddd073-2473-4718-9e03-4c7575399401
# ╠═6035bbc3-0ca9-48d4-9c91-0dcd3430e290
# ╟─512d75c4-3d79-4db7-aa29-611ca2334f99
# ╠═7034c86c-3e2d-472a-8a86-8f652d8a17a5
# ╠═53477fc9-3050-43b6-8fe1-18bbd1d833d2
# ╠═643ef712-f478-417d-808d-3868711afd9e
# ╟─df9eae9c-1d14-4fad-bea4-4f146d865795
# ╠═b520f136-dfc4-4303-944b-113708304457
# ╠═f819c9c1-8395-4363-8d5f-0563e7b3232e
# ╠═dc0b15bd-f957-414d-8d4f-6eb7a3b4d512
# ╟─7e2b6bf3-d2c7-4750-b712-d4edc0d21811
# ╠═30b3f2fc-e250-4869-97e9-546d96fd66bd
# ╠═3b6e054c-f551-400f-a9bc-4a620c83039c
# ╟─59a3ff81-b480-462f-b75c-32bde79a499e
# ╟─9514f4f8-b7a9-44c0-ae28-022266eec640
# ╟─245ab7a5-6b0e-4ca8-ba8e-c90d9b85c1a8
# ╠═76f7738a-0d03-4e5a-87cf-235fd02bdc1a
# ╠═cd74b95b-7b60-4bbf-8eae-ee6962065a57
# ╠═7ee49143-4e29-4dd6-8600-152f6df93788
# ╟─db2866c0-6785-4a69-90e9-ac3c604ad461
# ╠═08e7fc23-1055-46ef-b99c-551459c86de2
# ╠═bb9c6649-1625-4ba2-a704-04bcdface009
# ╟─01bc793c-05b0-4fe4-ab3f-51c7e1e003f5
# ╠═218e6f4a-01e2-4466-b876-b9f681b350fc
# ╠═3aab402a-4a2d-44c3-93c4-3ceecff9b839
# ╠═ca616565-e01e-4fc5-8e3c-75b44fba9c2e
# ╠═27537de5-f689-40f6-9f29-c76243773643
# ╠═9787be3d-6540-467f-944e-89875aa309dd
# ╠═7732e191-cc3f-4142-b99c-4416eae0f3c4
# ╟─a6da19e4-d8db-44de-844b-73762a9ea5dc
# ╠═874d43bd-e166-4651-afeb-de051030432b
# ╠═9c5a783d-3126-4164-85c8-8fa1d2f78b06
# ╠═a1888e7a-28d9-4a9b-a9ca-869149044963
# ╠═3409383d-423d-41bd-9d43-5a25fddec422
# ╠═d29f8950-4462-482e-b40c-a536996e8a0c
# ╠═8f856d65-4c5f-4c3f-8b54-985543226752
# ╠═8136de3d-347d-47e7-9a84-4593051ce41e
# ╠═d826e3c0-98c7-48cb-a32b-05bacff806af
# ╠═8bc9c775-7b0d-4af1-8e7f-9076ed03bbf1
# ╠═0dc15cee-c2ef-4eb9-9f2c-a551bc56decd
# ╠═06e970a0-e138-4bf1-b543-4751196b1f51
# ╠═c3201bb6-ebd0-4c3f-931c-168767da151a
# ╠═57079ddc-c483-4026-839b-9c1dd920bbe1
# ╠═49e5f2ba-a6a3-40df-9f30-2eaae51e910a
# ╠═60e7516d-9b59-4114-a368-fa12eb178fe4
# ╠═ccd30d53-881e-4928-81e7-6555215ce656
# ╠═78e23d5c-6a38-4adb-82e9-aed072fab833
# ╠═485c23ac-a8ca-4f86-8a6d-96feaf102ca2
# ╠═53ca278c-8219-469b-938a-e7bf14b0afb2
# ╠═76997273-aaae-46a5-ad59-bad85b25444a
# ╠═4cda378a-c6d5-4495-9602-e1c89a1e4c10
# ╠═5985f721-11a7-459a-a269-fba057c83d6b
# ╠═d2840b72-96a7-4fa7-97e3-5c514bd29efd
# ╠═ea83dd60-d7b9-41a9-b98d-f9338fc62038
# ╠═1fa79b6a-51ee-485c-8601-42f85bfca6c7
# ╠═8f6a172f-ee2c-4323-a8b5-d374e676a610
# ╠═d304112f-7f7f-479b-846a-869e535208f6
# ╠═1ba3bf5c-e4cf-44ca-9234-a10adf0d9a87
# ╠═8a4aa5ab-8ff1-44ef-95f9-6dcff92c91c7
# ╠═6228c594-cc90-40c0-ac6b-b432855d1d8a
# ╠═ae4c0055-a46b-4949-a162-031e1c409df9
# ╠═fc720d3b-ed22-4a03-8578-cc049e976697
# ╠═9709fc6f-a832-44ad-a8c2-8f6a4bc2ff59
# ╠═95d8d939-8873-4af2-bb77-c83e5ab4d143
# ╠═e427b78b-d3bc-471f-81d9-86a50e5401c7
# ╠═c25d0717-8c45-4524-984f-828356ea60c4
# ╠═2c31e133-ad2f-4767-a08c-534ad4c8a9c4
# ╠═f3abfd1f-8bb1-4da0-8ca0-aa751bd79bc3
# ╠═0fce9968-e8b8-433c-81fb-659bf8d5f74f
# ╠═5a868ac9-f56b-4f60-ad9a-fb5be1901aaa
# ╟─60bb62ec-f13b-4518-b09e-6f3653f9792d
