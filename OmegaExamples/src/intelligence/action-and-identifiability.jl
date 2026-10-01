### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 9eb323b2-fdbf-4737-8349-565c507d30ac
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

# ╔═╡ 8d0177aa-67e0-4e17-bc46-945a5d9460bd
md"""
# 6. Action and identifiability

Chapters 1–5 learned from observations the learner did not choose. This chapter
shows a case where no quantity of such observations is enough, but a single kind
of action is.

We compare two mechanisms that generate a pair of coin flips. Watching many
pairs cannot tell them apart, because they produce exactly the same distribution
of pairs. Setting the first flip by hand and watching the second can. The paper
makes the general point: when passive observation merges states that differ in
the structure a task depends on, finding a representation that supports control
may require acting on the world.
"""

# ╔═╡ b8c86269-aef9-457f-a2ea-025abf10beb5
md"""
## Two mechanisms

In each episode, you receive a coin and see two flips. The coin model's
parameters are the ones from Chapter 1.
"""

# ╔═╡ ec2dcb22-19a3-4a4d-b4af-479fe8a2f2b0
is_fair_prior = 0.5

# ╔═╡ 397890d1-6f60-4ddf-bebd-71398cb18834
fair_weight = 0.5

# ╔═╡ 38fb0a12-0814-4b4c-ad9d-c93f9a5ecd19
trick_weight = 0.85

# ╔═╡ 2e170979-0b4a-4b89-b309-309d0bc004f0
md"""
**The hidden coin.** This mechanism is Chapter 1's model: a friend picks a fair
or trick coin, and both flips come from it independently. The two flips are correlated
only because they share the coin.
"""

# ╔═╡ 81badfc5-eeea-4dec-8d74-72b255a69e8d
is_fair_coin = @~ Bernoulli(is_fair_prior)

# ╔═╡ 06bd70f1-a966-4105-b03b-edc20dfacc58
coin_weight = Variable(ω -> is_fair_coin(ω) ? fair_weight : trick_weight)

# ╔═╡ 6eb2afbf-fc82-4e22-abe9-b81e02906d57
hidden_first = Variable(ω -> ((:hidden, 1) ~ Bernoulli(coin_weight(ω)))(ω))

# ╔═╡ 2833f9fc-d2ca-47f6-a30d-20d8ca25cdc4
hidden_second = Variable(ω -> ((:hidden, 2) ~ Bernoulli(coin_weight(ω)))(ω))

# ╔═╡ 55546e65-677f-42fc-9f01-e78507a592b5
md"""
**The sticky coin.** A single coin lands heads with probability `marginal_heads`.
After the first flip, with probability `stickiness`, the second flip copies the
first; otherwise it is a fresh flip. Here the first flip causes the second.

We choose both numbers so that the sticky coin matches the hidden coin: the same
probability of heads on the first flip, and the same probability of two heads.
"""

# ╔═╡ c018c101-f508-401d-9f82-4f91d45f87c3
marginal_heads = is_fair_prior * fair_weight + (1 - is_fair_prior) * trick_weight

# ╔═╡ 65f6c45f-5f34-40df-a586-7aafa6ff1a8f
both_heads = is_fair_prior * fair_weight^2 + (1 - is_fair_prior) * trick_weight^2

# ╔═╡ 60f39171-826b-4e72-afd5-4ce3e83edf91
stickiness = both_heads / marginal_heads -
    (marginal_heads - both_heads) / (1 - marginal_heads)

# ╔═╡ cbe9e35e-65a3-4466-9445-22837d2d30c6
md"""
`stickiness` is the difference between the probability of heads on the second
flip after a head and after a tail, both under the hidden coin. At the starting
settings it is about 0.14.
"""

# ╔═╡ 94c0ceb4-d97b-48e1-b0d6-72e60113e13a
sticky_first = @~ Bernoulli(marginal_heads)

# ╔═╡ c008e337-985f-42ee-a672-b58ad7616786
copies_first = @~ Bernoulli(stickiness)

# ╔═╡ d0b4550f-664b-49dc-a833-1c94a91169df
fresh_flip = @~ Bernoulli(marginal_heads)

# ╔═╡ b3c1df93-f715-494c-8ac9-68b9719efa26
sticky_second = Variable(ω -> copies_first(ω) ? sticky_first(ω) : fresh_flip(ω))

# ╔═╡ e85b93cf-d615-4243-824c-ffa0959c895f
md"""
## Watching pairs

The next cells sample 2000 episodes from each mechanism and show the pairs.
"""

# ╔═╡ 808111d8-1d98-4b01-8d8e-0446fa51a0fe
show_pair(first, second) = string(first ? "H" : "T", second ? "H" : "T")

# ╔═╡ f1c9bdad-a3ce-46e3-9468-39ec31c963c5
hidden_pair = Variable(ω -> show_pair(hidden_first(ω), hidden_second(ω)))

# ╔═╡ 78406476-9f90-4722-af7d-1d36873df544
sticky_pair = Variable(ω -> show_pair(sticky_first(ω), sticky_second(ω)))

# ╔═╡ 2d873582-cd83-40ba-9f0c-fd9616dd6dca
viz(randsample(hidden_pair, 2000))

# ╔═╡ a03f4684-b6da-4f44-a118-cc5704043ace
viz(randsample(sticky_pair, 2000))

# ╔═╡ 5445a543-2840-4b13-a604-927095204d97
md"""
The two plots should look alike up to sampling noise. The next cell computes the
exact probability of each pair under both mechanisms.
"""

# ╔═╡ ac085438-4be4-42d2-a049-fb52c90717ff
function hidden_pair_probability(first, second)
    p(weight) = (first ? weight : 1 - weight) * (second ? weight : 1 - weight)
    is_fair_prior * p(fair_weight) + (1 - is_fair_prior) * p(trick_weight)
end

# ╔═╡ 480065e5-3426-4aaa-aadb-8b751e655160
function sticky_pair_probability(first, second)
    p_first = first ? marginal_heads : 1 - marginal_heads
    p_fresh = second ? marginal_heads : 1 - marginal_heads
    p_first * (stickiness * (first == second) + (1 - stickiness) * p_fresh)
end

# ╔═╡ 4e1560cc-da7b-4bea-8cdc-6e90f8e6ea4a
[(pair = show_pair(a, b),
  hidden_coin = hidden_pair_probability(a, b),
  sticky_coin = sticky_pair_probability(a, b))
 for a in (true, false) for b in (true, false)]

# ╔═╡ 3d8c56b8-49d6-42d6-854f-762eb3609bd4
md"""
The columns agree exactly, so any statistic of observed pairs has the same
distribution under both mechanisms and watching pairs can never favour one of
them. Conditioning does not help either: seeing a head first raises the
probability of a second head to the same value in both models.
"""

# ╔═╡ 657bd81b-ad7e-4eb5-986a-d0958a1154f1
(hidden_coin = mean(randsample(hidden_second |ᶜ hidden_first, 2000; alg = RejectionSample)),
 sticky_coin = mean(randsample(sticky_second |ᶜ sticky_first, 2000; alg = RejectionSample)),
 exact = both_heads / marginal_heads)

# ╔═╡ 5847ebe7-4f26-459b-9651-afde97d37686
md"""
## Setting the first flip

Now suppose you can place the first coin on the table heads up yourself, instead
of flipping it. In Omega, `|ᵈ` acts as the `do`-operator. `sticky_second |ᵈ (sticky_first => true)` asks
what the second flip would be if we set the first flip to heads.
"""

# ╔═╡ 15c319ba-ed96-4a4d-9df6-4a23e9bae798
intervention_samples = 4000

# ╔═╡ 34590d5c-23e1-4a92-8fa9-2e2fae6ca5c0
intervention_table = [
    (mechanism = name,
     set_heads = mean(randsample(second |ᵈ (first => true), intervention_samples)),
     set_tails = mean(randsample(second |ᵈ (first => false), intervention_samples)))
    for (name, first, second) in [
        (:hidden_coin, hidden_first, hidden_second),
        (:sticky_coin, sticky_first, sticky_second),
    ]
]

# ╔═╡ 5ff8d56f-dc36-4bd1-b634-c4ce1f44482f
md"""
Under the hidden coin, setting the first flip changes nothing. The second flip
does not depend on the first, so its probability of heads stays at
`marginal_heads`, about 0.675, whichever value we set. Setting the first flip
also cuts its link to the coin: an assigned head, unlike an observed one, says
nothing about which coin we hold.

Under the sticky coin, the second flip follows the first. Setting heads gives
about 0.72 and setting tails about 0.58, a difference equal to `stickiness`.

Try `trick_weight = 0.99`. Both mechanisms still match on pairs, but the gap
under intervention grows.
"""

# ╔═╡ 1331eb61-3d6c-49f9-b9ab-a72857de08fe
md"""
## Learning the mechanism

A learner does not know which mechanism it faces and gives each probability
one half. We generate episodes from the sticky coin and compare two learners.
The passive learner watches pairs. The active learner sets the first flip at
random in each episode and records the second.

Each episode uses a new coin, so episodes are independent.
"""

# ╔═╡ 7e3e36cf-1a5e-4a07-b1ba-ac091d66c1eb
true_mechanism = :sticky_coin

# ╔═╡ 35ea0917-daf3-4f54-9ab5-8bcaffa28541
episode_count = 500

# ╔═╡ 3865beab-1b36-4d31-9058-f57988a0b5c9
true_first, true_second = true_mechanism == :sticky_coin ?
    (sticky_first, sticky_second) : (hidden_first, hidden_second)

# ╔═╡ c08fb4ba-d9e8-4c7a-9193-d679f14ac0c8
passive_episodes = randsample(
    Variable(ω -> (true_first(ω), true_second(ω))), episode_count)

# ╔═╡ 5c91933c-ee79-4662-8dcc-51fe4ffa4d75
chosen_first_flips = rand(Bool, episode_count)

# ╔═╡ 6ba1c1ea-6c65-4457-9cbc-e4b483a5417e
active_episodes = [
    (chosen, only(randsample(true_second |ᵈ (true_first => chosen), 1)))
    for chosen in chosen_first_flips
]

# ╔═╡ 1c02a5b2-6856-4169-860c-e4654bb2cdd1
md"""
`controlled_probability` gives the probability of the second flip after we set
the first, under each mechanism. The hidden coin ignores the setting; the sticky
coin copies it with probability `stickiness`.
"""

# ╔═╡ 25e8666a-e6a7-4cbe-9da4-d81e4c574ba2
function controlled_probability(mechanism, chosen, second)
    p_fresh = second ? marginal_heads : 1 - marginal_heads
    mechanism == :hidden_coin ? p_fresh :
        stickiness * (chosen == second) + (1 - stickiness) * p_fresh
end

# ╔═╡ e873d80d-8892-4c50-9a77-b3930e2b1e7a
function sticky_posterior(log_ratios)
    log_odds = sum(log_ratios; init = 0.0)
    1 / (1 + exp(-log_odds))
end

# ╔═╡ e6b8c9a4-98d9-489c-95a1-c64cb3217faf
passive_log_ratios = [
    log(sticky_pair_probability(a, b)) - log(hidden_pair_probability(a, b))
    for (a, b) in passive_episodes
]

# ╔═╡ deda64ad-e29f-4fb1-b616-a6b1ad83ceae
active_log_ratios = [
    log(controlled_probability(:sticky_coin, a, b)) -
        log(controlled_probability(:hidden_coin, a, b))
    for (a, b) in active_episodes
]

# ╔═╡ 415d0b25-f741-46b8-9bae-b720e37326c2
episode_budgets = [0, 20, 100, episode_count]

# ╔═╡ 597c386b-814e-445d-950c-1c15e6a53a7a
[(episodes = k,
  passive_posterior_sticky = sticky_posterior(passive_log_ratios[1:k]),
  active_posterior_sticky = sticky_posterior(active_log_ratios[1:k]))
 for k in episode_budgets if k <= episode_count]

# ╔═╡ bb296f22-bc35-438b-9c2e-9e6a9ab5b84d
md"""
The passive posterior stays at 0.5 however many episodes it sees. Every pair has
the same probability under both mechanisms, so each log ratio is zero. The
active posterior moves towards the sticky coin, usually past 0.9 by the last
budget. Each intervention carries only a little evidence because `stickiness` is
small; raise `trick_weight` to see it converge faster.

Set `true_mechanism = :hidden_coin`. The active posterior now moves towards the
hidden coin, and the passive one still does not move.
"""

# ╔═╡ 9cd4ef97-ff10-46cf-95d1-9a1f101e6349
md"""
## Prediction and control

The two mechanisms are equivalent for one task and different for another. To
*predict* the second flip after seeing the first, the joint table of pairs is
enough, and passive data estimate it well. To *control* the second flip, for
example to make it land heads, you need to know whether setting the first flip
has any effect. Only the mechanism answers that question.

Chapter 1 described a representation by the distinctions it keeps. Passive
observation acts like a representation the learner cannot change: it keeps the
pair of flips and nothing else. The distinction between the two mechanisms is
not among the ones it keeps, because two different mechanisms produce the same
observations. No amount of passive data can add that distinction. The action here is a transformation the learner applies to the world: setting
the first flip. This helps distinguish between the mechanisms. 

## Discussion

Watch three flips per episode instead of two. Under the hidden coin, `HTH` and
`HHT` are equally likely. Are they under the sticky coin? What does your answer
say about when passive data are enough?

Set `trick_weight = fair_weight`. What happens to `stickiness`, and why do the
two mechanisms now agree under intervention as well?
"""

# ╔═╡ 02c40772-8c47-4c75-b21d-6ceb610f64d6
md"""
---
## References

This notebook is part of a tutorial series introducing the ideas in Yu (2026).

The hidden-coin mechanism is the coin model from ProbMods used in Chapter 1. Interventions use Omega's `|ᵈ` operator (Tavares et al., 2021), which implements the do-operator of Pearl (2009).

- Yu, A. J. (2026). *The Art of Making Problems Simple: A Theory of Intelligence*. PsyArXiv. [doi:10.31234/osf.io/pghzn_v3](https://doi.org/10.31234/osf.io/pghzn_v3)
- Goodman, N. D., Tenenbaum, J. B., & The ProbMods Contributors (2016). *Probabilistic Models of Cognition* (2nd ed.). [probmods.org](https://probmods.org/)
- Tavares, Z., Koppel, J., Zhang, X., Das, R., & Solar-Lezama, A. (2021). A language for counterfactual generative models. *Proceedings of the 38th International Conference on Machine Learning*, PMLR 139, 10173–10182. [pdf](http://www.zenna.org/publications/causal.pdf)
- Pearl, J. (2009). *Causality: Models, Reasoning, and Inference* (2nd ed.). Cambridge University Press.
- Held, R., & Hein, A. (1963). Movement-produced stimulation in the development of visually guided behavior. *Journal of Comparative and Physiological Psychology*, 56(5), 872–876.
"""

# ╔═╡ Cell order:
# ╠═9eb323b2-fdbf-4737-8349-565c507d30ac
# ╟─8d0177aa-67e0-4e17-bc46-945a5d9460bd
# ╟─b8c86269-aef9-457f-a2ea-025abf10beb5
# ╠═ec2dcb22-19a3-4a4d-b4af-479fe8a2f2b0
# ╠═397890d1-6f60-4ddf-bebd-71398cb18834
# ╠═38fb0a12-0814-4b4c-ad9d-c93f9a5ecd19
# ╟─2e170979-0b4a-4b89-b309-309d0bc004f0
# ╠═81badfc5-eeea-4dec-8d74-72b255a69e8d
# ╠═06bd70f1-a966-4105-b03b-edc20dfacc58
# ╠═6eb2afbf-fc82-4e22-abe9-b81e02906d57
# ╠═2833f9fc-d2ca-47f6-a30d-20d8ca25cdc4
# ╟─55546e65-677f-42fc-9f01-e78507a592b5
# ╠═c018c101-f508-401d-9f82-4f91d45f87c3
# ╠═65f6c45f-5f34-40df-a586-7aafa6ff1a8f
# ╠═60f39171-826b-4e72-afd5-4ce3e83edf91
# ╟─cbe9e35e-65a3-4466-9445-22837d2d30c6
# ╠═94c0ceb4-d97b-48e1-b0d6-72e60113e13a
# ╠═c008e337-985f-42ee-a672-b58ad7616786
# ╠═d0b4550f-664b-49dc-a833-1c94a91169df
# ╠═b3c1df93-f715-494c-8ac9-68b9719efa26
# ╟─e85b93cf-d615-4243-824c-ffa0959c895f
# ╠═808111d8-1d98-4b01-8d8e-0446fa51a0fe
# ╠═f1c9bdad-a3ce-46e3-9468-39ec31c963c5
# ╠═78406476-9f90-4722-af7d-1d36873df544
# ╠═2d873582-cd83-40ba-9f0c-fd9616dd6dca
# ╠═a03f4684-b6da-4f44-a118-cc5704043ace
# ╟─5445a543-2840-4b13-a604-927095204d97
# ╠═ac085438-4be4-42d2-a049-fb52c90717ff
# ╠═480065e5-3426-4aaa-aadb-8b751e655160
# ╠═4e1560cc-da7b-4bea-8cdc-6e90f8e6ea4a
# ╟─3d8c56b8-49d6-42d6-854f-762eb3609bd4
# ╠═657bd81b-ad7e-4eb5-986a-d0958a1154f1
# ╟─5847ebe7-4f26-459b-9651-afde97d37686
# ╠═15c319ba-ed96-4a4d-9df6-4a23e9bae798
# ╠═34590d5c-23e1-4a92-8fa9-2e2fae6ca5c0
# ╟─5ff8d56f-dc36-4bd1-b634-c4ce1f44482f
# ╟─1331eb61-3d6c-49f9-b9ab-a72857de08fe
# ╠═7e3e36cf-1a5e-4a07-b1ba-ac091d66c1eb
# ╠═35ea0917-daf3-4f54-9ab5-8bcaffa28541
# ╠═3865beab-1b36-4d31-9058-f57988a0b5c9
# ╠═c08fb4ba-d9e8-4c7a-9193-d679f14ac0c8
# ╠═5c91933c-ee79-4662-8dcc-51fe4ffa4d75
# ╠═6ba1c1ea-6c65-4457-9cbc-e4b483a5417e
# ╟─1c02a5b2-6856-4169-860c-e4654bb2cdd1
# ╠═25e8666a-e6a7-4cbe-9da4-d81e4c574ba2
# ╠═e873d80d-8892-4c50-9a77-b3930e2b1e7a
# ╠═e6b8c9a4-98d9-489c-95a1-c64cb3217faf
# ╠═deda64ad-e29f-4fb1-b616-a6b1ad83ceae
# ╠═415d0b25-f741-46b8-9bae-b720e37326c2
# ╠═597c386b-814e-445d-950c-1c15e6a53a7a
# ╟─bb296f22-bc35-438b-9c2e-9e6a9ab5b84d
# ╟─9cd4ef97-ff10-46cf-95d1-9a1f101e6349
# ╟─02c40772-8c47-4c75-b21d-6ceb610f64d6
