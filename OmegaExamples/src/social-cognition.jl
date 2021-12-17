### A Pluto.jl notebook ###
# v0.17.1

using Markdown
using InteractiveUtils

# ╔═╡ ad4f98b4-4d34-40e6-a546-1013badd310a
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    using Omega, Distributions, UnicodePlots, FreqTables
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

# ╔═╡ b1d5fd2a-f049-4664-9773-c74247028b86
widget = @~ widget_machine

# ╔═╡ b90bf4ab-7a19-439d-bae8-5d6a834f0d9a
get_good_widget_simple = (ω -> widget_machine(@uid, ω)) |ᶜ (widget >ₚ tolerance)

# ╔═╡ 92076a20-a0c1-4cde-acf4-c3d4d9bd7568
md"`randsample` uses rejection sampling by default, but we could also explicitly specify it by using `alg` keyword as given below:"

# ╔═╡ 9de65884-f298-44ca-bfc2-88929cb42f2d
histogram(randsample(get_good_widget_simple, 1000, alg = RejectionSample), bins = 7) 

# ╔═╡ 9ea0aab7-1228-43d5-9a68-47b4d117036c
md"# Social Cognition
How can we capture our intuitive theory of other people? Central to our understanding is the principle of rationality: an agent tends to choose actions that she expects to lead to outcomes that satisfy her goals. (This is a slight restatement of the principle as discussed in [Baker et al. (2009)](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.154.2977&rep=rep1&type=pdf), building on earlier work by [Dennett (1989)](https://scholar.google.com/scholar?q=%22The%20Intentional%20Stance%22), among others.) We can represent this in Omega as an inference over actions—an agent reasons about actions that lead to their goal being satisfied.
"

# ╔═╡ 87cd2805-8995-4b9e-8041-e91b70eb4fbe
md"""
For instance, imagine that Sally walks up to a vending machine wishing to have a cookie. Imagine also that we know the mapping between buttons (potential actions) and foods (outcomes). We can then predict Sally’s action:
"""

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
md"""We see, unsurprisingly, that if Sally wants a cookie, she will always press button $2$. In a world that is not quite so deterministic Sally’s actions will be more stochastic:"""

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
histogram(action_samples, bins = 2)

# ╔═╡ 6f619867-9af2-47d9-9621-759b65593a84
md"## Inferring Goals
Now imagine that we don’t know Sally’s goal (which food she wants), but we observe her pressing button $2$. We can infer her goal (this is sometimes called “inverse planning”):"

# ╔═╡ 344b85fc-d799-43a0-856c-297679084156
goal = pget(["bagel", "cookie"]) ∘ @~ Categorical([.5, .5])

# ╔═╡ 1f10beb3-9483-4619-83ba-49f743135898
action_dist(ω) = choose_action_stochastic(goal(ω), vending_machine_stochastic)(ω)

# ╔═╡ fcf06a26-35e4-47ac-878b-dae9b34182c8
goal_posterior = goal |ᶜ (action_dist ==ₚ 2)

# ╔═╡ 7d2f1234-84c3-4a63-87b9-f36b492fd3e0
goal_post_samples = randsample(goal_posterior, 1000)

# ╔═╡ 5e752da6-f784-4af1-b51a-9a13f64eff50
barplot(Dict(freqtable(goal_post_samples)))

# ╔═╡ 402d913d-8788-4ade-a11e-d0f09853e5f5
md"Now let’s imagine a more ambiguous case: button b is “broken” and will (uniformly) randomly result in a food from the machine. If we see Sally press button $2$, what goal is she most likely to have?"

# ╔═╡ 0a4ac84e-f51a-41f3-88a2-65cb695b45cf
function vending_machine_broken(ω, action)
	choices = ["bagel", "cookie"]
	if action == 1 
		choices[(@~ Categorical([0.9, 0.1]))(ω)]
	elseif action == 2
		choices[(@~ Categorical([0.5, 0.5]))(ω)]
	end
end

# ╔═╡ 47672c99-dc1a-4674-b008-5c1007f8de80
action_dist_broken(ω) = 
	choose_action_stochastic(goal(ω), vending_machine_broken)(ω)

# ╔═╡ 01c7ff1f-2d5d-4334-ad16-7fb74a29391c
goal_posterior_broken = goal |ᶜ (action_dist_broken ==ₚ 2)

# ╔═╡ a9f49983-d018-444e-a683-e32733821213
goal_post_broken_samples = randsample(goal_posterior_broken, 1000)

# ╔═╡ 567147c8-6815-48c9-a72e-076b101555e5
barplot(Dict(freqtable(goal_post_broken_samples))) # Isn't right : should get 3:7, now it is 1:1

# ╔═╡ c33a7649-1a0e-44ac-9b32-3afdb4abf564
md"""
Despite the fact that button $2$ is equally likely to result in either bagel or cookie, we have inferred that Sally probably wants a cookie. This is a result of the inference implicitly taking into account the counterfactual alternatives: if Sally had wanted a bagel, she would have likely pressed button $1$. The inner query takes these alternatives into account, adjusting the probability of the observed action based on alternative goals.
"""

# ╔═╡ 3130e952-63ed-4236-bca6-f6629c38440c
md"## Inferring preferences

If we have some prior knowledge about Sally’s preferences (which goals she is likely to have) we can incorporate this immediately into the prior over goals (which above was uniform).

A more interesting situation is when we believe that Sally has some preferences, but we don’t know what they are. We capture this by adding a higher level prior (a uniform) over preferences. Using this we can learn about Sally’s preferences from her actions: after seeing Sally press button $2$ several times, what will we expect her to want the next time?
"

# ╔═╡ 3dc36e8c-a494-4022-8c72-fd1b737d0301
preference = @~ Uniform(0 , 1)

# ╔═╡ e555e6fb-7f99-410d-b440-012819afa731
goal_prior(ω) = (@~ Bernoulli(preference))(ω) ? "bagel" : "cookie"

# ╔═╡ 00ec2e96-85ae-410f-b3d1-efb4253da2aa
action_dist_(ω) = choose_action_stochastic(goal_prior(ω), vending_machine_stochastic)

# ╔═╡ 003c79ab-1611-4a3e-963b-69215d886a2d
action_multi(ω) = (&)(repeat([(action_dist_(defω()) == 2)], 3)...)

# ╔═╡ 97c6c489-186e-49d1-b538-6b273ae242e2
goal_post = goal_prior |ᶜ action_multi

# ╔═╡ ee6cef1f-f00e-4dba-9689-9d81240f5b84
# randsample(goal_post)

# ╔═╡ 4cf196fe-e24e-4f7c-8b96-3ebdd4b30cca
md"""
Try varying the amount and kind of evidence. For instance, if Sally one time says “I want a cookie” (so you have directly observed her goal that time) how much evidence does that give you about her preferences, relative to observing her actions?

In the above preference inference, it is extremely important that sally _could have_ taken a different action if she had a different preference (i.e. she could have pressed button $1$ if she preferred to have a bagel). In the program below we have set up a situation in which both actions lead to cookie most of the time:
"""

# ╔═╡ b56af991-6176-4a79-9c98-1d4cdc2e0f93
function vending_machine_cookie(ω, action)
	choices = ["bagel", "cookie"]
	if action == 1 
		choices[(@~ Categorical([0.1, 0.9]))(ω)]
	elseif action == 2
		choices[(@~ Categorical([0.1, 0.9]))(ω)]
	end
end

# ╔═╡ 54f8f9d7-6eaf-4398-a58f-26460f138d77
action_dist_cookie(ω) = 
	choose_action_stochastic(goal_prior(ω), vending_machine_cookie)

# ╔═╡ ef2ce2f6-e013-4a45-8971-8ceb25464b69
action_cookie_multi(ω) = (&)(repeat([(action_dist_cookie(defω()) == 2)], 3)...)

# ╔═╡ de4fc02c-c665-4297-b226-a9822505ea27
goal_post_cookie = goal_prior |ᶜ action_cookie_multi

# ╔═╡ aa9fc886-f3ca-4ba4-820c-2df951431ee8
# randsample(goal_post_cookie)

# ╔═╡ bdae86a5-ffa0-4a40-a9d9-cc74e7b2685b
md"""
Now we can draw no conclusion about Sally’s preferences. Try varying the machine probabilities, how does the preference inference change? This effect, that the strength of a preference inference depends on the context of alternative actions, has been demonstrated in young infants by [Kushnir et al. (2010)](https://scholar.google.com/scholar?q=%22Young%20Children%20Use%20Statistical%20Sampling%20to%20Infer%20the%20Preferences%20of%20Other%20People%22).
"""

# ╔═╡ 6c8df318-e265-4c79-a1a4-3b22c3c2156f
md"## Inferring what they know"

# ╔═╡ 06b51715-3aa3-4c4a-b12e-c8ad37ede492
md"""
In the above models of goal and preference inference, we have assumed that the structure of the world (the operation of the vending machine) was common knowledge—they were non-random constructs used by both the agent (Sally) selecting actions and the observer interpreting these actions. What if we (the observer) don’t know how exactly the vending machine works, but think that Sally knows how it works? We can capture this by placing uncertainty on the vending machine inside the overall query but “outside” of Sally’s inference:
"""

# ╔═╡ 0eae2e2f-bc8d-4f72-82d8-2923377ee2d5
buttons_to_bagel_probs(n, ω) = ((@uid, n) ~ Uniform(0, 1))(ω)

# ╔═╡ b3ebce3f-172b-45e6-b3b9-e598582b4799
function vending_machine_know(ω, action)
	choices = ["bagel", "cookie"]
	if action == 1 
		c = buttons_to_bagel_probs(1, ω)
		choices[(@~ Categorical([c, 1 - c]))(ω)]
	elseif action == 2
		c = buttons_to_bagel_probs(2, ω)
		choices[(@~ Categorical([c, 1 - c]))(ω)]
	end
end

# ╔═╡ b3f646ed-1080-4e11-896d-8584773ed569
action(ω) = choose_action_stochastic(goal(ω), vending_machine_know)

# ╔═╡ 104c3b09-00d2-444f-a54d-bfef3b23bb79
buttons(ω) = 
	(button_1 = vending_machine_know(ω, 1), button_2 = vending_machine_know(ω, 2))

# ╔═╡ b76ca232-b2b7-4914-a29e-49a2c876e99e
# randsample(buttons |ᶜ ((goal ==ₚ "cookie") &ₚ (action ==ₚ 2)) )

# ╔═╡ 401b598e-9b5d-4fef-a8a4-490eff488d65
md"""
# Emotion and other mental states
So far we have explored reasoning about others’ goals, preferences, knowledge, and beliefs. It is commonplace to discuss other’s actions in terms of many other mental states as well! We might explain an unexpected slip in terms of wandering attention, a short-sighted choice in terms of temptation, a violent reaction in terms of anger, a purposeless embellishment in terms of joy. Each of these has a potential role to play in an elaborated scientific theory of how humans represent other’s minds.

## Communication and Language
### A Communication Game
Imagine playing the following two-player game. On each round the “teacher” pulls a die from a bag of weighted dice, and has to communicate to the “learner” which die it is (both players are familiar with the dice and their weights). However, the teacher may only communicate by giving the learner examples: showing them faces of the die.

We can formalize the inference of the teacher in choosing the examples to give by assuming that the goal of the teacher is to successfully teach the hypothesis – that is, to choose examples such that the learner will infer the intended hypothesis:
"""

# ╔═╡ 7d39b41a-7f55-4b68-acf4-771e9d927a21
md"To make this concrete, assume that there are two dice, A and B, which each have three sides (red, green, blue) that have weights. Which hypothesis will the learner infer if the teacher shows the green side?"

# ╔═╡ 0b5adcf4-62ba-46d0-b2eb-72ea316505b7
begin
	function die_to_probs(die::Int64)
		if die == 1
			return @~ Categorical([0., 0.2, 0.8])
		elseif die == 2
			return @~ Categorical([0.1, 0.3, 0.6])
		end
	end
end

# ╔═╡ 6a76e0cd-7398-4b1b-9b63-0346b689833e
side_prior = pget(["red", "green", "blue"]) ∘ @~ Categorical([1/3, 1/3, 1/3])

# ╔═╡ 4db9de3c-c181-4625-80f7-869e7dc9d2f4
die_prior = @~ Categorical([0.5, 0.5])

# ╔═╡ fbef5c02-1cd0-4cb3-b6d6-aae639d11585
roll(die, ω) = (pget(["red", "green", "blue"]) ∘ die_to_probs(die))(ω)

# ╔═╡ f6700537-858a-421a-87a3-d5f76287f9ed
begin
	function teacher(die, depth)
		return side_prior |ᶜ ((ω -> learner(side_prior(ω), depth)(ω)) ==ₚ die)
	end
	function learner(side, depth)
		if (depth == 0)
			return die_prior |ᶜ ((ω -> roll(die_prior(ω), ω)) ==ₚ side)
		else
			return die_prior |ᶜ ((ω -> teacher(die_prior(ω), depth - 1)(ω)) ==ₚ side)
		end
	end
end

# ╔═╡ a662c3a1-70d6-4305-84d3-a34c77bd5fb8
histogram(randsample(learner("green", 3), 1000), bins = 1)

# ╔═╡ 1190f5c8-371e-41e8-be6c-4d3aea30805b
md"""
If we run this with recursion depth 0—that is a learner that does probabilistic inference without thinking about the teacher thinking—we find the learner infers hypothesis $2$ most of the time (about $60\%$ of the time). This is the same as using the “strong sampling” assumption: the learner infers $2$ because $2$ is more likely to have landed on side 2. However, if we increase the recursion depth we find this reverses: the learner infers $2$ only about $40\%$ of the time. Now die $1$ becomes the better inference, because “if the teacher had meant to communicate $2$, they would have shown the red side because that can never come from $1$.”

This model, has been proposed by [Shafto et al. (2012)](https://langcog.stanford.edu/papers/SGF-perspectives2012.pdf) as a model of natural pedagogy. They describe several experimental tests of this model in the setting of simple “teaching games,” showing that people make inferences as above when they think the examples come from a helpful teacher, but not otherwise.

### Communicating with Words
Unlike the situation above, in which concrete examples were given from teacher to student, words in natural language denote more abstract concepts. However, we can use almost the same setup to reason about speakers and listeners communicating with words, if we assume that sentences have literal meanings, which anchor sentences to possible worlds. We assume for simplicity that the meaning of sentences are truth-functional: that each sentence corresponds to a function from states of the world to true/false.
"""

# ╔═╡ 19592b62-f93b-4422-a2de-9bb9fe5c2144
md"#### Example: Scalar Implicature"

# ╔═╡ 21e35713-538e-4e23-af5e-c4e5cc97ca28
md"""
Let us imagine a situation in which there are three plants which may or may not have sprouted. We imagine that there are three sentences that the speaker could say, “All of the plants have sprouted”, “Some of the plants have sprouted”, or “None of the plants have sprouted”. For simplicity we represent the worlds by the number of sprouted plants (0, 1, 2, or 3) and take a uniform prior over worlds. Using the above representation for communicating with words (with an explicit depth argument):
"""

# ╔═╡ 5b20e3af-08fb-4258-9ad9-1a7af3e74773
all_sprouted(state) = state == 3

# ╔═╡ 74e34862-f43e-4e8f-9021-c72e4c5399ad
some_sprouted(state) = state > 0

# ╔═╡ 6cfa42ad-1f26-41b9-b10b-f24265285fd6
none_sprouted(state) = state == 0

# ╔═╡ bc6674ec-48c7-4531-b99f-2932b1768d79
function meaning(words)
	if words == "all"
		return all_sprouted
	elseif words == "some"
		return some_sprouted
	elseif words == "none"
		return none_sprouted
	end
	@assert true "Unknown words"
end

# ╔═╡ 09e2c795-96c4-41e8-8284-ded50b5eb76d
state_prior = (@~ Categorical([0.25, 0.25, 0.25, 0.25])) -ₚ 1

# ╔═╡ b322e2b8-a498-40d0-8264-69ba5034818a
sentence_prior = pget(["all", "some", "none"]) ∘ @~ Categorical([1/3, 1/3, 1/3])

# ╔═╡ 05a564b5-af72-4d71-ad7a-5700699eb8e6
begin
	function speaker(state, depth)
		condition = (ω -> listener(sentence_prior(ω), depth)(ω)) ==ₚ state
		return sentence_prior |ᶜ condition
	end
	function listener(words, depth)
		if depth == 0
			condition = (ω -> meaning(words)(state_prior(ω)))
		else
			condition = (ω -> speaker(state_prior(ω), depth - 1)(ω)) ==ₚ words
		end
		state_prior |ᶜ condition
	end
end

# ╔═╡ 43ff6d9e-0725-406e-b87f-eb37209967d4
histogram(randsample(listener("some", 1), 1000), bins = 3) # graph isn't same - in WebPpl, they expect some, but not all

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
# ╠═b1d5fd2a-f049-4664-9773-c74247028b86
# ╠═b90bf4ab-7a19-439d-bae8-5d6a834f0d9a
# ╟─92076a20-a0c1-4cde-acf4-c3d4d9bd7568
# ╠═9de65884-f298-44ca-bfc2-88929cb42f2d
# ╟─9ea0aab7-1228-43d5-9a68-47b4d117036c
# ╟─87cd2805-8995-4b9e-8041-e91b70eb4fbe
# ╠═1d1b7607-e0f5-4234-b05b-40daba65bc36
# ╠═96fbba9c-516e-47cc-a3bc-7eefcbfdfc17
# ╠═db8999c9-6293-4e3c-9a79-6b5c29770261
# ╠═94a623bd-0c48-478c-802a-21288ce6c9a5
# ╟─58ec1fc3-2ac8-4ed3-9028-e09dbc10cfc7
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
# ╠═5e752da6-f784-4af1-b51a-9a13f64eff50
# ╟─402d913d-8788-4ade-a11e-d0f09853e5f5
# ╠═0a4ac84e-f51a-41f3-88a2-65cb695b45cf
# ╠═47672c99-dc1a-4674-b008-5c1007f8de80
# ╠═01c7ff1f-2d5d-4334-ad16-7fb74a29391c
# ╠═a9f49983-d018-444e-a683-e32733821213
# ╠═567147c8-6815-48c9-a72e-076b101555e5
# ╟─c33a7649-1a0e-44ac-9b32-3afdb4abf564
# ╟─3130e952-63ed-4236-bca6-f6629c38440c
# ╠═3dc36e8c-a494-4022-8c72-fd1b737d0301
# ╠═e555e6fb-7f99-410d-b440-012819afa731
# ╠═00ec2e96-85ae-410f-b3d1-efb4253da2aa
# ╠═003c79ab-1611-4a3e-963b-69215d886a2d
# ╠═97c6c489-186e-49d1-b538-6b273ae242e2
# ╠═ee6cef1f-f00e-4dba-9689-9d81240f5b84
# ╟─4cf196fe-e24e-4f7c-8b96-3ebdd4b30cca
# ╠═b56af991-6176-4a79-9c98-1d4cdc2e0f93
# ╠═54f8f9d7-6eaf-4398-a58f-26460f138d77
# ╠═ef2ce2f6-e013-4a45-8971-8ceb25464b69
# ╠═de4fc02c-c665-4297-b226-a9822505ea27
# ╠═aa9fc886-f3ca-4ba4-820c-2df951431ee8
# ╟─bdae86a5-ffa0-4a40-a9d9-cc74e7b2685b
# ╟─6c8df318-e265-4c79-a1a4-3b22c3c2156f
# ╟─06b51715-3aa3-4c4a-b12e-c8ad37ede492
# ╠═0eae2e2f-bc8d-4f72-82d8-2923377ee2d5
# ╠═b3ebce3f-172b-45e6-b3b9-e598582b4799
# ╠═b3f646ed-1080-4e11-896d-8584773ed569
# ╠═104c3b09-00d2-444f-a54d-bfef3b23bb79
# ╠═b76ca232-b2b7-4914-a29e-49a2c876e99e
# ╟─401b598e-9b5d-4fef-a8a4-490eff488d65
# ╟─7d39b41a-7f55-4b68-acf4-771e9d927a21
# ╠═0b5adcf4-62ba-46d0-b2eb-72ea316505b7
# ╠═6a76e0cd-7398-4b1b-9b63-0346b689833e
# ╠═4db9de3c-c181-4625-80f7-869e7dc9d2f4
# ╠═fbef5c02-1cd0-4cb3-b6d6-aae639d11585
# ╠═f6700537-858a-421a-87a3-d5f76287f9ed
# ╠═a662c3a1-70d6-4305-84d3-a34c77bd5fb8
# ╟─1190f5c8-371e-41e8-be6c-4d3aea30805b
# ╟─19592b62-f93b-4422-a2de-9bb9fe5c2144
# ╟─21e35713-538e-4e23-af5e-c4e5cc97ca28
# ╠═5b20e3af-08fb-4258-9ad9-1a7af3e74773
# ╠═74e34862-f43e-4e8f-9021-c72e4c5399ad
# ╠═6cfa42ad-1f26-41b9-b10b-f24265285fd6
# ╠═bc6674ec-48c7-4531-b99f-2932b1768d79
# ╠═09e2c795-96c4-41e8-8284-ded50b5eb76d
# ╠═b322e2b8-a498-40d0-8264-69ba5034818a
# ╠═05a564b5-af72-4d71-ad7a-5700699eb8e6
# ╠═43ff6d9e-0725-406e-b87f-eb37209967d4
