### A Pluto.jl notebook ###
# v0.17.5

using Markdown
using InteractiveUtils

# ╔═╡ ad4f98b4-4d34-40e6-a546-1013badd310a
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    using Omega, Distributions, UnicodePlots
end

# ╔═╡ 798f9234-39f5-42dc-9fe7-48f7c77cf2d2
md"""
# Prelude: Thinking About Assembly Lines

Imagine a factory where the widget-maker is used to make widgets, but they are sometimes faulty. The tester tests them and lets through only the good ones. You don’t know what tolerance the widget tester is set to, and wish to infer it. We can represent this as:
"""

# ╔═╡ f9c9e3cf-cb7b-4591-94ce-a4aae8679c92
widget_machine_choice = Categorical([.05, .1, .2, .3, .2, .1, .05])

# ╔═╡ 9c0214f4-2c2d-4828-a77b-9b0d144f7bbc
widget_machine(i, ω) = [.2 , .3, .4, .5, .6, .7, .8 ][widget_machine_choice(i, ω)]

# ╔═╡ 4b961d20-f630-4b34-8809-884a4bdf26bc
actual_weights = [.6, .7, .8]

# ╔═╡ 01c5334f-ff4b-4087-96ac-57131e65886b
tolerance = @~ Uniform(0.3, 0.7)

# ╔═╡ dae8d29a-fa2f-4322-8cf1-23acabea44e3
function get_good_widget(i, ω)
	widget = (@uid, i) ~ widget_machine
	widget(ω) > tolerance(ω) ? widget(ω) : get_good_widget(i + 1, ω)
end

# ╔═╡ 68979be3-f3c4-4926-90d4-b095d42ccbb1
actual_widgets = [0.6, 0.7, 0.8]

# ╔═╡ 2c88252c-ba83-423e-a340-c963f8cae334
random_widgets = manynth(get_good_widget, 1:length(actual_widgets))

# ╔═╡ 772edb3b-9d81-4cf1-bc8c-7f8373334a6c
randsample(random_widgets)

# ╔═╡ 7734b963-5cd6-42e6-9c09-fa1f4691109f
tolerance_ = randsample(tolerance |ᶜ (random_widgets ==ₚ actual_widgets), 1000)

# ╔═╡ 7d411137-313e-473a-b9ef-4c82ccb3e2d8
histogram(tolerance_)

# ╔═╡ 38576ae3-8cee-4ba0-9eb4-d81c167c808b
md"But notice that the definition of getGoodWidget is exactly like the definition of rejection sampling! We can re-write this much more simply"

# ╔═╡ b90bf4ab-7a19-439d-bae8-5d6a834f0d9a
get_good_widget_simple = widget_machine |ᶜ widget > tolerance

# ╔═╡ 9ea0aab7-1228-43d5-9a68-47b4d117036c
md"# Social Cognition
How can we capture our intuitive theory of other people? Central to our understanding is the principle of rationality: an agent tends to choose actions that she expects to lead to outcomes that satisfy her goals. (This is a slight restatement of the principle as discussed in Baker et al. (2009), building on earlier work by Dennett (1989), among others.) We can represent this in WebPPL as an inference over actions—an agent reasons about actions that lead to their goal being satisfied:
"

# ╔═╡ 1d1b7607-e0f5-4234-b05b-40daba65bc36
action_prior = @~ Categorical([0.5, 0.5])

# ╔═╡ 96fbba9c-516e-47cc-a3bc-7eefcbfdfc17
function vending_machine(action)
	if action == 1 
		"bagel"
	elseif action == 2
		"cookie"
	end
end

# ╔═╡ db8999c9-6293-4e3c-9a79-6b5c29770261
function choose_action(goal_state, transition)
	action_prior |ᶜ ω -> transition(action_prior(ω)) == goal_state
end

# ╔═╡ 94a623bd-0c48-478c-802a-21288ce6c9a5
randsample(choose_action("cookie", vending_machine))

# ╔═╡ 58ec1fc3-2ac8-4ed3-9028-e09dbc10cfc7
md"""We see, unsurprisingly, that if Sally wants a cookie, she will always press button b. In a world that is not quite so deterministic Sally’s actions will be more stochastic:"""

# ╔═╡ 1fab7ab9-258d-4526-ac80-52b107058fe2
pget(xs) = i -> xs[i]

# ╔═╡ deaa4d92-1863-4963-8a54-25b925240c5e
function vending_machine_stochastic(ω, action)
	choices = ["bagel", "cookie"]
	if action == 1 
		choices[(@~ Categorical([0.9, 0.1]))(ω)]
	elseif action == 2
		choices[(@~ Categorical([0.1, 0.9]))(ω)]
	end
end

# ╔═╡ 64c941d8-900e-41a8-b5ab-3539b45dccfb
function choose_action_stochastic(goal_state, transition)
	action_prior |ᶜ ω -> transition(ω, action_prior(ω)) == goal_state
end

# ╔═╡ 041bd9be-7161-4e2c-8ea1-f1e93c63836e
action_samples = randsample(choose_action_stochastic("cookie", vending_machine_stochastic), 100)

# ╔═╡ 95cc8a2b-3280-4ed0-9d64-488062b09a10
histogram(action_samples)

# ╔═╡ 6f619867-9af2-47d9-9621-759b65593a84
md"## Inferring Goals
Now imagine that we don’t know Sally’s goal (which food she wants), but we observe her pressing button b. We can use Infer to infer her goal (this is sometimes called “inverse planning”, since the outer infer “inverts” the inference inside chooseAction)."

# ╔═╡ 344b85fc-d799-43a0-856c-297679084156
goal = pget(["bagel", "cookie"]) ∘ @~ Categorical([.5, .5])

# ╔═╡ 1f10beb3-9483-4619-83ba-49f743135898
action_dist(ω) = choose_action_stochastic(goal(ω), vending_machine_stochastic)(ω)

# ╔═╡ fcf06a26-35e4-47ac-878b-dae9b34182c8
goal_posterior = goal |ᶜ (action_dist ==ₚ 2)

# ╔═╡ 7d2f1234-84c3-4a63-87b9-f36b492fd3e0
randsample(goal_posterior, 100)

# ╔═╡ 402d913d-8788-4ade-a11e-d0f09853e5f5
md"Now let’s imagine a more ambiguous case: button b is “broken” and will (uniformly) randomly result in a food from the machine. If we see Sally press button b, what goal is she most likely to have?"

# ╔═╡ 0a4ac84e-f51a-41f3-88a2-65cb695b45cf


# ╔═╡ 3130e952-63ed-4236-bca6-f6629c38440c
md"## Inferring preferences

If we have some prior knowledge about Sally’s preferences (which goals she is likely to have) we can incorporate this immediately into the prior over goals (which above was uniform).

A more interesting situation is when we believe that Sally has some preferences, but we don’t know what they are. We capture this by adding a higher level prior (a uniform) over preferences. Using this we can learn about Sally’s preferences from her actions: after seeing Sally press button b several times, what will we expect her to want the next time?
"

# ╔═╡ 3dc36e8c-a494-4022-8c72-fd1b737d0301


# ╔═╡ Cell order:
# ╠═ad4f98b4-4d34-40e6-a546-1013badd310a
# ╟─798f9234-39f5-42dc-9fe7-48f7c77cf2d2
# ╠═f9c9e3cf-cb7b-4591-94ce-a4aae8679c92
# ╠═9c0214f4-2c2d-4828-a77b-9b0d144f7bbc
# ╠═4b961d20-f630-4b34-8809-884a4bdf26bc
# ╠═dae8d29a-fa2f-4322-8cf1-23acabea44e3
# ╠═01c5334f-ff4b-4087-96ac-57131e65886b
# ╠═68979be3-f3c4-4926-90d4-b095d42ccbb1
# ╠═2c88252c-ba83-423e-a340-c963f8cae334
# ╠═772edb3b-9d81-4cf1-bc8c-7f8373334a6c
# ╠═7734b963-5cd6-42e6-9c09-fa1f4691109f
# ╠═7d411137-313e-473a-b9ef-4c82ccb3e2d8
# ╟─38576ae3-8cee-4ba0-9eb4-d81c167c808b
# ╠═b90bf4ab-7a19-439d-bae8-5d6a834f0d9a
# ╟─9ea0aab7-1228-43d5-9a68-47b4d117036c
# ╠═1d1b7607-e0f5-4234-b05b-40daba65bc36
# ╠═96fbba9c-516e-47cc-a3bc-7eefcbfdfc17
# ╠═db8999c9-6293-4e3c-9a79-6b5c29770261
# ╠═94a623bd-0c48-478c-802a-21288ce6c9a5
# ╠═58ec1fc3-2ac8-4ed3-9028-e09dbc10cfc7
# ╠═1fab7ab9-258d-4526-ac80-52b107058fe2
# ╠═deaa4d92-1863-4963-8a54-25b925240c5e
# ╠═64c941d8-900e-41a8-b5ab-3539b45dccfb
# ╠═041bd9be-7161-4e2c-8ea1-f1e93c63836e
# ╠═95cc8a2b-3280-4ed0-9d64-488062b09a10
# ╟─6f619867-9af2-47d9-9621-759b65593a84
# ╠═344b85fc-d799-43a0-856c-297679084156
# ╠═1f10beb3-9483-4619-83ba-49f743135898
# ╠═fcf06a26-35e4-47ac-878b-dae9b34182c8
# ╠═7d2f1234-84c3-4a63-87b9-f36b492fd3e0
# ╠═402d913d-8788-4ade-a11e-d0f09853e5f5
# ╠═0a4ac84e-f51a-41f3-88a2-65cb695b45cf
# ╟─3130e952-63ed-4236-bca6-f6629c38440c
# ╠═3dc36e8c-a494-4022-8c72-fd1b737d0301
