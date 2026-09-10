### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 61c9278e-5cbf-4e3c-944d-13d2618b4896
begin
    import Pkg
    Pkg.activate(Base.current_project())
    using Omega, Distributions, Statistics
end

# ╔═╡ 8130ad9b-c0d1-4a6a-9d53-9b5760a9b066
md"""
# 8. Executable self-models and interventions

How might you predict a person who is more forgiving than you? One possibility
is to run a model of yourself with a different way of responding to past hurts.
Here we write that self-model as a program in Omega, intervene on it, and use
the edited program to predict another player.

The example draws on executable behaviour models in
[Modeling Others' Minds as Code](https://arxiv.org/abs/2510.01272) and the use of
self-prediction and functional similarity in
[Embedded Universal Predictive Intelligence](https://arxiv.org/abs/2511.22226).
We supply the self-model here; learning that model from your own behaviour is a
further question. The example illustrates one idea from these papers, not the
full embedded-agent framework.
"""

# ╔═╡ 21fbdb61-d032-4ccc-84c8-4262bab12e34
md"""
## A program that remembers a betrayal

Imagine a repeated cooperation game. Each round, both players choose whether to
cooperate or defect. Mutual cooperation pays 3 each; unilateral defection pays 5
to the defector and 0 to the cooperator; mutual defection pays 1 each. Our player
follows a behaviour rule rather than calculating which action maximises reward.

We use `true` for cooperation and `false` for defection. The player cooperates
while its resentment is below a tolerance. After seeing the partner's action,
it retains a fraction of its resentment and adds one if the partner defected.
The fraction, `retention`, controls how long a betrayal continues to matter.
"""

# ╔═╡ a4bb15c8-3bd0-45de-b938-7e0b5a92d5a0
decay_update(resentment, cooperated, retention) = retention * resentment + !cooperated

# ╔═╡ 01035d77-5bf8-4016-b651-c129da768769
md"""
`!cooperated` is `true` when the partner defects, so it adds one in that case.
With retention 0.9, the player carries 90% of its previous resentment into the
next round. With retention 0.2, it carries only 20%. We call the second player
more forgiving in this specific sense.

The function below runs this rule through a sequence of partner actions. It
records resentment and the intended action **before** observing each round's
partner action, because the players act simultaneously. Every call starts at
zero resentment, so separate episodes do not share memory.
"""

# ╔═╡ 86212111-8a07-48c9-b70e-cb0ed2c840a4
function replay(observed; retention=0.9, tolerance=0.5, update=decay_update)
    resentment = 0.0
    states = Float64[]
    actions = Bool[]
    for cooperated in observed
        push!(states, resentment)
        push!(actions, resentment < tolerance)
        resentment = update(resentment, cooperated, retention)
    end
    (; states, actions, resentment, next_action=resentment < tolerance)
end

# ╔═╡ 83ed9751-879b-42d1-8968-6d5f0241ebd2
partner_actions = [true, false, true, true, true, true]

# ╔═╡ 1b899b11-28d9-4f29-bf33-77b4768a818c
replay(partner_actions)

# ╔═╡ 370eabdd-ec8d-40c2-814b-c6b36ec7ced8
md"""
At the starting settings you should see actions
`[true, true, false, false, false, false]`. The player cooperates in round 2
because it has not yet seen that round's betrayal. It defects in round 3, then
continues to defect while its resentment slowly fades.

Try replacing `false` with `true` in `partner_actions`. The player now has
nothing to resent. Restore the betrayal, then change the call to
`replay(partner_actions; retention=0.2)`. When does cooperation resume?
Keep retention between 0 and 1 and tolerance positive throughout this tutorial.
"""

# ╔═╡ 34aff97d-20a8-4228-86cf-652b0af13dcb
md"""
## Intervene on the self-model

We now name the parts of the program that we want to intervene on. `Variable`
defines an expression in Omega; the argument `ω` denotes the world in which we
evaluate it. Both expressions below return fixed values initially. They are
separate expressions so we can replace their values inside a larger model.
"""

# ╔═╡ 89d21d8d-b031-4842-bf0d-0483b2fd70fe
self_retention = Variable(ω -> 0.9)

# ╔═╡ 3659e021-4210-4379-a959-a2954beeaaf1
resentment_update = Variable(ω -> decay_update)

# ╔═╡ ae38562a-2230-4a3b-92b4-8e6d75c7e419
self_model(observed; tolerance=0.5) = Variable(ω -> replay(observed;
    retention=self_retention(ω), tolerance=tolerance, update=resentment_update(ω)))

# ╔═╡ 840f3ead-e51f-4577-b70e-b784e3906c89
md"""
`self_model` calls the same `replay` function, taking its retention and update
rule from the named expressions. We can now express "what would I do if I let
resentment fade faster?" with `|ᵈ`, the intervention operator.
"""

# ╔═╡ 224a23a4-e77f-401e-a3d6-fc7a6336a59d
original = self_model(partner_actions)

# ╔═╡ 48a58adb-363e-4c9c-afd3-397fa94203e9
forgiving = original |ᵈ (self_retention => 0.2)

# ╔═╡ 53f28f84-885c-42fa-83c1-f8c97ad33800
(original=only(randsample(original, 1)),
 forgiving=only(randsample(forgiving, 1)))

# ╔═╡ 94f12ee8-5d81-41f3-a8fd-218052f44e50
md"""
`randsample` executes each model. We request one result and use `only` to take
it out of its one-element collection. These models contain no random choices,
so repeated executions give the same result.

At the starting settings, the forgiving model returns to cooperation in round
4; the original still defects. The intervention changes the retention expression
inside `forgiving` and leaves `original` intact. Try 0.5 or 1.0 in the intervention
cell and compare the action sequences. At 1.0, resentment never fades.

These are predictions on the same supplied partner sequence. The partner does
not respond to the model's actions in this example.
"""

# ╔═╡ 820df746-12cc-485d-902a-b7bba4a41337
md"""
## The same intervention can have different effects

Suppose two self-models have different tolerances. One cooperates below
resentment 0.5; the other requires resentment below 0.1. We give both the same
history: one betrayal followed by one cooperative action.
"""

# ╔═╡ 3f718c33-483c-4283-af30-65e6646b4010
shared_history = [false, true]

# ╔═╡ 8992d244-d7b6-40b8-a5ac-172532a2976b
first_model = self_model(shared_history; tolerance=0.5)

# ╔═╡ 41ba6a4f-f753-4439-9685-b117013119fa
second_model = self_model(shared_history; tolerance=0.1)

# ╔═╡ 241223a3-443b-481c-ae22-66cc2f08af52
forgiveness = self_retention => 0.2

# ╔═╡ b750e2f3-932a-418d-8ac5-baab09f7e21f
[(tolerance=τ,
  before=only(randsample(model, 1)),
  after=only(randsample(model |ᵈ forgiveness, 1)))
 for (τ, model) in [(0.5, first_model), (0.1, second_model)]]

# ╔═╡ 0b045858-aae3-4ae3-ab07-7a20c074ea90
md"""
Look at `resentment` and `next_action` in each result. Resentment falls from
0.9 to 0.2 in both models. The first model switches from defection to cooperation;
the second still defects because 0.2 exceeds its tolerance.

Add another `true` to `shared_history`. The edited second model now has resentment
0.04 and cooperates too. Its unchanged next action in the shorter history did not
mean the intervention had no effect: the difference appeared later.

Try changing the second model's tolerance. Predictions depend both on the edit
and on the self-model to which we apply it. Here the self-models differ within
one program family; later we will also change the update rule itself.
"""

# ╔═╡ b9df9e28-e978-4aa7-9818-04b0e8ef3a61
md"""
## Learn an edit from another player's actions

So far we chose an edit and inspected its consequences. Now suppose we see
someone else's behaviour and want to infer which edit explains it.

The next two cells describe a short interaction. `my_actions` are what the other
player observed; `their_actions` are what we want to explain. We feed the other
player's observations into the model, so we reuse our behaviour rule from their
perspective. This rule ignores the player's own previous actions, although a
richer self-model could use them too.
"""

# ╔═╡ 88125fae-1051-4d64-8d64-e770810c9aca
my_actions = [true, false, true, true, true]

# ╔═╡ 5149a522-d23c-4f0b-b689-43fc8aaff485
their_actions = [true, true, false, true, true]

# ╔═╡ 0acb1ed7-cb7f-4d73-840b-1f7f06ce3265
md"""
The other player retaliates once after our defection, then cooperates again.
That sequence suggests faster recovery than our starting self-model.

We will consider five possible retention values. The prior gives each value a
weight before seeing the interaction. The similarity prior favours values close
to our own retention; the broad prior gives them equal weights. The number 0.25
controls how strongly we expect the other player to resemble us.
"""

# ╔═╡ c7b47143-1b47-4156-92c6-776dec94d42d
retention_values = [0.0, 0.2, 0.5, 0.8, 0.9]

# ╔═╡ 086a884d-abc4-42c7-b0dd-0da92b410ee8
begin
    similarity_weights = exp.(-abs.(retention_values .- only(randsample(self_retention, 1))) ./ 0.25)
    similarity_prior = similarity_weights / sum(similarity_weights)
end

# ╔═╡ e5c34164-7b1d-4a9c-a804-6880366f4fea
broad_prior = fill(1 / length(retention_values), length(retention_values))

# ╔═╡ 757be270-e91b-42ee-9890-655ec85de796
prior = similarity_prior

# ╔═╡ aff4b2b0-d20e-4c5f-8a41-dd0725a2b979
[(retention=ρ, probability=p) for (ρ, p) in zip(retention_values, prior)]

# ╔═╡ 4756311d-8d88-4122-add3-3a5328e612a2
md"""
With the starting self-model, the prior puts the most weight on 0.9 and very
little on 0.0. Change `prior` to `broad_prior` to start without this preference.
You can return to that cell after seeing the posterior to compare how the same
evidence changes these two initial beliefs.

`Categorical(prior)` chooses an index into `retention_values`. We draw one index
for an episode and use the corresponding retention throughout that episode.
"""

# ╔═╡ 68b2e584-16e9-494f-b8fc-54424c772f67
edit_index = @~ Categorical(prior)

# ╔═╡ 32134d2e-3cf8-46dd-945e-7b3e984fb100
other_retention = Variable(ω -> retention_values[edit_index(ω)])

# ╔═╡ 363c97bb-39c2-452d-8261-553a944674ce
other_model = self_model(my_actions) |ᵈ (self_retention => other_retention)

# ╔═╡ 44e3a3ec-182b-44d7-b3ec-69a3bbc52f68
md"""
`other_model` is our self-model with an uncertain retention value. To allow
occasional actions that disagree with its rule, we add an execution error.
`Bernoulli(p)` generates a Boolean action that cooperates with probability `p`.
For an intended cooperation we use probability 0.9; for an intended defection
we use 0.1. Each round gets its own random choice, named by `(:action, t)`.
"""

# ╔═╡ b2c542b2-d0fb-4323-a2d6-4cb69d4918b2
error_rate = 0.1

# ╔═╡ 10c91bf2-619b-4861-9085-047365a832a8
generated_actions = Variable(ω -> [
    ((:action, t) ~ Bernoulli(cooperates ? 1-error_rate : error_rate))(ω)
    for (t, cooperates) in enumerate(other_model(ω).actions)
])

# ╔═╡ 9eae1867-3393-4ce0-9462-eaff31c8e8b1
randsample(generated_actions, 5)

# ╔═╡ 366da59f-8ab3-4fc4-8195-f10ea5979437
md"""
These are five possible action sequences before conditioning. Some contain
long retaliation, and execution errors can produce an unexpected action at any
round. Rerun the cell to see different draws. Try increasing `error_rate` towards
0.5: at 0.5, the observed actions tell us nothing about retention.

We condition on the generated sequence matching `their_actions`. `|ᶜ` keeps
possible worlds compatible with that observation; sampling the conditioned
retention gives our posterior beliefs about the other player.
"""

# ╔═╡ df8ec9db-eccd-464e-be9e-d9fb02b284a0
matches_actions = Variable(ω -> generated_actions(ω) == their_actions)

# ╔═╡ eea86678-de6d-43b3-9d1c-29da3663fc14
posterior = other_retention |ᶜ matches_actions

# ╔═╡ c21f6097-ece8-4bcc-b147-84caaf178ced
retention_samples = randsample(posterior, 400; alg=RejectionSample)

# ╔═╡ fb1d88db-3efa-4457-90bb-bf28c0f15a8f
[(retention=ρ, prior_probability=prior[k],
  posterior_probability=count(==(ρ), retention_samples) / length(retention_samples))
 for (k, ρ) in enumerate(retention_values)]

# ╔═╡ cd6b7f5b-7160-40ca-8a80-f9a0a5cde696
md"""
At the starting settings, most posterior samples should have retention 0.0 or
0.2. Both values explain the quick return to cooperation. We cannot distinguish
them from this interaction alone: they predict the same intended actions.
The prior favours 0.2, so it usually receives more posterior weight.

Change `their_actions` to `[true, true, false, false, false]`. The posterior now
favours longer-lasting resentment. Alternatively, set both action sequences to
all `true`: every candidate predicts cooperation, so the posterior stays close
to the chosen prior. Keep the two sequences the same length.

The displayed proportions fluctuate because they come from samples. Increasing
400 reduces that fluctuation but takes longer. Keep the sequences short while
exploring: rejection sampling can become slow when matching a full trace is rare.
"""

# ╔═╡ 6510a10a-1c8e-46dc-8e6e-699f78ee7927
md"""
## Predict a new interaction

Can the inferred edits predict a history we have not yet observed? We now supply
two consecutive defections followed by cooperation. For each sampled retention,
we run a fresh episode and predict a cooperation probability in each round.
The function includes the same execution error as the inference model.
"""

# ╔═╡ e10eb093-304b-49ca-b89f-9a390c840031
new_actions = [true, false, false, true, true, true, true, true]

# ╔═╡ 83681362-b6da-43b7-89e9-b1dc16bda2ac
cooperation_probabilities(retention, observed) = [
    cooperates ? 1-error_rate : error_rate
    for cooperates in replay(observed; retention=retention).actions
]

# ╔═╡ abd8092b-844f-468b-b8ea-fc22a996751d
predicted_cooperation = mean([
    cooperation_probabilities(retention, new_actions)
    for retention in retention_samples
])

# ╔═╡ ca177850-7235-46f3-b705-7e6b36324542
self_prediction = cooperation_probabilities(only(randsample(self_retention, 1)), new_actions)

# ╔═╡ dc964126-d2a9-4cd2-acfd-e5af25e90f68
[(round=t, partner_action=new_actions[t],
  unchanged_self=self_prediction[t], inferred_other=predicted_cooperation[t])
 for t in eachindex(new_actions)]

# ╔═╡ 7c3b744c-ea3c-4b41-90e7-9b74ee2415cb
md"""
At the starting settings, both predictions initially favour cooperation and
then retaliation. Around round 5, the inferred other-model favours cooperation
again, while the unchanged self-model still favours defection. The two small
retention values differ here: 0.0 recovers after the first cooperative response,
whereas 0.2 also carries a small residual resentment. They happen to agree on
these actions at tolerance 0.5.

Switch `prior` between `similarity_prior` and `broad_prior` above and watch these
probabilities change. A similarity assumption need not help: it can put too
much weight on models that retain resentment when the other person forgives
quickly. Try a longer-retaliating `their_actions` sequence as well.

No actions from this new interaction enter the posterior. The display shows
predictions, so deciding which prior is better would require new partner actions
to compare against them.
"""

# ╔═╡ aa5ea0b8-0af0-43de-9ec3-fc28360965c4
md"""
## Change the rule, not only a parameter

Suppose someone forgives after two consecutive cooperative actions, regardless
of how many defections preceded them. We can express that rule by replacing the
update function. Its internal state now counts how many cooperative actions are
still needed: a defection sets it to two, and cooperation reduces it by one.
The action rule continues to cooperate when the state is below 0.5.
"""

# ╔═╡ 0080c9fc-9e9a-4a68-bb86-4842321639bd
repair_after_two(remaining, cooperated, retention) =
    cooperated ? max(0.0, remaining - 1) : 2.0

# ╔═╡ 28ca22c8-fe23-44e1-ba49-c6e7d0e48fbb
repair_model = self_model(new_actions) |ᵈ (resentment_update => repair_after_two)

# ╔═╡ aabb5af8-c554-4baa-abec-167595238469
randsample(repair_model, 1)

# ╔═╡ b388db30-75fc-4bcf-b24e-e3784e5d3550
md"""
For the starting `new_actions`, the repair model resumes cooperation in round
6: it has seen cooperative actions in rounds 4 and 5. Insert more defections
before those two cooperative actions. Each defection restarts the countdown,
but two consecutive cooperations still suffice to restore cooperation.

Try setting the countdown to `3.0` in the function. How many cooperative actions does the model now require?
The `retention` argument stays in the function signature so it fits the same
interface, but this rule does not use it. A retention intervention therefore has
no effect on this model. Run the cell below to see that directly.
"""

# ╔═╡ b29f76d9-5f66-4421-89e7-8bcb73ffa6bf
randsample(self_model(new_actions) |ᵈ
    (resentment_update => repair_after_two, self_retention => 0.2), 1)

# ╔═╡ 587471de-a298-4a40-8022-3b93878c88b1
md"""
Try retention 0.5 in the decay model. With tolerance 0.5, it can produce the
same actions as the two-cooperation countdown rule: after a defection the state
is at least 1 but below 2, so one cooperation leaves it at least 0.5 and two
bring it below 0.5. Both models start at zero and share that action threshold.

Matching actions do not make the mechanisms identical. Changing retention to
0.2 speeds up recovery in the decay model, but leaves the countdown model's
behaviour unchanged. A model's expressive limits depend on both the behaviour
rules it can represent and the interventions it makes available.

We supplied the new function ourselves. The earlier inference only chooses a
retention value; it cannot discover this update function, even when a retention value matches its actions. To explore a larger model space,
you could let the unknown edit choose between update functions as well.

An edit can change an action immediately, change it only after more experience,
or leave it unchanged because the model never uses the edited expression.
Which effect you predict depends on the self-model you start with.
"""

# ╔═╡ Cell order:
# ╠═61c9278e-5cbf-4e3c-944d-13d2618b4896
# ╟─8130ad9b-c0d1-4a6a-9d53-9b5760a9b066
# ╟─21fbdb61-d032-4ccc-84c8-4262bab12e34
# ╠═a4bb15c8-3bd0-45de-b938-7e0b5a92d5a0
# ╟─01035d77-5bf8-4016-b651-c129da768769
# ╠═86212111-8a07-48c9-b70e-cb0ed2c840a4
# ╠═83ed9751-879b-42d1-8968-6d5f0241ebd2
# ╠═1b899b11-28d9-4f29-bf33-77b4768a818c
# ╟─370eabdd-ec8d-40c2-814b-c6b36ec7ced8
# ╟─34aff97d-20a8-4228-86cf-652b0af13dcb
# ╠═89d21d8d-b031-4842-bf0d-0483b2fd70fe
# ╠═3659e021-4210-4379-a959-a2954beeaaf1
# ╠═ae38562a-2230-4a3b-92b4-8e6d75c7e419
# ╟─840f3ead-e51f-4577-b70e-b784e3906c89
# ╠═224a23a4-e77f-401e-a3d6-fc7a6336a59d
# ╠═48a58adb-363e-4c9c-afd3-397fa94203e9
# ╠═53f28f84-885c-42fa-83c1-f8c97ad33800
# ╟─94f12ee8-5d81-41f3-a8fd-218052f44e50
# ╟─820df746-12cc-485d-902a-b7bba4a41337
# ╠═3f718c33-483c-4283-af30-65e6646b4010
# ╠═8992d244-d7b6-40b8-a5ac-172532a2976b
# ╠═41ba6a4f-f753-4439-9685-b117013119fa
# ╠═241223a3-443b-481c-ae22-66cc2f08af52
# ╠═b750e2f3-932a-418d-8ac5-baab09f7e21f
# ╟─0b045858-aae3-4ae3-ab07-7a20c074ea90
# ╟─b9df9e28-e978-4aa7-9818-04b0e8ef3a61
# ╠═88125fae-1051-4d64-8d64-e770810c9aca
# ╠═5149a522-d23c-4f0b-b689-43fc8aaff485
# ╟─0acb1ed7-cb7f-4d73-840b-1f7f06ce3265
# ╠═c7b47143-1b47-4156-92c6-776dec94d42d
# ╠═086a884d-abc4-42c7-b0dd-0da92b410ee8
# ╠═e5c34164-7b1d-4a9c-a804-6880366f4fea
# ╠═757be270-e91b-42ee-9890-655ec85de796
# ╠═aff4b2b0-d20e-4c5f-8a41-dd0725a2b979
# ╟─4756311d-8d88-4122-add3-3a5328e612a2
# ╠═68b2e584-16e9-494f-b8fc-54424c772f67
# ╠═32134d2e-3cf8-46dd-945e-7b3e984fb100
# ╠═363c97bb-39c2-452d-8261-553a944674ce
# ╟─44e3a3ec-182b-44d7-b3ec-69a3bbc52f68
# ╠═b2c542b2-d0fb-4323-a2d6-4cb69d4918b2
# ╠═10c91bf2-619b-4861-9085-047365a832a8
# ╠═9eae1867-3393-4ce0-9462-eaff31c8e8b1
# ╟─366da59f-8ab3-4fc4-8195-f10ea5979437
# ╠═df8ec9db-eccd-464e-be9e-d9fb02b284a0
# ╠═eea86678-de6d-43b3-9d1c-29da3663fc14
# ╠═c21f6097-ece8-4bcc-b147-84caaf178ced
# ╠═fb1d88db-3efa-4457-90bb-bf28c0f15a8f
# ╟─cd6b7f5b-7160-40ca-8a80-f9a0a5cde696
# ╟─6510a10a-1c8e-46dc-8e6e-699f78ee7927
# ╠═e10eb093-304b-49ca-b89f-9a390c840031
# ╠═83681362-b6da-43b7-89e9-b1dc16bda2ac
# ╠═abd8092b-844f-468b-b8ea-fc22a996751d
# ╠═ca177850-7235-46f3-b705-7e6b36324542
# ╠═dc964126-d2a9-4cd2-acfd-e5af25e90f68
# ╟─7c3b744c-ea3c-4b41-90e7-9b74ee2415cb
# ╟─aa5ea0b8-0af0-43de-9ec3-fc28360965c4
# ╠═0080c9fc-9e9a-4a68-bb86-4842321639bd
# ╠═28ca22c8-fe23-44e1-ba49-c6e7d0e48fbb
# ╠═aabb5af8-c554-4baa-abec-167595238469
# ╟─b388db30-75fc-4bcf-b24e-e3784e5d3550
# ╠═b29f76d9-5f66-4421-89e7-8bcb73ffa6bf
# ╟─587471de-a298-4a40-8022-3b93878c88b1
