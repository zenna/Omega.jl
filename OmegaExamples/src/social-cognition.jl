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
get_good_widget_simple = widget |ᶜ (widget >ₚ tolerance)

# ╔═╡ 92076a20-a0c1-4cde-acf4-c3d4d9bd7568
md"`randsample` uses rejection sampling by default, but we could also explicitly specify it by using `alg` keyword as given below:"

# ╔═╡ 9de65884-f298-44ca-bfc2-88929cb42f2d
histogram(randsample(get_good_widget_simple, 1000, alg = RejectionSample), bins = 7) 

# ╔═╡ d3dfb144-2d16-4528-85ab-2dcaf7e6643e
md"""
We are now abstracting the tester machine, rather than thinking about the details inside the widget tester. We represent only that the machine correctly gives a widget above tolerance (by some means).
"""

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
	action_prior |ᶜ ((ω -> transition(action_prior(ω))) ==ₚ goal_state)
end

# ╔═╡ 94a623bd-0c48-478c-802a-21288ce6c9a5
sally_cookie_samples = randsample(choose_action("cookie", vending_machine), 1000)

# ╔═╡ ef0c5d84-8e90-4508-a56b-cf621ce1e887
barplot(Dict(freqtable(string.(sally_cookie_samples))))

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
	action_prior |ᶜ ((ω -> transition(ω, action_prior(ω))) ==ₚ goal_state)
end

# ╔═╡ 041bd9be-7161-4e2c-8ea1-f1e93c63836e
action_samples = randsample(choose_action_stochastic("cookie", vending_machine_stochastic), 100)

# ╔═╡ 95cc8a2b-3280-4ed0-9d64-488062b09a10
histogram(action_samples, bins = 1)

# ╔═╡ 6f619867-9af2-47d9-9621-759b65593a84
md"## Inferring Goals
Now imagine that we don’t know Sally’s goal (which food she wants), but we observe her pressing button $2$. We can infer her goal (this is sometimes called “inverse planning”) as follows:"

# ╔═╡ 344b85fc-d799-43a0-856c-297679084156
goal = pget(["bagel", "cookie"]) ∘ @~ Categorical([.5, .5])

# ╔═╡ 1f10beb3-9483-4619-83ba-49f743135898
action_dist(ω) = 
	choose_action_stochastic(goal(ω), vending_machine_stochastic)(ω)

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
# md"Despite the fact that button $2$ is equally likely to result in either bagel or cookie, we have inferred that Sally probably wants a cookie. This is a result of the inference implicitly taking into account the counterfactual alternatives: if Sally had wanted a bagel, she would have likely pressed button $1$. The inner query takes these alternatives into account, adjusting the probability of the observed action based on alternative goals."

# ╔═╡ 3130e952-63ed-4236-bca6-f6629c38440c
md"## Inferring preferences

If we have some prior knowledge about Sally’s preferences (which goals she is likely to have) we can incorporate this immediately into the prior over goals (which above was uniform).

A more interesting situation is when we believe that Sally has some preferences, but we don’t know what they are. We capture this by adding a higher level prior (a uniform) over preferences. Using this we can learn about Sally’s preferences from her actions: after seeing Sally press button $2$ several times, what will we expect her to want the next time?
"

# ╔═╡ d420ef02-1dde-4fc9-860e-b6da08ade38e
action_prior_has_preference = Categorical([0.5, 0.5])

# ╔═╡ 2c25f6da-532c-4182-84d2-6a184aaef328
function choose_action_(goal_state, transition, state = 0)
	action = (@uid, state) ~ action_prior_has_preference
	action |ᶜ ((ω -> transition(ω, action(ω))) ==ₚ goal_state)
end

# ╔═╡ 3dc36e8c-a494-4022-8c72-fd1b737d0301
preference = @~ Uniform(0 , 1)

# ╔═╡ e555e6fb-7f99-410d-b440-012819afa731
goal_prior(ω) = (@~ Bernoulli(preference))(ω) ? "bagel" : "cookie"

# ╔═╡ 00ec2e96-85ae-410f-b3d1-efb4253da2aa
action_dist_has_preference(i, ω) = 
choose_action_(goal_prior(ω), vending_machine_stochastic, i)(ω)

# ╔═╡ 003c79ab-1611-4a3e-963b-69215d886a2d
random_actions = manynth(action_dist_has_preference, 1:3)

# ╔═╡ ee6cef1f-f00e-4dba-9689-9d81240f5b84
goal_posterior_samples = 
		randsample(goal_prior |ᶜ (random_actions ==ₚ [2, 2, 2]), 1000)

# ╔═╡ 3c1c3c99-b5d1-4266-b788-e4f3093fa8ec
barplot(Dict(freqtable(goal_posterior_samples)))

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
action_dist_cookie(i, ω) = 
choose_action_(goal_prior(ω), vending_machine_cookie, i)(ω)

# ╔═╡ ef2ce2f6-e013-4a45-8971-8ceb25464b69
random_actions_cookie = manynth(action_dist_cookie, 1:3)

# ╔═╡ de4fc02c-c665-4297-b226-a9822505ea27
goal_posterior_cookie_samples = 
		randsample(goal_prior |ᶜ (random_actions_cookie ==ₚ [2, 2, 2]), 1000)

# ╔═╡ aa9fc886-f3ca-4ba4-820c-2df951431ee8
barplot(Dict(freqtable(goal_posterior_cookie_samples))) # counterfactuals?

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
function vending_machine_know(action, ω)
	choices = ["bagel", "cookie"]
	if action in [1, 2] 
		c = buttons_to_bagel_probs(action, ω)
		choices[(@~ Categorical([c, 1 - c]))(ω)]
	end
end

# ╔═╡ 18151805-6eab-4194-a417-7342c6982097
function choose_action_know(goal_state, transition)
	action_prior |ᶜ ((ω -> transition(action_prior(ω), ω)) ==ₚ goal_state)
end

# ╔═╡ 1be75cb1-af3e-4292-ad92-9dfd1f872ba9
action_dist_know(ω) = choose_action_know(goal(ω), vending_machine_know)(ω)

# ╔═╡ 104c3b09-00d2-444f-a54d-bfef3b23bb79
buttons(ω) = 
	(button_1 = (1 ~ vending_machine_know)(ω), button_2 = (2 ~ vending_machine_know)(ω))

# ╔═╡ 02213e53-3ae7-4648-90f5-8550960ff2d8
buttons_posterior = buttons |ᶜ ((action_dist_know ==ₚ 2) &ₚ (goal ==ₚ "cookie"))

# ╔═╡ fe8cd9b8-dd5a-4e3f-8ad6-5e83da95ac99
buttons_joint_samples = randsample(buttons_posterior, 1000)

# ╔═╡ 4ff9d1cf-90f8-4b0f-90ff-cad5312b92db
button_1_marginal_samples = map(b -> b.button_1, buttons_joint_samples)

# ╔═╡ bff4d249-fcd3-4579-94b3-47a218fe7404
barplot(Dict(freqtable(button_1_marginal_samples)))

# ╔═╡ 30b61892-a83e-4457-98b1-867b66e1321d
button_2_marginal_samples = map(b -> b.button_2, buttons_joint_samples)

# ╔═╡ aaac91be-6a4a-4290-a8d1-f4ef83bf3461
barplot(Dict(freqtable(button_2_marginal_samples)))

# ╔═╡ 4c7553e7-98a4-4b3a-be3a-121b40e263df
md"""
Now imagine a vending machine that has only one button, but it can be pressed many times. We don’t know what the machine will do in response to a given button sequence. We do know that pressing more buttons is less a priori likely.
"""

# ╔═╡ 2223b737-71d8-4561-a692-b90d057c6f5b
action_prior_one_button = @~ Categorical([0.7, 0.2, 0.1])

# ╔═╡ aa93c504-d85e-4224-a2a5-649e51f25aa9
function vending_machine_one_button(action, ω)
	choices = ["bagel", "cookie"]
	if action in [1, 2, 3] 
		c = buttons_to_bagel_probs(action, ω)
		choices[(@~ Categorical([c, 1 - c]))(ω)]
	end
end

# ╔═╡ 52e4a044-db32-45e0-a601-7fbe2c2377dc
function choose_action_one_button(goal_state, transition)
	action_prior_one_button |ᶜ ((ω -> transition(action_prior_one_button(ω), ω)) ==ₚ goal_state)
end

# ╔═╡ 3ede7dc8-306f-44ae-a33d-d0a56d1f2274
action_dist_one_button(ω) = choose_action_one_button(goal(ω), vending_machine_one_button)(ω)

# ╔═╡ 31b13fda-f3ef-4b9f-b53c-f648424efcda
buttons_(ω) = 
	(button_once = (1 ~ vending_machine_one_button)(ω), button_twice = (2 ~ vending_machine_one_button)(ω))

# ╔═╡ 181819f5-0644-4d9b-be8a-05ada90f3575
buttons_posterior_ = 
	buttons_ |ᶜ ((action_dist_one_button ==ₚ 1) &ₚ(goal ==ₚ "cookie"))

# ╔═╡ 731b1469-c307-4425-bbdd-6f07741354a8
buttons_joint_samples_ = randsample(buttons_posterior_, 1000)

# ╔═╡ 862eb6ab-a805-4267-8e65-4187736ad523
button_once_marginal_samples = map(b -> b.button_once, buttons_joint_samples_)

# ╔═╡ e66754b1-e389-4691-903f-dbb01aaa16af
barplot(Dict(freqtable(button_once_marginal_samples)))

# ╔═╡ 86cb8c39-5ec4-49a5-aa59-483a59a26c06
button_twice_marginal_samples = map(b -> b.button_twice, buttons_joint_samples_)

# ╔═╡ bc7b13f0-182c-4698-b09e-d0cde415e774
barplot(Dict(freqtable(button_twice_marginal_samples)))

# ╔═╡ db5df471-6ddd-41be-8cd8-eca55dc5f729
md"""
#### Joint inference about knowledge and goals
In social cognition, we often make joint inferences about two kinds of mental states: agents’ beliefs about the world and their desires, goals or preferences. We can see an example of such a joint inference in the vending machine scenario. Suppose we condition on two observations: that Sally presses the button twice, and that this results in a cookie. Then, assuming that she knows how the machine works, we jointly infer that she wanted a cookie, that pressing the button twice is likely to give a cookie, and that pressing the button once is unlikely to give a cookie.
"""

# ╔═╡ a981b051-e6fc-4c35-88c8-f7f98a956d86
knowledge_and_goals(ω) = (goal = goal(ω),
          one_press_result = (1 ~ vending_machine_one_button)(ω),
          two_press_result = (2 ~ vending_machine_one_button)(ω),
          one_press_cookie_prob = 1 - (1 ~ buttons_to_bagel_probs)(ω))

# ╔═╡ ea60f93d-7e68-473b-aa7c-1d79c9c22b6b
kg_posterior = knowledge_and_goals |ᶜ (((2 ~ vending_machine_one_button) ==ₚ "cookie") &ₚ (action_dist_one_button ==ₚ 2))

# ╔═╡ fba8029e-0167-4940-aeb5-71029acc61fb
kg_samples = randsample(kg_posterior, 1000)

# ╔═╡ 5e1861df-9f3b-49dd-a786-b56a4e380223
kg_goals = map(b -> b.goal, kg_samples)

# ╔═╡ 6e3de869-b82a-4765-b22c-d13ebc343fb0
barplot(Dict(freqtable(kg_goals)))

# ╔═╡ 05bd87c7-c994-4044-968c-e35644b67b66
kg_one = map(b -> b.one_press_result, kg_samples)

# ╔═╡ 89aeb454-7d97-45f2-9282-97426129bf8b
kg_two = map(b -> b.two_press_result, kg_samples)

# ╔═╡ 23b85822-9bbb-4883-987b-9174d3f25a00
barplot(Dict(freqtable(kg_two)))

# ╔═╡ 394a60fe-1151-4d39-ae54-734cad3d30cb
barplot(Dict(freqtable(kg_one)))

# ╔═╡ d9ab6345-0b66-44a0-a701-b83980760c1c
kg_one_press_cookie_prob = map(b -> b.one_press_cookie_prob, kg_samples)

# ╔═╡ 28533c5e-f2dc-46b3-9119-19bcb1b0f4ff
histogram(kg_one_press_cookie_prob)

# ╔═╡ ca810a1d-7346-414a-9cec-2fea3e82e2e5
md"""
## Inferring whether they know
Let’s imagine that we (the observer) know that the vending machine actually tends to return a bagel for button a and a cookie for button b. But we don’t know if Sally knows this! Instead we see Sally announce that she wants a cookie, but pushes button a. How can we determine, from her actions, whether Sally is knowledgeable or ignorant? We hypothesize that if she is ignorant, Sally chooses according to a random vending machine. We can then infer her knowledge state:
"""

# ╔═╡ f87269c5-e8ef-4962-8657-322eae99647d
b_probs = [0.9, 0.1]

# ╔═╡ cdd71cec-def1-44d7-987b-816b9e826c82
function true_vending_machine(ω, action)
	choices = ["bagel", "cookie"]
	c = b_probs[action]
	choices[(@~ Categorical([c, 1 - c]))(ω)]
end

# ╔═╡ e907c9aa-afeb-41ae-aee3-d7ba4b904a57
function random_machine(ω, action)
	choices = ["bagel", "cookie"]
	choices[(@~ Categorical([0.5, 0.5]))(ω)]
end

# ╔═╡ 123eedbb-6bdc-42dc-abf2-463777bde75e
knows = @~ Bernoulli()

# ╔═╡ c9d90acc-23d3-478e-b887-32ff1bd552bd
s = randsample(knows |ᶜ (((ω -> choose_action_stochastic("cookie", knows(ω) ? true_vending_machine : random_machine)(ω)) ==ₚ 1) &ₚ ((ω -> true_vending_machine(ω, 1)) ==ₚ "bagel")), 1000)

# ╔═╡ 65d1c8e0-e847-4d84-b7b7-1cf24cfce057
barplot(Dict(freqtable(string.(s))))

# ╔═╡ 8764c334-f275-40d1-b455-d5a28c7793e4
md"""
This is a very simple example, but it illustrates how we can represent a difference in knowledge between the observer and the observed agent by simply using different world models (the vending machines) for explaining the action (in `choose_action_stochastic`) and for explaining the outcome (in `|ᶜ`).

## Inferring what they believe
Above we assumed that if Sally is ignorant, she chooses based on a random machine. This is both not flexible enough and too strong an assumption. Indeed, Sally may have all kinds of specific (and potentially false) beliefs about vending machines. To capture this, we can represent Sally’s beliefs as a separate randomly chosen vending machine: by passing this into Sally’s chooseAction we indicate these are Sally’s beliefs, by putting this inside the outer Infer we represent the observer reasoning about Sally’s beliefs:
"""

# ╔═╡ 3a8d3c56-b89e-4ed1-8cd1-803a641bece7
sally_belief(i, ω) = ((@uid, i) ~ Uniform(0, 1))(ω)

# ╔═╡ 92e83a4b-1f06-464e-9bc9-d849e9fd1336
function sally_machine(ω, action)
	choices = ["bagel", "cookie"]
	c = (action ~ sally_belief)(ω)
	choices[(@~ Categorical([c, 1 - c]))(ω)]
end

# ╔═╡ c570958b-13fd-4909-91c2-3b126872c354
s_ = randsample((ω -> sally_machine(ω, 1)) |ᶜ (((ω -> choose_action_stochastic("cookie", sally_machine)(ω)) ==ₚ 1) &ₚ ((ω -> true_vending_machine(ω, 1)) ==ₚ "bagel")), 1000)

# ╔═╡ 6d62e403-bfe4-4bef-8092-c9a20b884bab
barplot(Dict(freqtable(string.(s_))))

# ╔═╡ 2f2b71f6-7e60-44cb-96d0-9a20578d258e
md"In the developmental psychology literature, the ability to represent and reason about other people’s _false beliefs_ has been extensively investigated as a hallmark of human Theory of Mind."

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
# ╟─d3dfb144-2d16-4528-85ab-2dcaf7e6643e
# ╟─9ea0aab7-1228-43d5-9a68-47b4d117036c
# ╟─87cd2805-8995-4b9e-8041-e91b70eb4fbe
# ╠═1d1b7607-e0f5-4234-b05b-40daba65bc36
# ╠═96fbba9c-516e-47cc-a3bc-7eefcbfdfc17
# ╠═db8999c9-6293-4e3c-9a79-6b5c29770261
# ╠═94a623bd-0c48-478c-802a-21288ce6c9a5
# ╠═ef0c5d84-8e90-4508-a56b-cf621ce1e887
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
# ╠═c33a7649-1a0e-44ac-9b32-3afdb4abf564
# ╟─3130e952-63ed-4236-bca6-f6629c38440c
# ╠═d420ef02-1dde-4fc9-860e-b6da08ade38e
# ╠═2c25f6da-532c-4182-84d2-6a184aaef328
# ╠═3dc36e8c-a494-4022-8c72-fd1b737d0301
# ╠═e555e6fb-7f99-410d-b440-012819afa731
# ╠═00ec2e96-85ae-410f-b3d1-efb4253da2aa
# ╠═003c79ab-1611-4a3e-963b-69215d886a2d
# ╠═ee6cef1f-f00e-4dba-9689-9d81240f5b84
# ╠═3c1c3c99-b5d1-4266-b788-e4f3093fa8ec
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
# ╠═18151805-6eab-4194-a417-7342c6982097
# ╠═1be75cb1-af3e-4292-ad92-9dfd1f872ba9
# ╠═104c3b09-00d2-444f-a54d-bfef3b23bb79
# ╠═02213e53-3ae7-4648-90f5-8550960ff2d8
# ╠═fe8cd9b8-dd5a-4e3f-8ad6-5e83da95ac99
# ╠═4ff9d1cf-90f8-4b0f-90ff-cad5312b92db
# ╠═bff4d249-fcd3-4579-94b3-47a218fe7404
# ╠═30b61892-a83e-4457-98b1-867b66e1321d
# ╠═aaac91be-6a4a-4290-a8d1-f4ef83bf3461
# ╟─4c7553e7-98a4-4b3a-be3a-121b40e263df
# ╠═2223b737-71d8-4561-a692-b90d057c6f5b
# ╠═aa93c504-d85e-4224-a2a5-649e51f25aa9
# ╠═52e4a044-db32-45e0-a601-7fbe2c2377dc
# ╠═3ede7dc8-306f-44ae-a33d-d0a56d1f2274
# ╠═31b13fda-f3ef-4b9f-b53c-f648424efcda
# ╠═181819f5-0644-4d9b-be8a-05ada90f3575
# ╠═731b1469-c307-4425-bbdd-6f07741354a8
# ╠═862eb6ab-a805-4267-8e65-4187736ad523
# ╠═e66754b1-e389-4691-903f-dbb01aaa16af
# ╠═86cb8c39-5ec4-49a5-aa59-483a59a26c06
# ╠═bc7b13f0-182c-4698-b09e-d0cde415e774
# ╟─db5df471-6ddd-41be-8cd8-eca55dc5f729
# ╠═a981b051-e6fc-4c35-88c8-f7f98a956d86
# ╠═ea60f93d-7e68-473b-aa7c-1d79c9c22b6b
# ╠═fba8029e-0167-4940-aeb5-71029acc61fb
# ╠═5e1861df-9f3b-49dd-a786-b56a4e380223
# ╠═6e3de869-b82a-4765-b22c-d13ebc343fb0
# ╠═05bd87c7-c994-4044-968c-e35644b67b66
# ╠═23b85822-9bbb-4883-987b-9174d3f25a00
# ╠═89aeb454-7d97-45f2-9282-97426129bf8b
# ╠═394a60fe-1151-4d39-ae54-734cad3d30cb
# ╠═d9ab6345-0b66-44a0-a701-b83980760c1c
# ╠═28533c5e-f2dc-46b3-9119-19bcb1b0f4ff
# ╟─ca810a1d-7346-414a-9cec-2fea3e82e2e5
# ╠═f87269c5-e8ef-4962-8657-322eae99647d
# ╠═cdd71cec-def1-44d7-987b-816b9e826c82
# ╠═e907c9aa-afeb-41ae-aee3-d7ba4b904a57
# ╠═123eedbb-6bdc-42dc-abf2-463777bde75e
# ╠═c9d90acc-23d3-478e-b887-32ff1bd552bd
# ╠═65d1c8e0-e847-4d84-b7b7-1cf24cfce057
# ╟─8764c334-f275-40d1-b455-d5a28c7793e4
# ╠═3a8d3c56-b89e-4ed1-8cd1-803a641bece7
# ╠═92e83a4b-1f06-464e-9bc9-d849e9fd1336
# ╠═c570958b-13fd-4909-91c2-3b126872c354
# ╠═6d62e403-bfe4-4bef-8092-c9a20b884bab
# ╟─2f2b71f6-7e60-44cb-96d0-9a20578d258e
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
