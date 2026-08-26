### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils
using Test

# ╔═╡ 1ac95343-9d93-40cf-a495-1751114f10a7
begin
    import Pkg
    Pkg.activate(Base.current_project())
    using OmegaExamples
end

# ╔═╡ 6d728a56-c1a2-4ae3-9c61-a06c9b47e498
md"""
# Strategy-based abstraction in a repeated game

This notebook isolates one multi-agent idea: a focal agent can model an
opponent only through distinctions available in its own strategy language. The
earlier intelligence chapters introduce worlds, task-relative representations,
and quotient coordinates. The ProbMods notebooks introduce probabilistic
programming and inference in Omega.

The interaction is an indefinitely repeated Stag Hunt. The finite histories
below are diagnostic inputs, not complete episodes, and no agent observes an
ending round or remaining horizon.
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
## A simple focal agent

The simple focal agent can execute only stationary mixed strategies
``\pi_q``: hunt with probability ``q``, independently of history. It reuses
that same one-parameter class to model the opponent. With a uniform
``\operatorname{Beta}(1,1)`` prior, its posterior prediction depends only on
the opponent's action counts. It cannot express whether the opponent responded
to the focal player's actions or whether trust was lost and repaired.

We enumerate the tiny posterior below exactly. See *Worlds, Tasks, and
Representations* and the ProbMods notebooks for Omega's general conditioning
and inference machinery.
"""

# ╔═╡ 456c6cdb-2cab-454c-91f7-bac047a5341f
function stationary_prediction(
    history::JointHistory;
    alpha::Real = 1.0,
    beta::Real = 1.0,
)
    alpha > 0 || throw(ArgumentError("alpha must be positive"))
    beta > 0 || throw(ArgumentError("beta must be positive"))
    hunts = count(==(hunt_stag), history.opponent)
    float(alpha + hunts) / (alpha + beta + length(history.opponent))
end

# ╔═╡ b2b8c864-21db-4a95-9420-c9e8d420d6f5
function stationary_projection(history::JointHistory)
    p_hunt = stationary_prediction(history)
    (
        representation = (
            hunts = count(==(hunt_stag), history.opponent),
            events = length(history.opponent),
        ),
        p_hunt = p_hunt,
        action = greedy_response(p_hunt),
    )
end

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

# ╔═╡ 3cdcd170-d003-4332-9e04-901e3ffd2a2d
begin
    permuted_opponent_history = JointHistory(
        copy(history_without_repair.focal),
        [forage_safe, hunt_stag, forage_safe],
    )
    @assert stationary_prediction(permuted_opponent_history) == 2 / 5
    @test_throws ArgumentError JointHistory([hunt_stag], Action[])
    @test_throws ArgumentError greedy_response(1.1)
end

# ╔═╡ 36ebdb45-7dd5-45be-b602-c9201718864a
md"""
## A stateful focal agent

The richer focal agent can execute four small strategy programs. Two have
persistent state: `grim_trust` remembers any safe choice forever, whereas
`repair_after_two` restores trust only after two consecutive stag hunts. These
programs are not memory-one strategies.

To model the opponent, the focal agent runs its own programs with the player
roles swapped. It compares each program's predicted action with the observed
opponent action, using error probability 0.1, and normalises the four
likelihoods. The resulting labels name the focal agent's programs; they do not
name the opponent's true type.
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

# ╔═╡ a12d39b9-0b41-430d-b61c-0653619ae342
begin
    @assert grim_trust(Action[]) == hunt_stag
    @assert grim_trust([hunt_stag, forage_safe, hunt_stag]) == forage_safe
    @assert repair_after_two([forage_safe, hunt_stag]) == forage_safe
    @assert repair_after_two([forage_safe, hunt_stag, hunt_stag]) == hunt_stag
end

# ╔═╡ 6c8ab301-2cae-4d02-94b9-2ddab860622c
function program_likelihood(
    strategy,
    history::JointHistory;
    error_rate::Real = 0.1,
)
    0 < error_rate < 0.5 ||
        throw(ArgumentError("error_rate must lie strictly between 0 and 0.5"))
    prod(
        strategy(history.focal[1:t-1]) == history.opponent[t] ?
            1 - error_rate : error_rate
        for t in eachindex(history.opponent)
    )
end

# ╔═╡ e8ee9a8d-e010-4434-b010-1310b2970504
function stateful_posterior(
    history::JointHistory,
    library = stateful_library;
    error_rate::Real = 0.1,
)
    isempty(library) && throw(ArgumentError("library must not be empty"))
    weights = Dict(
        name => program_likelihood(strategy, history; error_rate = error_rate)
        for (name, strategy) in library
    )
    normalizer = sum(values(weights))
    isfinite(normalizer) && normalizer > 0 ||
        throw(ArgumentError("posterior weights are not normalisable"))
    Dict(name => weight / normalizer for (name, weight) in weights)
end

# ╔═╡ 4c318010-8be7-4c37-8208-9d3b0b7db0e8
function stateful_prediction(
    history::JointHistory,
    posterior::AbstractDict,
    library = stateful_library,
)
    prediction = sum(
        posterior[name] * (strategy(history.focal) == hunt_stag)
        for (name, strategy) in library
    )
    isfinite(prediction) && 0 <= prediction <= 1 ||
        throw(ArgumentError("posterior predictive probability is invalid"))
    prediction
end

# ╔═╡ 4572b7ad-f23a-4c62-a8e5-a3e20b9996ac
function stateful_projection(
    history::JointHistory;
    library = stateful_library,
    error_rate::Real = 0.1,
)
    posterior = stateful_posterior(history, library; error_rate = error_rate)
    p_hunt = stateful_prediction(history, posterior, library)
    (posterior = posterior, p_hunt = p_hunt, action = greedy_response(p_hunt))
end

# ╔═╡ e65d0519-f5cf-4b82-9ddd-da434643bd22
begin
    posterior_without_repair = stateful_posterior(history_without_repair)
    posterior_after_repair = stateful_posterior(history_after_repair)
    stateful_without_repair = stateful_projection(history_without_repair)
    stateful_after_repair = stateful_projection(history_after_repair)

    @assert isapprox(sum(values(posterior_without_repair)), 1.0)
    @assert isapprox(sum(values(posterior_after_repair)), 1.0)
    @assert isapprox(stateful_without_repair.p_hunt, 0.005813953488372093)
    @assert isapprox(stateful_after_repair.p_hunt, 0.47674418604651164)
    @assert stateful_without_repair.action == forage_safe
    @assert stateful_after_repair.action == hunt_stag
end

# ╔═╡ 7f60c12d-d4c4-422a-9225-37117904c3d8
diagnostic_results = [
    (
        history = "safe, safe, hunt",
        simple_p_hunt = stationary_prediction(history_without_repair),
        stateful_p_hunt = stateful_without_repair.p_hunt,
        stateful_action = stateful_without_repair.action,
    ),
    (
        history = "safe, hunt, hunt",
        simple_p_hunt = stationary_prediction(history_after_repair),
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
safe, safe, hunt, trust has not been repaired, and its hunt prediction is about
0.006. After safe, hunt, hunt, the two-hunt repair condition holds, and its
prediction rises to about 0.477. The richer focal agent can make this
distinction only because its own strategy language contains that contingency.
"""

# ╔═╡ b350b92f-1907-4518-a852-e15d19f53692
begin
    alternating_history = JointHistory(
        fill(hunt_stag, 4),
        [hunt_stag, forage_safe, hunt_stag, forage_safe],
    )
    alternating_projection = stateful_projection(alternating_history)

    @assert !haskey(alternating_projection.posterior, :alternator)
    @assert Set(keys(alternating_projection.posterior)) ==
        Set(first.(stateful_library))
    @assert isapprox(sum(values(alternating_projection.posterior)), 1.0)
end

# ╔═╡ 25a5295f-f81a-4816-9804-a3e88db19072
md"""
An opponent that alternates independently of the focal player is outside the
library. The focal agent does not invent an `alternator` type. It projects the
trace onto a posterior mixture of its four available programs. The posterior
gives the focal agent's description, not a recovered fact about the opponent.
"""

# ╔═╡ f04467fc-f576-4d4a-b0f5-e092482ed1fc
md"""
## A recursive ToM baseline

A classical comparison can nest models instead of projecting the opponent onto
the focal policy class. In this small level-``k`` baseline, level 0 supplies an
action distribution, level 1 best responds to level 0, and each higher level
best responds to the preceding level. The declared depth bounds the recursion.

This level hierarchy is one toy recursive ToM construction, not the unique
classical account.
In Stag Hunt, both mutual hunting and mutual foraging are stable coordination
outcomes. Recursion therefore remains dependent on its level-0 anchor and need
not produce a new action at every depth.
"""

# ╔═╡ 2fe362ec-7a62-44c7-8f40-bc5f813e1d50
function level_action_probability(level::Integer, level_zero_p_hunt::Real)
    0 <= level <= 10 || throw(ArgumentError("level must lie between 0 and 10"))
    0 <= level_zero_p_hunt <= 1 ||
        throw(ArgumentError("level_zero_p_hunt must lie in [0, 1]"))
    level == 0 && return float(level_zero_p_hunt)
    lower_level = level_action_probability(level - 1, level_zero_p_hunt)
    greedy_response(lower_level) == hunt_stag ? 1.0 : 0.0
end

# ╔═╡ 93fc32e5-8073-4699-bd00-f9147ac75157
function recursive_tom(
    depth::Integer;
    level_zero_p_hunt::Real = 0.2,
)
    1 <= depth <= 10 || throw(ArgumentError("depth must lie between 1 and 10"))
    opponent_p_hunt = level_action_probability(depth - 1, level_zero_p_hunt)
    (
        depth = depth,
        opponent_p_hunt = opponent_p_hunt,
        action = greedy_response(opponent_p_hunt),
    )
end

# ╔═╡ 2a2842c4-505d-4bf1-bc83-e59f90ae186f
begin
    @assert level_action_probability(0, 0.2) == 0.2
    @assert level_action_probability(1, 0.2) == 0.0
    @assert level_action_probability(2, 0.2) == 0.0
    @assert level_action_probability(1, 0.4) == 1.0
    @assert recursive_tom(2; level_zero_p_hunt = 0.2).action == forage_safe
    @test_throws ArgumentError recursive_tom(0)
    @test_throws ArgumentError recursive_tom(11)
end

# ╔═╡ 01bff82c-d5d8-4296-a681-1077c3c9f303
comparison = [
    (
        focal_agent = "stationary self-projector",
        opponent_representation = "posterior hunt rate",
        p_hunt = stationary_projection(history_after_repair).p_hunt,
        action = stationary_projection(history_after_repair).action,
        recursive = false,
    ),
    (
        focal_agent = "stateful self-projector",
        opponent_representation = "posterior over role-swapped self programs",
        p_hunt = stateful_projection(history_after_repair).p_hunt,
        action = stateful_projection(history_after_repair).action,
        recursive = false,
    ),
    (
        focal_agent = "level-2 recursive ToM baseline",
        opponent_representation = "level-1 model grounded at level 0",
        p_hunt = recursive_tom(2).opponent_p_hunt,
        action = recursive_tom(2).action,
        recursive = true,
    ),
]

# ╔═╡ 9cf79af0-8a07-4dd0-9d9d-2bf02738d42f
md"""
## What the example establishes

The two self-projectors use the same greedy response. Their difference lies in
what the focal agent can represent about another player. The stationary agent
retains an action rate. The stateful agent can additionally express persistent
trust and repair because those distinctions exist in its own executable
strategy language. The focal agent projects an opponent outside that language
onto the available programs instead of identifying a new type.

The level-``k`` baseline instead nests models. None of the three agents plans
over the indefinite future in this notebook. The example therefore isolates a
representational and reasoning distinction; it does not show that
self-projection is optimal, that a richer library is always better, or that a
learning procedure produced the supplied programs.
"""

# ╔═╡ 7ae14849-8d09-43a4-b2d1-ded6201b6e25
begin
    @assert stationary_prediction(history_without_repair) == 2 / 5
    @assert stationary_prediction(history_after_repair) == 2 / 5
    @assert stationary_projection(history_without_repair).action == hunt_stag
    @assert stationary_projection(history_after_repair).action == hunt_stag
end

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
# ╠═456c6cdb-2cab-454c-91f7-bac047a5341f
# ╠═b2b8c864-21db-4a95-9420-c9e8d420d6f5
# ╠═6d22f491-c1ea-4f5e-ae6c-34e66aa722c6
# ╠═7ae14849-8d09-43a4-b2d1-ded6201b6e25
# ╠═3cdcd170-d003-4332-9e04-901e3ffd2a2d
# ╟─36ebdb45-7dd5-45be-b602-c9201718864a
# ╠═04b81687-d694-4e06-bafa-00d2a7111068
# ╠═5a244279-7ac6-443a-8cf5-b57268e8c8d7
# ╠═a12d39b9-0b41-430d-b61c-0653619ae342
# ╠═6c8ab301-2cae-4d02-94b9-2ddab860622c
# ╠═e8ee9a8d-e010-4434-b010-1310b2970504
# ╠═4c318010-8be7-4c37-8208-9d3b0b7db0e8
# ╠═4572b7ad-f23a-4c62-a8e5-a3e20b9996ac
# ╠═e65d0519-f5cf-4b82-9ddd-da434643bd22
# ╠═7f60c12d-d4c4-422a-9225-37117904c3d8
# ╟─8f903022-d73f-451e-8f6b-7e157f0ec6ac
# ╠═b350b92f-1907-4518-a852-e15d19f53692
# ╟─25a5295f-f81a-4816-9804-a3e88db19072
# ╟─f04467fc-f576-4d4a-b0f5-e092482ed1fc
# ╠═2fe362ec-7a62-44c7-8f40-bc5f813e1d50
# ╠═93fc32e5-8073-4699-bd00-f9147ac75157
# ╠═2a2842c4-505d-4bf1-bc83-e59f90ae186f
# ╠═01bff82c-d5d8-4296-a681-1077c3c9f303
# ╟─9cf79af0-8a07-4dd0-9d9d-2bf02738d42f
