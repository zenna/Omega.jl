### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 1ac95343-9d93-40cf-a495-1751114f10a7
begin
    import Pkg
    Pkg.activate(Base.current_project())
    using Omega, Distributions, OmegaExamples, UnicodePlots
end

# ╔═╡ 6d728a56-c1a2-4ae3-9c61-a06c9b47e498
md"""
# 7. Strategy-based compression

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

# ╔═╡ 447539c0-6a26-4cb7-861f-ec5ea6682461
begin
    @assert greedy_response(0.24) == forage_safe
    @assert greedy_response(0.25) == forage_safe
    @assert greedy_response(0.26) == hunt_stag
end

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
begin
    history_without_repair = JointHistory(
        [forage_safe, forage_safe, hunt_stag],
        [hunt_stag, forage_safe, forage_safe],
    )
    history_after_repair = JointHistory(
        [forage_safe, hunt_stag, hunt_stag],
        [hunt_stag, forage_safe, forage_safe],
    )
end

# ╔═╡ 44eef06a-9c47-448e-8ee4-f6dbc0a6c9d4
begin
    stationary_hunt_rate = @~ Beta(1, 1)

    stationary_opponent_action(event, ω) =
        (event ~ Bernoulli(stationary_hunt_rate(ω)))(ω)

    stationary_opponent_trace(events) = manynth(stationary_opponent_action, 1:events)
end

# ╔═╡ e4b50f2c-5989-4a52-a54a-52d14f345cd0
function stationary_posterior(
    history::JointHistory;
    sample_count::Integer = 5_000,
)
    sample_count > 0 || throw(ArgumentError("sample_count must be positive"))
    observed_actions = history.opponent .== hunt_stag
    observation = Variable(ω ->
        stationary_opponent_trace(length(observed_actions))(ω) == observed_actions
    )
    randsample(
        stationary_hunt_rate |ᶜ observation,
        sample_count;
        alg = RejectionSample,
    )
end

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
begin
    stationary_samples_without_repair = stationary_posterior(
        history_without_repair;
        sample_count = 2_000,
    )
    stationary_samples_after_repair = stationary_posterior(
        history_after_repair;
        sample_count = 2_000,
    )

    @assert length(stationary_samples_without_repair) == 2_000
    @assert all(0 .<= stationary_samples_without_repair .<= 1)
    @assert isapprox(mean(stationary_samples_without_repair), 2 / 5; atol = 0.04)
    @assert isapprox(mean(stationary_samples_after_repair), 2 / 5; atol = 0.04)
end

# ╔═╡ 0921a0d2-4042-4925-9a0d-dd8886f004ee
viz(stationary_samples_without_repair)

# ╔═╡ b2b8c864-21db-4a95-9420-c9e8d420d6f5
viz(stationary_samples_after_repair)

# ╔═╡ 7ae14849-8d09-43a4-b2d1-ded6201b6e25
begin
    stationary_without_repair = stationary_projection(
        history_without_repair,
        stationary_samples_without_repair,
    )
    stationary_after_repair = stationary_projection(
        history_after_repair,
        stationary_samples_after_repair,
    )
    @assert stationary_without_repair.action == hunt_stag
    @assert stationary_after_repair.action == hunt_stag
end

# ╔═╡ 3cdcd170-d003-4332-9e04-901e3ffd2a2d
begin
    permuted_opponent_history = JointHistory(
        copy(history_without_repair.focal),
        [forage_safe, hunt_stag, forage_safe],
    )
    permuted_stationary_samples = stationary_posterior(
        permuted_opponent_history;
        sample_count = 2_000,
    )
    @assert isapprox(mean(permuted_stationary_samples), 2 / 5; atol = 0.04)
end

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
begin
    always_hunt(other_actions::AbstractVector{Action}) = hunt_stag
    always_safe(other_actions::AbstractVector{Action}) = forage_safe

    grim_trust(other_actions::AbstractVector{Action}) =
        forage_safe in other_actions ? forage_safe : hunt_stag

    function repair_after_two(other_actions::AbstractVector{Action})
        forage_safe in other_actions || return hunt_stag
        repaired = length(other_actions) >= 2 &&
            other_actions[end - 1:end] == [hunt_stag, hunt_stag]
        repaired ? hunt_stag : forage_safe
    end
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
function stateful_posterior(
    history::JointHistory;
    library = stateful_library,
    error_rate::Real = 0.1,
    sample_count::Integer = 5_000,
)
    isempty(library) && throw(ArgumentError("library must not be empty"))
    sample_count > 0 || throw(ArgumentError("sample_count must be positive"))

    program_index = @~ Categorical(fill(1 / length(library), length(library)))
    generated_actions = Variable(ω -> [
        begin
            strategy = last(library[program_index(ω)])
            intends_hunt = strategy(history.focal[1:event-1]) == hunt_stag
            ((:stateful_observation, event) ~ Bernoulli(
                intends_hunt ? 1 - error_rate : error_rate,
            ))(ω)
        end
        for event in eachindex(history.opponent)
    ])
    observed_actions = history.opponent .== hunt_stag
    observation = Variable(ω -> generated_actions(ω) == observed_actions)
    program_samples = randsample(
        program_index |ᶜ observation,
        sample_count;
        alg = RejectionSample,
    )
    first.(library[program_samples])
end

# ╔═╡ 2cb49427-1bf0-47ce-aaed-a346e6db7a10
md"""
Each posterior sample names one program. `posterior_hunt_probability` runs
those programs on the complete focal history; the fraction that predict
`hunt_stag` estimates the opponent's next-action probability.
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

# ╔═╡ 74842b92-4c4a-4750-8878-4ab8adb4acd9
md"""
The assertions check that inference stays within the supplied program library,
that the Monte Carlo estimates remain near their analytic values, and that the
two histories lead to opposite greedy actions.
"""

# ╔═╡ b49d72c6-f8c7-4b42-97dc-e3b8f64e47c0
begin
    program_samples_without_repair = stateful_posterior(
        history_without_repair;
        sample_count = 5_000,
    )
    program_samples_after_repair = stateful_posterior(
        history_after_repair;
        sample_count = 5_000,
    )
    p_hunt_without_repair = posterior_hunt_probability(
        history_without_repair,
        program_samples_without_repair,
    )
    p_hunt_after_repair = posterior_hunt_probability(
        history_after_repair,
        program_samples_after_repair,
    )

    @assert Set(program_samples_without_repair) ⊆ Set(first.(stateful_library))
    @assert isapprox(p_hunt_without_repair, 0.0058; atol = 0.02)
    @assert isapprox(p_hunt_after_repair, 0.4767; atol = 0.04)
    @assert greedy_response(p_hunt_without_repair) == forage_safe
    @assert greedy_response(p_hunt_after_repair) == hunt_stag
end

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

# ╔═╡ a12d39b9-0b41-430d-b61c-0653619ae342
begin
    @assert grim_trust(Action[]) == hunt_stag
    @assert grim_trust([hunt_stag, forage_safe, hunt_stag]) == forage_safe
    @assert repair_after_two([forage_safe, hunt_stag]) == forage_safe
    @assert repair_after_two([forage_safe, hunt_stag, hunt_stag]) == hunt_stag
end

# ╔═╡ e65d0519-f5cf-4b82-9ddd-da434643bd22
begin
    stateful_without_repair = stateful_projection(
        history_without_repair,
        program_samples_without_repair,
    )
    stateful_after_repair = stateful_projection(
        history_after_repair,
        program_samples_after_repair,
    )

    @assert stateful_without_repair.action == forage_safe
    @assert stateful_after_repair.action == hunt_stag
end

# ╔═╡ 7f60c12d-d4c4-422a-9225-37117904c3d8
diagnostic_results = [
    (
        history = "safe, safe, hunt",
        simple_p_hunt = stationary_without_repair.p_hunt,
        stateful_p_hunt = stateful_without_repair.p_hunt,
        stateful_action = stateful_without_repair.action,
    ),
    (
        history = "safe, hunt, hunt",
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
safe, safe, hunt, one hunt has not restored trust, and the posterior predictive
hunt probability is about 0.006. After safe, hunt, hunt, the two-hunt repair
condition holds, and the probability rises to about 0.477. The displayed Monte
Carlo estimates fluctuate around these values. The richer focal agent can make
this distinction because its own strategy language contains that contingency.
"""

# ╔═╡ 9cf79af0-8a07-4dd0-9d9d-2bf02738d42f
md"""
## What the example establishes

The two self-projectors use the same greedy response. Their difference lies in
what the focal agent can represent about another player. The stationary agent
retains an action rate. The stateful agent can additionally express persistent
trust and repair because those distinctions exist in its own executable
strategy language. The focal agent projects an opponent outside that language
onto the available programs and does not identify a new type.

Neither of the agents plans over the
indefinite future in this notebook. The example therefore isolates a
representational and reasoning distinction; it does not show that self-projection
is optimal, that a richer library is always better, or that a learning procedure
produced the supplied programs.
"""

# ╔═╡ Cell order:
# ╠═1ac95343-9d93-40cf-a495-1751114f10a7
# ╟─6d728a56-c1a2-4ae3-9c61-a06c9b47e498
# ╟─b8f8a187-e266-4c15-8ab6-7cc7f2db4aaa
# ╠═150ef3a1-522e-4a09-b771-44fc72819efb
# ╠═193a472f-0ba1-4feb-af05-88835145bf63
# ╠═3c7c071b-953d-4937-93ab-ed30fa29d005
# ╠═af664b72-2fc8-46da-9e6c-9fe8457da41b
# ╠═447539c0-6a26-4cb7-861f-ec5ea6682461
# ╟─0fb05915-859f-4b5e-9db7-0d751bf6fa98
# ╠═6d22f491-c1ea-4f5e-ae6c-34e66aa722c6
# ╠═44eef06a-9c47-448e-8ee4-f6dbc0a6c9d4
# ╠═e4b50f2c-5989-4a52-a54a-52d14f345cd0
# ╠═456c6cdb-2cab-454c-91f7-bac047a5341f
# ╠═59a24ac0-6720-4a1f-a1db-71446a81215c
# ╠═0921a0d2-4042-4925-9a0d-dd8886f004ee
# ╠═b2b8c864-21db-4a95-9420-c9e8d420d6f5
# ╠═7ae14849-8d09-43a4-b2d1-ded6201b6e25
# ╠═3cdcd170-d003-4332-9e04-901e3ffd2a2d
# ╟─36ebdb45-7dd5-45be-b602-c9201718864a
# ╠═04b81687-d694-4e06-bafa-00d2a7111068
# ╠═5a244279-7ac6-443a-8cf5-b57268e8c8d7
# ╟─c13c01d2-a746-4c14-a177-7a2257b8321f
# ╠═970f10bd-10b4-4bdc-ad74-43c3b014dbb5
# ╟─2cb49427-1bf0-47ce-aaed-a346e6db7a10
# ╠═4b2f40e6-b16e-49bf-825c-c170f8a48f76
# ╠═4572b7ad-f23a-4c62-a8e5-a3e20b9996ac
# ╟─74842b92-4c4a-4750-8878-4ab8adb4acd9
# ╠═b49d72c6-f8c7-4b42-97dc-e3b8f64e47c0
# ╠═6c8ab301-2cae-4d02-94b9-2ddab860622c
# ╠═e8ee9a8d-e010-4434-b010-1310b2970504
# ╠═a12d39b9-0b41-430d-b61c-0653619ae342
# ╠═e65d0519-f5cf-4b82-9ddd-da434643bd22
# ╠═7f60c12d-d4c4-422a-9225-37117904c3d8
# ╟─8f903022-d73f-451e-8f6b-7e157f0ec6ac
# ╟─9cf79af0-8a07-4dd0-9d9d-2bf02738d42f
