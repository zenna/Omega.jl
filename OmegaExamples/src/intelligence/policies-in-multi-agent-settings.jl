### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 1ac95343-9d93-40cf-a495-1751114f10a7
begin
    import Pkg
    # Set to `true` to run against your local Omega.jl checkout instead of
    # installing the published `complete-probmods` branch.
    use_local_omega = true
    if use_local_omega
        Pkg.activate(Base.current_project())
    else
        Pkg.activate(mktempdir())
        repo = "https://github.com/zenna/Omega.jl"
        rev = "complete-probmods"
        Pkg.add([
            Pkg.PackageSpec(url=repo, rev=rev),
            Pkg.PackageSpec(url=repo, rev=rev, subdir="OmegaCore"),
            Pkg.PackageSpec(url=repo, rev=rev, subdir="InferenceBase"),
            Pkg.PackageSpec(url=repo, rev=rev, subdir="SoftPredicates"),
            Pkg.PackageSpec(url=repo, rev=rev, subdir="connectors/OmegaDistributions"),
            Pkg.PackageSpec(url=repo, rev=rev, subdir="connectors/OmegaSoftPredicates"),
            Pkg.PackageSpec(url=repo, rev=rev, subdir="OmegaMH"),
            Pkg.PackageSpec(url=repo, rev=rev, subdir="ReplicaExchange"),
            Pkg.PackageSpec(url=repo, rev=rev, subdir="OmegaExamples"),
        ])
    end
    using Omega, Distributions, OmegaExamples, UnicodePlots
end

# ╔═╡ 6d728a56-c1a2-4ae3-9c61-a06c9b47e498
md"""
# 7. Representing and revising models of other agents

Chapters 1–4 asked which distinctions a representation must keep to answer a
question. We now use the same techniques to ask about another player: given an
interaction history, will the opponent hunt in the next round? Under a
stationary model, a count of past hunts is enough. A model of how trust changes
also needs to keep track of what the focal player did.

We compare three programmatic opponent models in a repeated Stag Hunt. First,
we predict from action counts. Then we infer a strategy from a supplied library,
as Chapter 5 inferred a rule from examples. Finally, we infer a memory parameter
within an opponent policy and use Chapter 6's intervention operator to compare
responses to focal actions we choose. Inference learns from the recorded past;
intervention changes a future action while keeping the opponent and past fixed.

The histories below are short observations of an interaction with no announced
ending round. We infer models from recorded actions and compute predictions
from supplied histories. We also show how a greedy focal player would choose
an action from a next-round prediction. We do not run an ongoing interaction
or compare the predictions with new opponent observations.
"""

# ╔═╡ b8f8a187-e266-4c15-8ab6-7cc7f2db4aaa
md"""
## Greedy player

Each player chooses `hunt_stag` or `forage_safe` simultaneously. Hunting pays
4 when the opponent also hunts and 0 otherwise. Foraging always pays 1. If the
focal player predicts that the opponent hunts with probability ``p``, hunting
has expected immediate reward ``4p`` and foraging has reward 1. A greedy player
therefore hunts exactly when ``p>1/4`` and otherwise takes the safe action.

`JointHistory` keeps both players' actions in order. Its `focal` and `opponent`
vectors record simultaneous actions, so a strategy predicting round `t` can
use only the actions from earlier rounds.
"""

# ╔═╡ 150ef3a1-522e-4a09-b771-44fc72819efb
@enum Action forage_safe hunt_stag

# ╔═╡ 193a472f-0ba1-4feb-af05-88835145bf63
struct JointHistory
    focal::Vector{Action}
    opponent::Vector{Action}

    function JointHistory(focal::Vector{Action}, opponent::Vector{Action})
        length(focal) == length(opponent) ||
            throw(ArgumentError("focal and opponent histories must have equal length"))
        new(focal, opponent)
    end
end

# ╔═╡ 3c7c071b-953d-4937-93ab-ed30fa29d005
function expected_immediate_reward(action::Action, p_hunt::Real)
    0 <= p_hunt <= 1 || throw(ArgumentError("p_hunt must lie in [0, 1]"))
    action == hunt_stag ? 4 * float(p_hunt) : 1.0
end

# ╔═╡ af664b72-2fc8-46da-9e6c-9fe8457da41b
function greedy_response(p_hunt::Real)
    hunt_value = expected_immediate_reward(hunt_stag, p_hunt)
    safe_value = expected_immediate_reward(forage_safe, p_hunt)
    hunt_value > safe_value ? hunt_stag : forage_safe
end

# ╔═╡ f7f75f76-6b40-487e-af41-42b9a0841cc0
[(p_hunt=p, action=greedy_response(p)) for p in [0.1, 0.25, 0.4, 0.9]]

# ╔═╡ 20ce487b-b1ff-41de-9b11-9010c37814a4
md"""
At probability 0.25, hunting and foraging have the same immediate expected
reward, and our rule chooses to forage. Edit the probabilities
in the cell, then try changing the hunting reward from 4 to 2 in
`expected_immediate_reward`. How does the decision threshold move?
"""

# ╔═╡ 0fb05915-859f-4b5e-9db7-0d751bf6fa98
md"""
## Compression to a stationary strategy

The simplest opponent model uses stationary mixed strategies ``\pi_q``:
hunt with probability ``q``, independently of history. We place a uniform
``\operatorname{Beta}(1,1)`` prior on ``q`` and condition on the observed
number of opponent hunts.

The representation is an `(events, hunts)` pair, like the `(flips, heads)` pair
in Chapter 2. Given ``q``, the actions are independent Bernoulli draws, so their
count has a binomial distribution. We generate that count directly. Reordering
the opponent's actions or changing the focal actions leaves the representation
unchanged. It therefore cannot express responses to the focal player or changes
in trust, however much data we collect.
"""

# ╔═╡ 6d22f491-c1ea-4f5e-ae6c-34e66aa722c6
history_without_repair = JointHistory(
    [forage_safe, forage_safe, hunt_stag],
    [hunt_stag, forage_safe, forage_safe],
)

# ╔═╡ 64715e09-090d-4718-9a47-9d3ce04c1927
history_after_repair = JointHistory(
    [forage_safe, hunt_stag, hunt_stag],
    [hunt_stag, forage_safe, forage_safe],
)

# ╔═╡ 0f09ccc9-aee1-4b73-a90f-5adf55c3e288
md"""
Both histories contain the same opponent actions: hunt, safe, safe. Only the
focal actions differ: in `history_after_repair`, the last two focal actions are
hunts.
"""

# ╔═╡ 44eef06a-9c47-448e-8ee4-f6dbc0a6c9d4
stationary_hunt_rate = @~ Beta(1, 1)

# ╔═╡ a0a89a69-3d2b-4633-8d4d-6ffd90002063
stationary_representation(history::JointHistory) = (
    events = length(history.opponent),
    hunts = count(==(hunt_stag), history.opponent),
)

# ╔═╡ 16b90f4d-a820-422e-9dfd-e37881e12ecf
stationary_hunt_count(events) = Variable(ω ->
    (@~ Binomial(events, stationary_hunt_rate(ω)))(ω))

# ╔═╡ e4b50f2c-5989-4a52-a54a-52d14f345cd0
function stationary_posterior(history::JointHistory)
    coordinate = stationary_representation(history)
    matches_count = stationary_hunt_count(coordinate.events) .== coordinate.hunts
    stationary_hunt_rate |ᶜ matches_count
end

# ╔═╡ 76fabd04-ec95-4e7a-921c-dc7ec9784194
md"""
`stationary_representation` compresses a history to its count coordinate.
`stationary_posterior` conditions the hunt rate on that coordinate, and the
posterior mean decodes it into a prediction for the next round.
"""

# ╔═╡ 456c6cdb-2cab-454c-91f7-bac047a5341f
function stationary_projection(
    history::JointHistory,
    hunt_rate_samples::AbstractVector{<:Real},
)
    isempty(hunt_rate_samples) &&
        throw(ArgumentError("hunt_rate_samples must not be empty"))
    p_hunt = mean(hunt_rate_samples)
    (
        representation = stationary_representation(history),
        p_hunt = p_hunt,
        action = greedy_response(p_hunt),
    )
end

# ╔═╡ 59a24ac0-6720-4a1f-a1db-71446a81215c
stationary_samples = randsample(
    stationary_posterior(history_without_repair), 400; alg = RejectionSample)

# ╔═╡ 70535c63-fda8-465a-93f1-da2698fe1a45
md"""
One hunt and two safe actions update the uniform prior to `Beta(2,3)`, whose
mean is 0.4. Both histories have the same count coordinate, so they give the
same posterior.
"""

# ╔═╡ 0921a0d2-4042-4925-9a0d-dd8886f004ee
viz(stationary_samples)

# ╔═╡ 7ae14849-8d09-43a4-b2d1-ded6201b6e25
stationary_without_repair = stationary_projection(
    history_without_repair,
    stationary_samples,
)

# ╔═╡ 733c4148-1cf9-45a6-ac75-a37cc020ecd0
stationary_after_repair = stationary_projection(
    history_after_repair,
    stationary_samples,
)

# ╔═╡ 3cdcd170-d003-4332-9e04-901e3ffd2a2d
permuted_opponent_history = JointHistory(
    copy(history_without_repair.focal),
    [forage_safe, hunt_stag, forage_safe],
)

# ╔═╡ 5e0c2a61-7d4b-4f2e-9c1a-3b8d6f0e2a47
md"""
Reordering the opponent's actions to safe, hunt, safe also leaves the coordinate
unchanged. The stationary model therefore gives all three histories the same
posterior. Try changing only the focal actions, then changing the opponent's
hunt count. Which change can this representation detect?
"""

# ╔═╡ 8b4f1d93-2c6e-4a07-b5d8-e19a7c3f6b20
(
    original = stationary_representation(history_without_repair),
    permuted = stationary_representation(permuted_opponent_history),
)

# ╔═╡ 36ebdb45-7dd5-45be-b602-c9201718864a
md"""
## Selecting a strategy from a library

We now expand the set of opponent models, as we expanded the representation in
Chapter 4. `always_hunt` and `always_safe` ignore history. `grim_trust` treats
one safe action as a permanent loss of trust, while `repair_after_two` lets two
consecutive hunts restore it.

Each candidate program predicts the opponent's action from the focal player's
past actions. A uniform categorical prior chooses one program for the whole
history. We generate its actions with error probability 0.1 and condition on
the observed opponent actions. The resulting labels name programs in the
supplied library; they do not establish the opponent's true type. The focal
player's decision rule remains `greedy_response`.
"""

# ╔═╡ 04b81687-d694-4e06-bafa-00d2a7111068
always_hunt(other_actions::AbstractVector{Action}) = hunt_stag

# ╔═╡ e523ad30-163a-418b-a7a0-f7883fba3864
always_safe(other_actions::AbstractVector{Action}) = forage_safe

# ╔═╡ 607629b3-7edb-417f-a168-afdc1c808790
grim_trust(other_actions::AbstractVector{Action}) =
    forage_safe in other_actions ? forage_safe : hunt_stag

# ╔═╡ b18e073c-6cd2-47ef-b8f9-a6a042420a2a
function repair_after_two(other_actions::AbstractVector{Action})
    forage_safe in other_actions || return hunt_stag
    repaired = length(other_actions) >= 2 &&
        other_actions[end - 1:end] == [hunt_stag, hunt_stag]
    repaired ? hunt_stag : forage_safe
end

# ╔═╡ 5a244279-7ac6-443a-8cf5-b57268e8c8d7
stateful_library = [
    :always_hunt => always_hunt,
    :always_safe => always_safe,
    :grim_trust => grim_trust,
    :repair_after_two => repair_after_two,
]

# ╔═╡ b2c542b2-d0fb-4323-a2d6-4cb69d4918b2
error_rate = 0.1

# ╔═╡ 970f10bd-10b4-4bdc-ad74-43c3b014dbb5
function stateful_posterior(history::JointHistory; library=stateful_library, error_rate=0.1)
    program_index = @~ Categorical(fill(1 / length(library), length(library)))
    generated_actions = Variable(ω -> [
        begin
            strategy = last(library[program_index(ω)])
            intends_hunt = strategy(history.focal[1:t-1]) == hunt_stag
            ((:action, t) ~ Bernoulli(intends_hunt ? 1 - error_rate : error_rate))(ω) ?
                hunt_stag : forage_safe
        end
        for t in eachindex(history.opponent)
    ])
    matches_actions = Variable(ω -> generated_actions(ω) == history.opponent)
    program_name = Variable(ω -> first(library[program_index(ω)]))
    program_name |ᶜ matches_actions
end

# ╔═╡ a9de7b65-7b08-414b-a123-03fa6a47a7ac
md"""
Each round has a separate
Bernoulli draw that can reverse the program's intended action. We use the same
`error_rate` when inferring the opponent's retention below.
"""

# ╔═╡ 2cb49427-1bf0-47ce-aaed-a346e6db7a10
md"""
Each posterior sample names one program. `posterior_hunt_probability` runs
those programs on the complete focal history; the fraction that predict
`hunt_stag` estimates the probability that the opponent's program intends to
hunt next. We use that intended-action prediction for the greedy choice;
the error rate lets inference tolerate observed actions that deviate from a
program's intended actions.
"""

# ╔═╡ 4b2f40e6-b16e-49bf-825c-c170f8a48f76
function posterior_hunt_probability(
    history::JointHistory,
    program_samples::AbstractVector{Symbol};
    library = stateful_library,
)
    isempty(program_samples) && throw(ArgumentError("program_samples must not be empty"))
    strategies = Dict(library)
    mean(strategies[name](history.focal) == hunt_stag for name in program_samples)
end

# ╔═╡ 4572b7ad-f23a-4c62-a8e5-a3e20b9996ac
function stateful_projection(
    history::JointHistory,
    program_samples::AbstractVector{Symbol};
    library = stateful_library,
)
    p_hunt = posterior_hunt_probability(
        history,
        program_samples;
        library = library,
    )
    (
        program_samples = program_samples,
        p_hunt = p_hunt,
        action = greedy_response(p_hunt),
    )
end

# ╔═╡ b49d72c6-f8c7-4b42-97dc-e3b8f64e47c0
program_samples_without_repair = randsample(stateful_posterior(history_without_repair; error_rate=error_rate), 500; alg=RejectionSample)

# ╔═╡ 2f5f6bca-83ae-4ed8-8c22-0a2b01ade7e5
viz(string.(program_samples_without_repair))

# ╔═╡ 24f1ff4e-e1d2-47f0-bac2-52660541e794
program_samples_after_repair = randsample(stateful_posterior(history_after_repair; error_rate=error_rate), 500; alg=RejectionSample)

# ╔═╡ 6c8ab301-2cae-4d02-94b9-2ddab860622c
viz(string.(program_samples_after_repair))

# ╔═╡ 966c93fd-74a3-4a27-8cd7-21361a8b56c7
md"""
With the starting repair history, most samples should name either `grim_trust`
or `repair_after_two`. Both explain the observed retaliation, but they disagree
about the next round: only `repair_after_two` treats the last two focal hunts as
repair. That disagreement is why we keep a distribution over programs.
"""

# ╔═╡ e65d0519-f5cf-4b82-9ddd-da434643bd22
stateful_without_repair = stateful_projection(
    history_without_repair,
    program_samples_without_repair,
)

# ╔═╡ e0036e15-5fd2-4c44-9dba-b73aa445a8f2
stateful_after_repair = stateful_projection(
    history_after_repair,
    program_samples_after_repair,
)

# ╔═╡ 7f60c12d-d4c4-422a-9225-37117904c3d8
predictions = [
    (
        history = history_without_repair.focal,
        stationary_p_hunt = stationary_without_repair.p_hunt,
        stationary_action = stationary_without_repair.action,
        stateful_p_hunt = stateful_without_repair.p_hunt,
        stateful_action = stateful_without_repair.action,
    ),
    (
        history = history_after_repair.focal,
        stationary_p_hunt = stationary_after_repair.p_hunt,
        stationary_action = stationary_after_repair.action,
        stateful_p_hunt = stateful_after_repair.p_hunt,
        stateful_action = stateful_after_repair.action,
    ),
]

# ╔═╡ 8f903022-d73f-451e-8f6b-7e157f0ec6ac
md"""
The stationary model sees the same opponent actions in both histories, so it
predicts ``p=2/5`` in both cases and the focal player hunts greedily.

The stateful model also asks what the focal player did. After focal actions
safe, safe, hunt, one hunt has not restored trust, and the posterior intended
hunt probability is about 0.006. After safe, hunt, hunt, the two-hunt repair
condition holds, and the probability rises to about 0.477. The displayed sample
estimates fluctuate around these values. With finite samples,
the smaller probability may appear as zero because none of the sampled programs
intends to hunt; increasing the sample count makes rare programs easier to see.
The richer representation keeps a distinction the count discarded: whether
the focal actions satisfy the repair rule.
"""

# ╔═╡ 5c9b6c7e-b23a-4631-b4f5-c82a6b69a001
md"""
## Opponent predictions determine the focal player's actions

The focal player uses the same `greedy_response` rule in every case: hunt when
the estimated opponent hunt probability exceeds ``1/4``, and forage otherwise.
Changing the opponent model can change that estimate and hence the chosen
action, even though the decision rule stays fixed.

The first plot shows the opponent predictions that enter the rule. The table
compares the resulting focal actions side by side for each history.
Because the rule is deterministic, each distribution puts all its mass on the
displayed action: its probability is one, and the other action's is zero.
We apply the rule to the posterior
mean, as above; we do not choose an action separately for each posterior sample.
"""

# ╔═╡ 5c9b6c7e-b23a-4631-b4f5-c82a6b69a002
focal_action_distributions = [
    (
        model = model,
        history = prediction.history,
        label = model * " | " * join(
            [action == hunt_stag ? "hunt" : "safe" for action in prediction.history],
            ", ",
        ),
        opponent_p_hunt = p_hunt,
        focal_action = action,
        p_forage_safe = Float64(action == forage_safe),
        p_hunt_stag = Float64(action == hunt_stag),
    )
    for prediction in predictions
    for (model, p_hunt, action) in (
        ("stationary", prediction.stationary_p_hunt, prediction.stationary_action),
        ("stateful", prediction.stateful_p_hunt, prediction.stateful_action),
    )
]

# ╔═╡ 5c9b6c7e-b23a-4631-b4f5-c82a6b69a003
opponent_prediction_plot = barplot(
    [row.label for row in focal_action_distributions],
    [row.opponent_p_hunt for row in focal_action_distributions];
    title = "Opponent hunt predictions (focal hunts above 0.25)",
    xlabel = "P(opponent hunts next)",
    maximum = 1.0,
    width = 45,
)

# ╔═╡ 5c9b6c7e-b23a-4631-b4f5-c82a6b69a004
conditional_focal_action_table = let
    action_label = action -> action == hunt_stag ? "Hunt" : "Forage safely"
    table_rows = [
        "| " * join(action_label.(prediction.history), " → ") *
        " | **" * action_label(prediction.stationary_action) *
        "** | **" * action_label(prediction.stateful_action) * "** |"
        for prediction in predictions
    ]
    Markdown.parse(
        "| Focal action history | Stationary model: next focal action | Stateful model: next focal action |\n" *
        "| :--- | :---: | :---: |\n" * join(table_rows, "\n"),
    )
end

# ╔═╡ 5c9b6c7e-b23a-4631-b4f5-c82a6b69a005
md"""
We can also compare action frequencies by giving the two example histories
equal weight. This weighting defines a distribution over histories, rather than adding
randomness to the decision rule. With the starting examples, the stationary
model makes the focal player hunt in both histories; the stateful model makes
it forage in the first and hunt in the second. The resulting hunt frequencies
are one and one half, respectively.

The final plot averages the conditional action distributions under this chosen
weighting. These are frequencies across our two examples, not estimates of
how often the focal player acts in a population of games. Both plots and the table
update with the predictions above; finite posterior samples can affect an
action if the estimated hunt probability crosses the decision threshold.
"""

# ╔═╡ 5c9b6c7e-b23a-4631-b4f5-c82a6b69a006
focal_action_frequencies = [
    (
        model = model,
        p_forage_safe = mean([row.p_forage_safe for row in focal_action_distributions if row.model == model]),
        p_hunt_stag = mean([row.p_hunt_stag for row in focal_action_distributions if row.model == model]),
    )
    for model in ("stationary", "stateful")
]

# ╔═╡ 5c9b6c7e-b23a-4631-b4f5-c82a6b69a007
focal_action_frequency_plot = barplot(
    [row.model * " -> " * action_name
        for row in focal_action_frequencies
        for action_name in ("safe", "hunt")],
    [probability
        for row in focal_action_frequencies
        for probability in (row.p_forage_safe, row.p_hunt_stag)];
    title = "Focal actions across equally weighted example histories",
    xlabel = "Action frequency",
    maximum = 1.0,
    width = 45,
)

# ╔═╡ 9cf79af0-8a07-4dd0-9d9d-2bf02738d42f
md"""
## Inferring a parameterised opponent policy

The strategy library supplied several complete programs. We now infer a
parameter within one program: how quickly the opponent's resentment fades.
This is ordinary inference, not an intervention on a fixed baseline.

The opponent hunts while its resentment is below a tolerance. After observing
the focal player's action, it retains a fraction of its resentment and adds
one if the focal player foraged. Resentment measures lingering loss of trust;
choosing the safe action is not necessarily a betrayal. `retention` controls
how long that choice matters. At tolerance 0.5 and retention 1, one safe action
prevents hunting forever, as in `grim_trust`; smaller values let resentment fade.

For a given retention and update rule, resentment represents the action history,
and the tolerance decodes it into the next intended action. These are the roles
that the count and its decoder played in Chapter 1, now for an order-dependent task.
"""

# ╔═╡ a4bb15c8-3bd0-45de-b938-7e0b5a92d5a0
decay_update(resentment, action, retention) =
    retention * resentment + (action == forage_safe)

# ╔═╡ 01035d77-5bf8-4016-b651-c129da768769
md"""
`replay` records resentment and the intended action before observing each round's
focal action, because moves are simultaneous. We assume an episode begins with
zero resentment and fix tolerance at 0.5 to isolate uncertainty about retention.
Neither value is learned here. Observations beginning midway through an episode
could require a prior over initial resentment too.
"""

# ╔═╡ 86212111-8a07-48c9-b70e-cb0ed2c840a4
function replay(other_actions::AbstractVector{Action};
    retention, tolerance = 0.5, update = decay_update)
    resentment = 0.0
    states = Float64[]
    actions = Action[]
    for action in other_actions
        push!(states, resentment)
        push!(actions, resentment < tolerance ? hunt_stag : forage_safe)
        resentment = update(resentment, action, retention)
    end
    (; states, actions, resentment,
       next_action = resentment < tolerance ? hunt_stag : forage_safe)
end

# ╔═╡ b9df9e28-e978-4aa7-9818-04b0e8ef3a61
md"""
## Learning retention from actions

Each candidate opponent policy takes the focal actions as input. We run it on
`observed_history.focal` and condition on `observed_history.opponent`. At round
`t`, the policy uses only earlier focal actions. It ignores the opponent's own
previous actions, although a richer policy could use them too.
"""

# ╔═╡ 88125fae-1051-4d64-8d64-e770810c9aca
observed_history = JointHistory(
    [hunt_stag, forage_safe, hunt_stag, hunt_stag, hunt_stag],
    [hunt_stag, hunt_stag, forage_safe, hunt_stag, hunt_stag],
)

# ╔═╡ 0acb1ed7-cb7f-4d73-840b-1f7f06ce3265
md"""
The opponent forages once after the focal player forages, then hunts again.
We give five retention values equal prior weight. One value is drawn for the
whole episode; resentment changes from round to round under that value.
"""

# ╔═╡ c7b47143-1b47-4156-92c6-776dec94d42d
retention_values = [0.0, 0.2, 0.5, 0.8, 0.9]

# ╔═╡ 757be270-e91b-42ee-9890-655ec85de796
prior = fill(1 / length(retention_values), length(retention_values))

# ╔═╡ 68b2e584-16e9-494f-b8fc-54424c772f67
retention_index = @~ Categorical(prior)

# ╔═╡ 32134d2e-3cf8-46dd-945e-7b3e984fb100
opponent_retention = Variable(ω -> retention_values[retention_index(ω)])

# ╔═╡ ae38562a-2230-4a3b-92b4-8e6d75c7e419
opponent_policy(focal_actions; tolerance = 0.5, update = decay_update) =
    Variable(ω -> replay(focal_actions;
        retention = opponent_retention(ω), tolerance = tolerance, update = update))

# ╔═╡ 363c97bb-39c2-452d-8261-553a944674ce
other_model = opponent_policy(observed_history.focal)

# ╔═╡ 44e3a3ec-182b-44d7-b3ec-69a3bbc52f68
md"""
`other_model` is a policy with uncertain retention. We add the same execution
error as in the strategy library, with a separate draw `(:action, t)` each round.
"""

# ╔═╡ 10c91bf2-619b-4861-9085-047365a832a8
generated_actions = Variable(ω -> [
    ((:action, t) ~ Bernoulli(action == hunt_stag ? 1 - error_rate : error_rate))(ω) ?
        hunt_stag : forage_safe
    for (t, action) in enumerate(other_model(ω).actions)
])

# ╔═╡ 366da59f-8ab3-4fc4-8195-f10ea5979437
md"""
We condition on the generated sequence matching `observed_history.opponent`.
The conditioned retention describes which parameter values explain these actions.
No part of the policy is replaced to perform this inference.
"""

# ╔═╡ df8ec9db-eccd-464e-be9e-d9fb02b284a0
matches_actions = Variable(ω -> generated_actions(ω) == observed_history.opponent)

# ╔═╡ eea86678-de6d-43b3-9d1c-29da3663fc14
posterior = opponent_retention |ᶜ matches_actions

# ╔═╡ c21f6097-ece8-4bcc-b147-84caaf178ced
retention_samples = randsample(posterior, 400; alg=RejectionSample)

# ╔═╡ fb1d88db-3efa-4457-90bb-bf28c0f15a8f
[(retention=ρ, prior_probability=prior[k],
  posterior_probability=count(==(ρ), retention_samples) / length(retention_samples))
 for (k, ρ) in enumerate(retention_values)]

# ╔═╡ cd6b7f5b-7160-40ca-8a80-f9a0a5cde696
md"""
At the starting settings, most posterior samples have retention 0.0 or 0.2.
Both explain the quick return to hunting and predict the same intended actions
on this history, so these observations cannot distinguish them.

Change the opponent actions to
`[hunt_stag, hunt_stag, forage_safe, forage_safe, forage_safe]` and inspect
which retentions gain weight. Keep both vectors the same length. Sample estimates
fluctuate; rejection sampling can become slow when a full trace is rare.
"""

# ╔═╡ 6510a10a-1c8e-46dc-8e6e-699f78ee7927
md"""
## Predicting actions on a new history

For each posterior retention sample, we run the policy on a new supplied
focal-action sequence. This is a new episode, starting at zero resentment.
We average opponent hunt probabilities, including the same execution error as
the inference model. These predictions are conditional on the supplied sequence;
we do not simulate two players responding to each other.
"""

# ╔═╡ e10eb093-304b-49ca-b89f-9a390c840031
new_focal_actions = [
    hunt_stag, forage_safe, forage_safe, hunt_stag,
    hunt_stag, hunt_stag, hunt_stag, hunt_stag,
]

# ╔═╡ 83681362-b6da-43b7-89e9-b1dc16bda2ac
observed_hunt_probability(action::Action) =
    action == hunt_stag ? 1 - error_rate : error_rate

# ╔═╡ ca177850-7235-46f3-b705-7e6b36324542
hunt_probabilities(retention, focal_actions; update = decay_update) =
    observed_hunt_probability.(replay(focal_actions; retention, update).actions)

# ╔═╡ abd8092b-844f-468b-b8ea-fc22a996751d
predicted_hunting = mean([
    hunt_probabilities(retention, new_focal_actions)
    for retention in retention_samples
])

# ╔═╡ dc964126-d2a9-4cd2-acfd-e5af25e90f68
[(round=t, focal_action=new_focal_actions[t], opponent_p_hunt=predicted_hunting[t])
 for t in eachindex(new_focal_actions)]

# ╔═╡ 7c3b744c-ea3c-4b41-90e7-9b74ee2415cb
md"""
At the starting settings, the inferred opponent usually resumes hunting around
round 5. No actions from this new episode enter the posterior, so assessing
these predictions would require new opponent observations. Unlike the earlier
library prediction of an intended action, these probabilities include execution error.
"""

# ╔═╡ 34aff97d-20a8-4228-86cf-652b0af13dcb
md"""
## Intervening on the focal player's next action

Return to the end of `observed_history`. The focal player can choose its next
action, but cannot set the opponent's retention. We ask: **how would the same
opponent respond if we hunted next, compared with foraging next?**

We reconstruct the opponent's current resentment from the recorded focal
actions under each possible retention. Both branches keep that past and
retention fixed. Chapter 6's `|ᵈ` operator replaces only the next focal action.
This is an intervention on an input to the opponent's policy, not a different
opponent fitted to different data.

The default next action comes from the same greedy rule used earlier. We force
each alternative to compare its consequences, then prescribe a hunt in the
following round in both branches. Because moves are simultaneous, changing
our next action cannot change the opponent's action in that round. It can
change resentment afterwards, and hence the opponent's action one round later.
"""

# ╔═╡ 89d21d8d-b031-4842-bf0d-0483b2fd70fe
current_opponent_p_hunt = mean([
    observed_hunt_probability(replay(observed_history.focal; retention).next_action)
    for retention in retention_samples
])

# ╔═╡ 3659e021-4210-4379-a959-a2954beeaaf1
planned_focal_action = Variable(ω -> greedy_response(current_opponent_p_hunt))

# ╔═╡ 83ed9751-879b-42d1-8968-6d5f0241ebd2
future_focal_actions = Variable(ω -> vcat(
    observed_history.focal, [planned_focal_action(ω), hunt_stag],
))

# ╔═╡ 224a23a4-e77f-401e-a3d6-fc7a6336a59d
future_opponent = Variable(ω -> opponent_policy(future_focal_actions(ω))(ω))

# ╔═╡ 48a58adb-363e-4c9c-afd3-397fa94203e9
after_focal_safe = future_opponent |ᵈ (planned_focal_action => forage_safe)

# ╔═╡ b750e2f3-932a-418d-8ac5-baab09f7e21f
after_focal_hunt = future_opponent |ᵈ (planned_focal_action => hunt_stag)

# ╔═╡ 53f28f84-885c-42fa-83c1-f8c97ad33800
paired_responses = Variable(ω -> (
    retention = opponent_retention(ω),
    safe = after_focal_safe(ω),
    hunt = after_focal_hunt(ω),
)) |ᶜ matches_actions

# ╔═╡ 0b045858-aae3-4ae3-ab07-7a20c074ea90
response_samples = randsample(paired_responses, 400; alg=RejectionSample)

# ╔═╡ 840f3ead-e51f-4577-b70e-b784e3906c89
md"""
Each `response_samples` entry evaluates both interventions in the same sampled
world: the same retention and observed past support both branches. Conditioning
uses only the recorded actions, which do not depend on `planned_focal_action`.
We average probabilities of future observed actions rather than drawing new
execution errors, so the comparison has no additional noise from future action draws.
"""

# ╔═╡ 94f12ee8-5d81-41f3-a8fd-218052f44e50
action_intervention_predictions = [
    (
        round = length(observed_history.focal) + offset,
        if_focal_forages_next = mean([
            observed_hunt_probability(sample.safe.actions[length(observed_history.focal) + offset])
            for sample in response_samples
        ]),
        if_focal_hunts_next = mean([
            observed_hunt_probability(sample.hunt.actions[length(observed_history.focal) + offset])
            for sample in response_samples
        ]),
    )
    for offset in 1:2
]

# ╔═╡ 820df746-12cc-485d-902a-b7bba4a41337
action_intervention_table = let
    rows = [
        "| " * string(row.round) * " | " *
        string(round(row.if_focal_forages_next; digits=3)) * " | " *
        string(round(row.if_focal_hunts_next; digits=3)) * " |"
        for row in action_intervention_predictions
    ]
    Markdown.parse(
        "| Opponent round | P(hunt) if we forage next | P(hunt) if we hunt next |\n" *
        "| :---: | :---: | :---: |\n" * join(rows, "\n"),
    )
end

# ╔═╡ 6b8431cb-6b4e-4aaa-b4f3-b624c830a001
md"""
With the starting history, both branches predict roughly 0.9 probability of an
opponent hunt in round 6. In round 7, foraging next lowers that probability to
0.1, while hunting next keeps it near 0.9. The effect travels through the
opponent's resentment; we never intervene on its action directly.

The round-6 expected immediate rewards are still 1 for foraging and approximately
``4\times0.9=3.6`` for hunting. The unchanged greedy rule therefore hunts. The
round-7 comparison reveals a later consequence that the greedy rule does not
evaluate. Computing a longer-term value would require a continuation policy
and a planning horizon.

This is a causal prediction under the supplied update rule. The short observed
history does not establish that real opponents use that mechanism. Testing it
would require choosing actions and observing subsequent responses.
"""

# ╔═╡ aa5ea0b8-0af0-43de-9ec3-fc28360965c4
md"""
## Comparing update rules

The earlier `repair_after_two` strategy can also be written as a countdown:
safe foraging sets the state to two, and each hunt reduces it by one. At
tolerance 0.5, two consecutive hunts restore hunting. This is an alternative
opponent hypothesis, not an intervention the focal player can impose.
"""

# ╔═╡ 0080c9fc-9e9a-4a68-bb86-4842321639bd
repair_update(remaining, action, retention) =
    action == hunt_stag ? max(0.0, remaining - 1) : 2.0

# ╔═╡ 28ca22c8-fe23-44e1-ba49-c6e7d0e48fbb
repair_model = opponent_policy(new_focal_actions; update=repair_update)

# ╔═╡ aabb5af8-c554-4baa-abec-167595238469
only(randsample(repair_model, 1))

# ╔═╡ b388db30-75fc-4bcf-b24e-e3784e5d3550
md"""
The repair model resumes hunting in round 6, after seeing hunts in rounds 4 and
5. Each safe action restarts the countdown. Its update keeps the `retention`
argument to fit the same interface but ignores it, so uncertainty about retention
has no effect on its actions. Try changing the reset value from `2.0` to `3.0`.
"""

# ╔═╡ 43df7d4c-ceb6-4c75-9f0f-a595b3090cda
md"""
Return to the original two histories. With the countdown update, the policy
predicts safe foraging next after safe, safe, hunt, and hunting after safe,
hunt, hunt. These are the predictions of `repair_after_two` from the library.
Selecting a strategy and selecting its update rule can express the same behaviour.
The library prediction averaged over uncertain strategies; this display fixes
the countdown rule and shows its intended next action.
"""

# ╔═╡ 484e1196-57c6-498e-a313-d8549df3d0bc
[(history=name,
  next_action=only(randsample(opponent_policy(history.focal; update=repair_update), 1)).next_action)
 for (name, history) in [
     (:history_without_repair, history_without_repair),
     (:history_after_repair, history_after_repair),
 ]]

# ╔═╡ 587471de-a298-4a40-8022-3b93878c88b1
md"""
## Discussion

Change only the focal actions in the two original histories. The stationary
model keeps its prediction; the strategy library can change its prediction.
Remove `repair_after_two` from the library. Can the remaining strategies still
express recovery after two hunts?

Inferring retention cannot discover a countdown mechanism. We supplied both
update rules; a larger model family could infer which one explains the actions.
As in Chapter 4, the model family limits what parameter inference can recover.

Inference asks which opponent policies explain the recorded actions.
Intervention asks how a fixed policy would respond to an action we choose.
These examples keep those questions separate. They infer opponent models and
predict responses to supplied histories; they do not learn a model of the
focal player's own behaviour.

Try a history where the opponent's response is uncertain, and inspect the
action interventions. Could a chosen focal action help distinguish the remaining
retentions or update rules, as the chosen coin setting did in Chapter 6?
What would a planner need to evaluate both information gained and future rewards?
"""

# ╔═╡ fc6e8750-762e-473f-819d-3165c44f4ea8
md"""
---
## References

This notebook is part of a tutorial series introducing the ideas in Yu (2026).

The Stag Hunt follows Skyrms (2004); `grim_trust` is a grim-trigger strategy
(Friedman, 1971). See Kleiman-Weiner et al. (2016) and the ProbMods chapter
*Social Cognition* for related work on Bayesian models of social interaction.

- Yu, A. J. (2026). *The Art of Making Problems Simple: A Theory of Intelligence*. PsyArXiv. [doi:10.31234/osf.io/pghzn_v3](https://doi.org/10.31234/osf.io/pghzn_v3)
- Tavares, Z., Koppel, J., Zhang, X., Das, R., & Solar-Lezama, A. (2021). A language for counterfactual generative models. *Proceedings of the 38th International Conference on Machine Learning*, PMLR 139, 10173–10182. [pdf](http://www.zenna.org/publications/causal.pdf)
- Skyrms, B. (2004). *The Stag Hunt and the Evolution of Social Structure*. Cambridge University Press.
- Friedman, J. W. (1971). A non-cooperative equilibrium for supergames. *The Review of Economic Studies*, 38(1), 1–12.
- Kleiman-Weiner, M., Ho, M. K., Austerweil, J. L., Littman, M. L., & Tenenbaum, J. B. (2016). Coordinate to cooperate or compete: Abstract goals and joint intentions in social interaction. *Proceedings of the 38th Annual Conference of the Cognitive Science Society*.
"""

# ╔═╡ Cell order:
# ╠═1ac95343-9d93-40cf-a495-1751114f10a7
# ╟─6d728a56-c1a2-4ae3-9c61-a06c9b47e498
# ╟─b8f8a187-e266-4c15-8ab6-7cc7f2db4aaa
# ╠═150ef3a1-522e-4a09-b771-44fc72819efb
# ╠═193a472f-0ba1-4feb-af05-88835145bf63
# ╠═3c7c071b-953d-4937-93ab-ed30fa29d005
# ╠═af664b72-2fc8-46da-9e6c-9fe8457da41b
# ╠═f7f75f76-6b40-487e-af41-42b9a0841cc0
# ╟─20ce487b-b1ff-41de-9b11-9010c37814a4
# ╟─0fb05915-859f-4b5e-9db7-0d751bf6fa98
# ╠═6d22f491-c1ea-4f5e-ae6c-34e66aa722c6
# ╠═64715e09-090d-4718-9a47-9d3ce04c1927
# ╟─0f09ccc9-aee1-4b73-a90f-5adf55c3e288
# ╠═44eef06a-9c47-448e-8ee4-f6dbc0a6c9d4
# ╠═a0a89a69-3d2b-4633-8d4d-6ffd90002063
# ╠═16b90f4d-a820-422e-9dfd-e37881e12ecf
# ╠═e4b50f2c-5989-4a52-a54a-52d14f345cd0
# ╟─76fabd04-ec95-4e7a-921c-dc7ec9784194
# ╠═456c6cdb-2cab-454c-91f7-bac047a5341f
# ╠═59a24ac0-6720-4a1f-a1db-71446a81215c
# ╟─70535c63-fda8-465a-93f1-da2698fe1a45
# ╠═0921a0d2-4042-4925-9a0d-dd8886f004ee
# ╠═7ae14849-8d09-43a4-b2d1-ded6201b6e25
# ╠═733c4148-1cf9-45a6-ac75-a37cc020ecd0
# ╠═3cdcd170-d003-4332-9e04-901e3ffd2a2d
# ╟─5e0c2a61-7d4b-4f2e-9c1a-3b8d6f0e2a47
# ╠═8b4f1d93-2c6e-4a07-b5d8-e19a7c3f6b20
# ╟─36ebdb45-7dd5-45be-b602-c9201718864a
# ╠═04b81687-d694-4e06-bafa-00d2a7111068
# ╠═e523ad30-163a-418b-a7a0-f7883fba3864
# ╠═607629b3-7edb-417f-a168-afdc1c808790
# ╠═b18e073c-6cd2-47ef-b8f9-a6a042420a2a
# ╠═5a244279-7ac6-443a-8cf5-b57268e8c8d7
# ╠═b2c542b2-d0fb-4323-a2d6-4cb69d4918b2
# ╠═970f10bd-10b4-4bdc-ad74-43c3b014dbb5
# ╟─a9de7b65-7b08-414b-a123-03fa6a47a7ac
# ╟─2cb49427-1bf0-47ce-aaed-a346e6db7a10
# ╠═4b2f40e6-b16e-49bf-825c-c170f8a48f76
# ╠═4572b7ad-f23a-4c62-a8e5-a3e20b9996ac
# ╠═b49d72c6-f8c7-4b42-97dc-e3b8f64e47c0
# ╠═2f5f6bca-83ae-4ed8-8c22-0a2b01ade7e5
# ╠═24f1ff4e-e1d2-47f0-bac2-52660541e794
# ╠═6c8ab301-2cae-4d02-94b9-2ddab860622c
# ╟─966c93fd-74a3-4a27-8cd7-21361a8b56c7
# ╠═e65d0519-f5cf-4b82-9ddd-da434643bd22
# ╠═e0036e15-5fd2-4c44-9dba-b73aa445a8f2
# ╠═7f60c12d-d4c4-422a-9225-37117904c3d8
# ╟─8f903022-d73f-451e-8f6b-7e157f0ec6ac
# ╟─5c9b6c7e-b23a-4631-b4f5-c82a6b69a001
# ╠═5c9b6c7e-b23a-4631-b4f5-c82a6b69a002
# ╠═5c9b6c7e-b23a-4631-b4f5-c82a6b69a003
# ╠═5c9b6c7e-b23a-4631-b4f5-c82a6b69a004
# ╟─5c9b6c7e-b23a-4631-b4f5-c82a6b69a005
# ╠═5c9b6c7e-b23a-4631-b4f5-c82a6b69a006
# ╠═5c9b6c7e-b23a-4631-b4f5-c82a6b69a007
# ╟─9cf79af0-8a07-4dd0-9d9d-2bf02738d42f
# ╠═a4bb15c8-3bd0-45de-b938-7e0b5a92d5a0
# ╟─01035d77-5bf8-4016-b651-c129da768769
# ╠═86212111-8a07-48c9-b70e-cb0ed2c840a4
# ╟─b9df9e28-e978-4aa7-9818-04b0e8ef3a61
# ╠═88125fae-1051-4d64-8d64-e770810c9aca
# ╟─0acb1ed7-cb7f-4d73-840b-1f7f06ce3265
# ╠═c7b47143-1b47-4156-92c6-776dec94d42d
# ╠═757be270-e91b-42ee-9890-655ec85de796
# ╠═68b2e584-16e9-494f-b8fc-54424c772f67
# ╠═32134d2e-3cf8-46dd-945e-7b3e984fb100
# ╠═ae38562a-2230-4a3b-92b4-8e6d75c7e419
# ╠═363c97bb-39c2-452d-8261-553a944674ce
# ╟─44e3a3ec-182b-44d7-b3ec-69a3bbc52f68
# ╠═10c91bf2-619b-4861-9085-047365a832a8
# ╟─366da59f-8ab3-4fc4-8195-f10ea5979437
# ╠═df8ec9db-eccd-464e-be9e-d9fb02b284a0
# ╠═eea86678-de6d-43b3-9d1c-29da3663fc14
# ╠═c21f6097-ece8-4bcc-b147-84caaf178ced
# ╠═fb1d88db-3efa-4457-90bb-bf28c0f15a8f
# ╟─cd6b7f5b-7160-40ca-8a80-f9a0a5cde696
# ╟─6510a10a-1c8e-46dc-8e6e-699f78ee7927
# ╠═e10eb093-304b-49ca-b89f-9a390c840031
# ╠═83681362-b6da-43b7-89e9-b1dc16bda2ac
# ╠═ca177850-7235-46f3-b705-7e6b36324542
# ╠═abd8092b-844f-468b-b8ea-fc22a996751d
# ╠═dc964126-d2a9-4cd2-acfd-e5af25e90f68
# ╟─7c3b744c-ea3c-4b41-90e7-9b74ee2415cb
# ╟─34aff97d-20a8-4228-86cf-652b0af13dcb
# ╠═89d21d8d-b031-4842-bf0d-0483b2fd70fe
# ╠═3659e021-4210-4379-a959-a2954beeaaf1
# ╠═83ed9751-879b-42d1-8968-6d5f0241ebd2
# ╠═224a23a4-e77f-401e-a3d6-fc7a6336a59d
# ╠═48a58adb-363e-4c9c-afd3-397fa94203e9
# ╠═b750e2f3-932a-418d-8ac5-baab09f7e21f
# ╠═53f28f84-885c-42fa-83c1-f8c97ad33800
# ╠═0b045858-aae3-4ae3-ab07-7a20c074ea90
# ╟─840f3ead-e51f-4577-b70e-b784e3906c89
# ╠═94f12ee8-5d81-41f3-a8fd-218052f44e50
# ╠═820df746-12cc-485d-902a-b7bba4a41337
# ╟─6b8431cb-6b4e-4aaa-b4f3-b624c830a001
# ╟─aa5ea0b8-0af0-43de-9ec3-fc28360965c4
# ╠═0080c9fc-9e9a-4a68-bb86-4842321639bd
# ╠═28ca22c8-fe23-44e1-ba49-c6e7d0e48fbb
# ╠═aabb5af8-c554-4baa-abec-167595238469
# ╟─b388db30-75fc-4bcf-b24e-e3784e5d3550
# ╟─43df7d4c-ceb6-4c75-9f0f-a595b3090cda
# ╠═484e1196-57c6-498e-a313-d8549df3d0bc
# ╟─587471de-a298-4a40-8022-3b93878c88b1
# ╟─fc6e8750-762e-473f-819d-3165c44f4ea8
