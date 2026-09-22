### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 1ac95343-9d93-40cf-a495-1751114f10a7
begin
    import Pkg
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
    using Omega, Distributions, OmegaExamples, UnicodePlots
end

# ╔═╡ 6d728a56-c1a2-4ae3-9c61-a06c9b47e498
md"""
# 7. Representation of policies in multi-agent settings

The preceding chapters treat a representation as a task-dependent compression
of possible worlds. This chapter applies that idea to another agent: a focal
agent compresses an interaction history by interpreting the opponent through
its own strategy language. The available strategies determine which behavioural
distinctions the focal agent can express.

The example uses an indefinitely repeated Stag Hunt. The finite histories below provide diagnostic inputs, not
complete episodes; no agent observes an ending round or remaining horizon.
"""

# ╔═╡ b8f8a187-e266-4c15-8ab6-7cc7f2db4aaa
md"""
## A greedy decision in Stag Hunt

Each player chooses `hunt_stag` or `forage_safe` simultaneously. Hunting pays
4 when the opponent also hunts and 0 otherwise. Foraging always pays 1. If the
focal agent predicts that the opponent hunts with probability ``p``, hunting
has expected immediate reward ``4p`` and foraging has reward 1. A greedy agent
therefore hunts exactly when ``p>1/4``; at equality it takes the safe action.
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
reward, and our rule chooses forage. Above 0.25 it hunts. Edit the probabilities
in the cell, then try changing the hunting reward from 4 to 2 in
`expected_immediate_reward`. How does the decision threshold move?
"""

# ╔═╡ 0fb05915-859f-4b5e-9db7-0d751bf6fa98
md"""
## Compression to a stationary strategy

The simple focal agent can execute only stationary mixed strategies
``\pi_q``: hunt with probability ``q``, independently of history. It reuses
that same one-parameter class to model the opponent. Omega places a uniform
``\operatorname{Beta}(1,1)`` prior on ``q``, generates the opponent's actions,
and conditions ``q`` on the observed trace. This posterior depends only on the
opponent's action counts. It cannot express whether the opponent responded to
the focal player's actions or whether earlier actions damaged or restored trust.
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
focal actions differ. The last two focal actions are hunts in `history_after_repair`.
Keep each player's vector the same length when editing these observations.
"""

# ╔═╡ 44eef06a-9c47-448e-8ee4-f6dbc0a6c9d4
stationary_hunt_rate = @~ Beta(1, 1)

# ╔═╡ a0a89a69-3d2b-4633-8d4d-6ffd90002063
stationary_opponent_action(event, ω) =
    (event ~ Bernoulli(stationary_hunt_rate(ω)))(ω)

# ╔═╡ 16b90f4d-a820-422e-9dfd-e37881e12ecf
stationary_opponent_trace(events) = manynth(stationary_opponent_action, 1:events)

# ╔═╡ e4b50f2c-5989-4a52-a54a-52d14f345cd0
function stationary_posterior(history::JointHistory)
    observed_actions = history.opponent .== hunt_stag
    matches_actions = Variable(ω ->
        stationary_opponent_trace(length(observed_actions))(ω) == observed_actions)
    stationary_hunt_rate |ᶜ matches_actions
end

# ╔═╡ 76fabd04-ec95-4e7a-921c-dc7ec9784194
md"""
`stationary_posterior` builds a conditional model. It generates one Boolean
per round with a shared hunt probability and conditions that probability on the
opponent's observed actions. `randsample` in the next cells draws possible values
of that probability; increasing 400 gives a steadier estimate but takes longer.
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
        representation = (
            hunts = count(==(hunt_stag), history.opponent),
            events = length(history.opponent),
        ),
        p_hunt = p_hunt,
        action = greedy_response(p_hunt),
    )
end

# ╔═╡ 59a24ac0-6720-4a1f-a1db-71446a81215c
stationary_samples_without_repair = randsample(stationary_posterior(history_without_repair), 400; alg=RejectionSample)

# ╔═╡ 3f45eb4d-6932-44d1-8390-98d3248d64f0
stationary_samples_after_repair = randsample(stationary_posterior(history_after_repair), 400; alg=RejectionSample)

# ╔═╡ 70535c63-fda8-465a-93f1-da2698fe1a45
md"""
The distributions should look similar. One hunt and two safe actions update
the uniform prior to a `Beta(2,3)` distribution, whose mean is 0.4. Permuting the
opponent's actions leaves that distribution unchanged. Add a hunt to both sides
of a history and see how the posterior shifts.
"""

# ╔═╡ 0921a0d2-4042-4925-9a0d-dd8886f004ee
viz(stationary_samples_without_repair)

# ╔═╡ b2b8c864-21db-4a95-9420-c9e8d420d6f5
viz(stationary_samples_after_repair)

# ╔═╡ 7ae14849-8d09-43a4-b2d1-ded6201b6e25
stationary_without_repair = stationary_projection(
    history_without_repair,
    stationary_samples_without_repair,
)

# ╔═╡ 733c4148-1cf9-45a6-ac75-a37cc020ecd0
stationary_after_repair = stationary_projection(
    history_after_repair,
    stationary_samples_after_repair,
)

# ╔═╡ 3cdcd170-d003-4332-9e04-901e3ffd2a2d
permuted_opponent_history = JointHistory(
    copy(history_without_repair.focal),
    [forage_safe, hunt_stag, forage_safe],
)

# ╔═╡ 2900a473-1edd-4131-83e8-16fb56d07d01
permuted_stationary_samples = randsample(stationary_posterior(permuted_opponent_history), 400; alg=RejectionSample)

# ╔═╡ 36ebdb45-7dd5-45be-b602-c9201718864a
md"""
## A stateful focal agent

The focal agent has four strategy programs. `always_hunt` and `always_safe`
ignore history. `grim_trust` treats one safe action as a permanent loss of
trust, while `repair_after_two` lets two consecutive hunts restore it.

To model the opponent, the focal agent runs its own programs with the player
roles swapped. It samples a program from a uniform categorical prior. The
program generates each opponent action with error probability 0.1, and then it
conditions the latent program on the observed actions. The resulting labels
name the focal agent's programs; they do not name the opponent's true type.
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

# ╔═╡ c13c01d2-a746-4c14-a177-7a2257b8321f
md"""
The stateful prior gives all four programs equal probability. Each program
predicts the opponent from the focal action history, while `error_rate` allows
occasional actions that disagree with that prediction. Conditioning retains
the programs that best explain the observed trace.
"""

# ╔═╡ 970f10bd-10b4-4bdc-ad74-43c3b014dbb5
function stateful_posterior(history::JointHistory; library=stateful_library, error_rate=0.1)
    program_index = @~ Categorical(fill(1 / length(library), length(library)))
    generated_actions = Variable(ω -> [
        begin
            strategy = last(library[program_index(ω)])
            intends_hunt = strategy(history.focal[1:t-1]) == hunt_stag
            ((:action, t) ~ Bernoulli(intends_hunt ? 1-error_rate : error_rate))(ω)
        end
        for t in eachindex(history.opponent)
    ])
    matches_actions = Variable(ω -> generated_actions(ω) == (history.opponent .== hunt_stag))
    program_name = Variable(ω -> first(library[program_index(ω)]))
    program_name |ᶜ matches_actions
end

# ╔═╡ a9de7b65-7b08-414b-a123-03fa6a47a7ac
md"""
A categorical draw selects one program for the whole history. At round `t`,
the chosen program sees `history.focal[1:t-1]`, so it cannot use the simultaneous
focal action before observing it. The Bernoulli draw allows a 0.1 chance of an
action opposite to the program's intention. Conditioning returns a distribution
over program names, which the next cells sample and display.

Try changing `error_rate` towards 0.5. The observed actions then become less
informative about which program generated them.
"""

# ╔═╡ 2cb49427-1bf0-47ce-aaed-a346e6db7a10
md"""
Each posterior sample names one program. `posterior_hunt_probability` runs
those programs on the complete focal history; the fraction that predict
`hunt_stag` estimates the probability that its program intends to hunt next. The examples below use that intended-action prediction for the greedy choice; the error rate in inference allows imperfect demonstrations.
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
program_samples_without_repair = randsample(stateful_posterior(history_without_repair), 400; alg=RejectionSample)

# ╔═╡ 24f1ff4e-e1d2-47f0-bac2-52660541e794
program_samples_after_repair = randsample(stateful_posterior(history_after_repair), 400; alg=RejectionSample)

# ╔═╡ 8a067f2a-3197-48ab-8f28-9c534dda7364
p_hunt_without_repair = posterior_hunt_probability(
    history_without_repair,
    program_samples_without_repair,
)

# ╔═╡ dc0b3666-d873-4c50-85a8-3aa846b72c2e
p_hunt_after_repair = posterior_hunt_probability(
    history_after_repair,
    program_samples_after_repair,
)

# ╔═╡ 6c8ab301-2cae-4d02-94b9-2ddab860622c
viz(string.(program_samples_after_repair))

# ╔═╡ e8ee9a8d-e010-4434-b010-1310b2970504
stateful_posterior_summary = [
    (
        program = name,
        probability = count(==(name), program_samples_after_repair) /
            length(program_samples_after_repair),
    )
    for name in first.(stateful_library)
]

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
        simple_p_hunt = stationary_without_repair.p_hunt,
        stateful_p_hunt = stateful_without_repair.p_hunt,
        stateful_action = stateful_without_repair.action,
    ),
    (
        history = history_after_repair.focal,
        simple_p_hunt = stationary_after_repair.p_hunt,
        stateful_p_hunt = stateful_after_repair.p_hunt,
        stateful_action = stateful_after_repair.action,
    ),
]

# ╔═╡ 8f903022-d73f-451e-8f6b-7e157f0ec6ac
md"""
The opponent takes the same actions in both histories: hunt, safe, safe. The
final joint action is also the same. The simple model therefore predicts
``p=2/5`` in both cases and hunts greedily.

The stateful model also asks what the focal agent did. After focal actions
safe, safe, hunt, one hunt has not restored trust, and the posterior intended
hunt probability is about 0.006. After safe, hunt, hunt, the two-hunt repair
condition holds, and the probability rises to about 0.477. The displayed sample estimates fluctuate around these values. With 400 draws,
the smaller probability may appear as zero because none of the sampled programs
intends to hunt; increasing the number of samples makes rare programs easier to see. The richer focal agent can make
this distinction because its own strategy language contains that contingency.
"""

# ╔═╡ 9cf79af0-8a07-4dd0-9d9d-2bf02738d42f
md"""
## Discussion

Try changing only the focal actions in the two histories. The stationary model
keeps the same prediction because it only counts opponent hunts. The stateful
model can change its prediction because its programs respond to the focal actions.

Remove `repair_after_two` from `stateful_library`, then rerun the inference.
Can the remaining programs still distinguish the histories? Add a rule that
repairs trust after a single hunt and inspect which programs gain posterior weight.
Keep `always_hunt` and `always_safe` available while experimenting so the model
can also explain behaviour that ignores the focal actions.

Both focal agents choose greedily from their predictions of the next round.
What additional predictions would they need to consider the effect of today's
action on later cooperation?
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
# ╠═3f45eb4d-6932-44d1-8390-98d3248d64f0
# ╟─70535c63-fda8-465a-93f1-da2698fe1a45
# ╠═0921a0d2-4042-4925-9a0d-dd8886f004ee
# ╠═b2b8c864-21db-4a95-9420-c9e8d420d6f5
# ╠═7ae14849-8d09-43a4-b2d1-ded6201b6e25
# ╠═733c4148-1cf9-45a6-ac75-a37cc020ecd0
# ╠═3cdcd170-d003-4332-9e04-901e3ffd2a2d
# ╠═2900a473-1edd-4131-83e8-16fb56d07d01
# ╟─36ebdb45-7dd5-45be-b602-c9201718864a
# ╠═04b81687-d694-4e06-bafa-00d2a7111068
# ╠═e523ad30-163a-418b-a7a0-f7883fba3864
# ╠═607629b3-7edb-417f-a168-afdc1c808790
# ╠═b18e073c-6cd2-47ef-b8f9-a6a042420a2a
# ╠═5a244279-7ac6-443a-8cf5-b57268e8c8d7
# ╟─c13c01d2-a746-4c14-a177-7a2257b8321f
# ╠═970f10bd-10b4-4bdc-ad74-43c3b014dbb5
# ╟─a9de7b65-7b08-414b-a123-03fa6a47a7ac
# ╟─2cb49427-1bf0-47ce-aaed-a346e6db7a10
# ╠═4b2f40e6-b16e-49bf-825c-c170f8a48f76
# ╠═4572b7ad-f23a-4c62-a8e5-a3e20b9996ac
# ╠═b49d72c6-f8c7-4b42-97dc-e3b8f64e47c0
# ╠═24f1ff4e-e1d2-47f0-bac2-52660541e794
# ╠═8a067f2a-3197-48ab-8f28-9c534dda7364
# ╠═dc0b3666-d873-4c50-85a8-3aa846b72c2e
# ╠═6c8ab301-2cae-4d02-94b9-2ddab860622c
# ╠═e8ee9a8d-e010-4434-b010-1310b2970504
# ╟─966c93fd-74a3-4a27-8cd7-21361a8b56c7
# ╠═e65d0519-f5cf-4b82-9ddd-da434643bd22
# ╠═e0036e15-5fd2-4c44-9dba-b73aa445a8f2
# ╠═7f60c12d-d4c4-422a-9225-37117904c3d8
# ╟─8f903022-d73f-451e-8f6b-7e157f0ec6ac
# ╟─9cf79af0-8a07-4dd0-9d9d-2bf02738d42f
