### A Pluto.jl notebook ###
# v0.18.1

using Markdown
using InteractiveUtils

# ╔═╡ c8bab010-6162-11ec-07f9-ef4b5f242a82
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    using Omega, Distributions, UnicodePlots, OmegaExamples
end

# ╔═╡ e9b1baa3-1f0b-410a-b945-293c19d02a8f
md"""
# Prologue: The performance characteristics of different algorithms
There are many different ways to sample from the same distribution, it is thus useful to separately think about the distributions we are building (including conditional distributions) and how we will sample from them. Indeed, in the last few chapters we have explored the dynamics of inference without worrying about the details of inference algorithms. The efficiency characteristics of different implementations of `randsample` can be very different, however, and this is important both practically and for motivating cognitive hypotheses at the level of algorithms (or psychological processes).

The “guess and check” method of rejection sampling is conceptually useful but is often not efficient: even if we are sure that our model can satisfy the condition, it will often take a very large number of samples to find computations that do so. To see this, let us explore the impact of `baserate` in our simple warm-up example:
"""

# ╔═╡ bb390f80-b3d5-4123-8576-9bcedf005042
baserate = 0.1

# ╔═╡ 27815642-3d3b-4687-b06a-ac9dc48aa05c
@timed let
		A = @~ Bernoulli(baserate)
		B = @~ Bernoulli(baserate)
		C = @~ Bernoulli(baserate)
		randsample(A |ᶜ (A +ₚ B +ₚ C >=ₚ 2), 100)
end

# ╔═╡ ae42cfc9-57cd-4b1f-b909-5e7aa948eb42
md"Even for this simple program, lowering the baserate by just one order of magnitude, to $0.01$, will make rejection sampling impractical."

# ╔═╡ 5533a337-c611-4ba5-a2f4-c092725c5757
md"""
There are many other algorithms and techniques for probabilistic inference, reviewed below. They each have their own performance characteristics. For instance, _Markov chain Monte Carlo_ inference approximates the posterior distribution via a random walk (described in detail below).
"""

# ╔═╡ 697034c7-8bdc-42b6-bf15-e2bea6be0919
@timed let
		A = @~ Bernoulli(baserate)
		B = @~ Bernoulli(baserate)
		C = @~ Bernoulli(baserate)
		randsample(A |ᶜ (A +ₚ B +ₚ C >=ₚ 2), 100, alg = MH)
end

# ╔═╡ 1f49b556-cb7e-4a36-b0aa-0009d22d0255
md"""
See what happens in the above inference as you lower the baserate. Unlike rejection sampling, inference will not slow down appreciably (but results will become less stable). Inference should also not slow down exponentially as the size of the state space is increased. This is an example of the kind of trade-offs that are common between different inference algorithms.

The varying performance characteristics of different algorithms for (approximate) inference mean that getting accurate results for complex models can depend on choosing the right algorithm (with the right parameters). In what follows we aim to gain some intuition for how and when algorithms work, without being exhaustive.
"""

# ╔═╡ 542a3458-731d-4326-944f-de2e519144a7
md"""
# Markov chain Monte Carlo (MCMC)
We have already seen that samples from a (conditional) distribution can be an effective way to represent the results of inference – when rejection sampling is feasible it is an excellent approach. Other methods have been developed to take _approximate_ samples from a conditional distribution. One popular method uses Markov chains.

## Markov chains as samplers
A Markov model (or _Markov chain_, as it is often called in the context of inference algorithms)is a stochastic (i.e., random) process that transitions between states. Here is a Markov chain:
"""

# ╔═╡ f561d04e-271c-44fc-b54c-c928f330e436
transition_probs = [[.48, .48, .02, .02], 
	[.48, .48, .02, .02], 
	[.02, .02, .48, .48], 
	[.02, .02, .48, .48]]

# ╔═╡ 767eba7d-5ca7-4038-8972-613f3378a1f5
transition(ω, i, state) = (i ~ Categorical(transition_probs[state]))(ω)

# ╔═╡ ea9255e9-dbb6-42da-842c-bf0566d571c3
chain(state, n, ω) = (n == 0) ? state : chain(transition(ω, n, state), n - 1, ω)

# ╔═╡ 0997ad05-ba17-406f-aa09-244e18d83c9a
md"State after $10$ steps:"

# ╔═╡ 1fe4f0eb-7f8f-42e9-92de-249375c202f0
viz(randsample(ω -> chain(1, 10, ω), 1000))

# ╔═╡ a2b395e0-c8e7-4857-aa1d-18f0bb38eb33
viz(randsample(ω -> chain(3, 10, ω), 1000))

# ╔═╡ 9333c3dc-8cb7-486c-89bd-9dd56596dec2
md"State after $25$ steps:"

# ╔═╡ bc4a5906-ee86-4b05-8fc3-e714c3bbe9f4
viz(randsample(ω -> chain(1, 25, ω), 1000))

# ╔═╡ 86ea9486-78c7-4d0e-bd1e-f160a4bc6d63
viz(randsample(ω -> chain(3, 25, ω), 1000))

# ╔═╡ 95e17891-8370-4544-9a1f-9fa7198cfd55
md"State after $50$ steps:"

# ╔═╡ 8992c00f-0703-4912-b339-54246a9ad422
viz(randsample(ω -> chain(1, 50, ω), 1000))

# ╔═╡ 177b1308-9a81-40cd-bdd9-0c005f0df7de
viz(randsample(ω -> chain(3, 50, ω), 1000))

# ╔═╡ 5e71e49f-6acd-42d0-88ef-8c144d0b5dd0
md"""
Notice that the distribution of states after only a few steps is highly influenced by the starting state. In the long run the distribution looks the same from any starting state: this long-run distribution is the called the _stable distribution_ (also known as _stationary distribution_). To define stationary distribution formally, let $p(x)$ be the target distribution, and let $π(x→x′)$ be the transition distribution (i.e. the transition function in the above program). Since the stationary distribution is characterized by not changing when the transition is applied we have a _balance condition_: $p(x′)=∑ₓp(x)π(x→x′)$. Note that the balance condition holds for the distribution as a whole—a single state can of course be moved by the transition.

For the chain above, the stable distribution is uniform—we have found a (fairly baroque!) way to sample from the uniform distribution on the states! We could have sampled from the uniform distribution using other Markov chains. For instance the following chain is more natural, since it transitions uniformly:
"""

# ╔═╡ 9ceba035-95d8-4c6b-9f7f-3d3805a4a6b0
transition_(ω, i, state) = (i ~ Categorical([0.25, 0.25, 0.25, 0.25]))(ω)

# ╔═╡ 38be68ad-5b88-4502-b781-0f1e9a6ff9b0
chain_(state, n, ω) = (n == 0) ? state : chain_(transition_(ω, n, state), n - 1, ω)

# ╔═╡ 094a6d14-12c9-4a1e-ac94-160c55735c4b
md"State after $10$ steps:"

# ╔═╡ b76dfe5e-06a1-405b-96d2-31595318e0fd
viz(randsample(ω -> chain_(1, 10, ω), 1000))

# ╔═╡ 7ad01364-e034-4048-a4af-3a80037d7292
viz(randsample(ω -> chain_(3, 10, ω), 1000))

# ╔═╡ 904f6a1e-7b90-49a4-b2c0-cf02d37624a1
md"State after $25$ steps:"

# ╔═╡ 1f2e3971-a92e-4541-8a9d-6da9ed5dd433
viz(randsample(ω -> chain_(1, 25, ω), 1000))

# ╔═╡ 54424781-d376-497e-ad9d-eed881407a06
viz(randsample(ω -> chain_(3, 25, ω), 1000))

# ╔═╡ 42bf50ca-7dfe-4726-ad51-93f66ef81574
md"State after $50$ steps:"

# ╔═╡ 5ade662a-f12b-4fac-bdf3-22393a4b0277
viz(randsample(ω -> chain_(1, 50, ω), 1000))

# ╔═╡ eba08575-cc43-4dda-a0ba-15065cbf9ea0
viz(randsample(ω -> chain_(3, 50, ω), 1000))

# ╔═╡ d2cfb0ac-9c93-4cf8-b423-bfbcae3d6be1
md"""
Notice that this chain converges much more quickly to the uniform distribution. (Edit the code to confirm to yourself that the chain converges to the stationary distribution after a single step.) The number of steps it takes for the distribution on states to reach the stable distribution (and hence lose traces of the starting state) is called the _burn-in time_. Thus, while we can use a Markov chain as a way to (approximately) sample from its stable distribution, the efficiency depends on burn-in time. While many Markov chains have the same stable distribution they can have very different burn-in times, and hence different efficiency.

The state space in our examples above involved a small number of states, but Markov chains can also be constructed over infinite state spaces. Here’s a chain over the integers:
"""

# ╔═╡ 9714abcc-bc9c-4ed9-a433-c617aab3383e
p = 0.7

# ╔═╡ c9c48250-f39f-47f7-91a2-9a3ccfef4f3f
function transition_int(ω, i, state, p)
	if state == 3
		return (i ~ Categorical([1 - 0.5 * (1 - p), 0.5 * (1 - p)]))(ω) + 2
	end
	return (i ~ Categorical([0.5, 0.5 - 0.5 * (1 - p), 0.5 * (1 - p)]))(ω) + state - 2
end

# ╔═╡ 752eb825-1a12-495a-a2fe-37c9a26a66e0
chain_int(state, n, p, ω) = (n == 0) ? state : 
	chain_int(transition_int(ω, n, state, p), n - 1, p, ω)

# ╔═╡ 9699e68b-8f15-444f-81e3-4ad1f7a7d4cc
let
	samples = randsample(ω -> chain_int(3, 250, p, ω), 5000)
	counts = map(i -> count(x -> x == i, samples), 3:10)
	probs = counts ./ sum(counts)
	barplot(3:10, probs)
end

# ╔═╡ 19f7b56d-bcfe-444b-99c0-3e369a448276
md"""
As we can see, this Markov chain has as its stationary distribution a geometric distribution conditioned to be greater than $2$. The Markov chain above _implements_ the inference below, in the sense that it specifies a way to sample from the required conditional distribution.
"""

# ╔═╡ 243a4ca7-732c-4181-bf45-e0449eeb3e6d
geometric(ω, p, i = 0) = (i ~ Bernoulli(p))(ω) ? 1 : (1 + geometric(ω, p, i + 1))

# ╔═╡ 417e23ed-56d5-41f8-a3f1-b81ef0b7a63a
mygeom = ω -> geometric(ω, p)

# ╔═╡ 4ea00086-cf2c-4f9f-b5c9-bcfd66baf955
post = mygeom |ᶜ (mygeom >ₚ 2)

# ╔═╡ 109015e9-891a-4f29-97c5-d0296e0c491b
let
	samples = randsample(post, 25000)
	counts = map(i -> count(x -> x == i, samples), sort(unique(samples)))
	probs = counts ./ sum(counts)
	barplot(sort(unique(samples)), probs)
end

# ╔═╡ 7e9fa7f0-365d-47f0-a349-cc94e60b931f
md"""
Markov chain Monte Carlo (MCMC) is an approximate inference method based on identifying a Markov chain whose stationary distribution matches the conditional distribution you’d like to estimate. If such a transition distribution can be identified, we simply run it forward to generate samples from the target distribution.

# Metropolis-Hastings
Fortunately, it turns out that for any given (conditional) distribution there are Markov chains with a matching stationary distribution. There are a number of methods for finding an appropriate Markov chain. One particularly common method is _Metropolis Hastings_ recipe.

To create the necessary transition function, we first create a proposal distribution, $q(x→x′)$, which does not need to have the target distribution as its stationary distribution, but should be easy to sample from (otherwise it will be unwieldy to use!). A common option for continuous state spaces is to sample a new state from a multivariate Gaussian centered on the current state. To turn a proposal distribution into a transition function with the right stationary distribution, we either accepting or reject the proposed transition with probability: $min(1, \frac{p(x′)q(x′→x)}{p(x)q(x→x′)})$. That is, we flip a coin with that probability: if it comes up heads our next state is $x’$, otherwise our next state is still $x$.

Such a transition function not only satisfies the balance condition, it actually satisfies a stronger condition, _detailed balance_. Specifically, $p(x)π(x→x′)=p(x′)π(x′→x)$. (To show that detailed balance implies balance, substitute the right-hand side of the detailed balance equation into the balance equation, replacing the summand, and then simplify.) It can be shown that the Metropolis-hastings algorithm gives a transition probability (i.e. $π(x→x′)$) that satisfies detailed balance and thus balance.

Note that in order to use this recipe we need to have a function that computes the target probability (not just one that samples from it) and the transition probability, but they need not be normalized (since the normalization terms will cancel).

We can use this recipe to construct a Markov chain for the conditioned geometric distribution, as above, by using a proposal distribution that is equally likely to propose one number higher or lower:
"""

# ╔═╡ f252680f-ea5d-4623-911d-3e04f976d2ae
# The target distribution (not normalized):
# prob = 0 if x condition is violated, otherwise proportional to geometric distribution
target_dist(x, p) = (x < 3) ? 0 : (p * ((1-p) ^ (x-1)))

# ╔═╡ 74d1c535-caae-4606-9bed-5438f64a6a44
# The MH recipe:
function accept(x1, x2, p, ω, i)
	prob = min(1, target_dist(x2, p)/target_dist(x1, p))
	return ((@uid, i) ~ Bernoulli(prob))(ω)
end

# ╔═╡ 0c3131b0-04a0-411d-940f-db5bf24966d0
# the MCMC loop:
function mcmc(state, iterations, p, ω)
	s = [state]
	for i in 2:iterations
		# here we're equally likely to propose x+1 or x-1
		proposed_state = (i ~ Bernoulli())(ω) ? (state - 1) : (state + 1)
  		state = accept(state, proposed_state, p, ω, i) ? proposed_state : state
		push!(s, state)
	end
	s
end

# ╔═╡ f48fb481-68b9-4c44-941b-13e3eaeb1a1c
let
	samples = randsample(ω -> mcmc(3, 10000, p, ω)) # mcmc for conditioned geometric
	counts = map(i -> count(x -> x == i, samples), sort(unique(samples)))
	probs = counts ./ sum(counts)
	barplot(sort(unique(samples)), probs)
end

# ╔═╡ 6edb1b62-0b18-4a05-b42b-c353243a5454
md"Note that the transition function that is automatically derived using the MH recipe is actually the same as the one we wrote by hand earlier."

# ╔═╡ Cell order:
# ╠═c8bab010-6162-11ec-07f9-ef4b5f242a82
# ╟─e9b1baa3-1f0b-410a-b945-293c19d02a8f
# ╠═bb390f80-b3d5-4123-8576-9bcedf005042
# ╠═27815642-3d3b-4687-b06a-ac9dc48aa05c
# ╟─ae42cfc9-57cd-4b1f-b909-5e7aa948eb42
# ╟─5533a337-c611-4ba5-a2f4-c092725c5757
# ╠═697034c7-8bdc-42b6-bf15-e2bea6be0919
# ╟─1f49b556-cb7e-4a36-b0aa-0009d22d0255
# ╟─542a3458-731d-4326-944f-de2e519144a7
# ╠═f561d04e-271c-44fc-b54c-c928f330e436
# ╠═767eba7d-5ca7-4038-8972-613f3378a1f5
# ╠═ea9255e9-dbb6-42da-842c-bf0566d571c3
# ╟─0997ad05-ba17-406f-aa09-244e18d83c9a
# ╠═1fe4f0eb-7f8f-42e9-92de-249375c202f0
# ╠═a2b395e0-c8e7-4857-aa1d-18f0bb38eb33
# ╟─9333c3dc-8cb7-486c-89bd-9dd56596dec2
# ╠═bc4a5906-ee86-4b05-8fc3-e714c3bbe9f4
# ╠═86ea9486-78c7-4d0e-bd1e-f160a4bc6d63
# ╟─95e17891-8370-4544-9a1f-9fa7198cfd55
# ╠═8992c00f-0703-4912-b339-54246a9ad422
# ╠═177b1308-9a81-40cd-bdd9-0c005f0df7de
# ╟─5e71e49f-6acd-42d0-88ef-8c144d0b5dd0
# ╠═9ceba035-95d8-4c6b-9f7f-3d3805a4a6b0
# ╠═38be68ad-5b88-4502-b781-0f1e9a6ff9b0
# ╟─094a6d14-12c9-4a1e-ac94-160c55735c4b
# ╠═b76dfe5e-06a1-405b-96d2-31595318e0fd
# ╠═7ad01364-e034-4048-a4af-3a80037d7292
# ╟─904f6a1e-7b90-49a4-b2c0-cf02d37624a1
# ╠═1f2e3971-a92e-4541-8a9d-6da9ed5dd433
# ╠═54424781-d376-497e-ad9d-eed881407a06
# ╟─42bf50ca-7dfe-4726-ad51-93f66ef81574
# ╠═5ade662a-f12b-4fac-bdf3-22393a4b0277
# ╠═eba08575-cc43-4dda-a0ba-15065cbf9ea0
# ╟─d2cfb0ac-9c93-4cf8-b423-bfbcae3d6be1
# ╠═9714abcc-bc9c-4ed9-a433-c617aab3383e
# ╠═c9c48250-f39f-47f7-91a2-9a3ccfef4f3f
# ╠═752eb825-1a12-495a-a2fe-37c9a26a66e0
# ╠═9699e68b-8f15-444f-81e3-4ad1f7a7d4cc
# ╟─19f7b56d-bcfe-444b-99c0-3e369a448276
# ╠═243a4ca7-732c-4181-bf45-e0449eeb3e6d
# ╠═417e23ed-56d5-41f8-a3f1-b81ef0b7a63a
# ╠═4ea00086-cf2c-4f9f-b5c9-bcfd66baf955
# ╠═109015e9-891a-4f29-97c5-d0296e0c491b
# ╟─7e9fa7f0-365d-47f0-a349-cc94e60b931f
# ╠═f252680f-ea5d-4623-911d-3e04f976d2ae
# ╠═74d1c535-caae-4606-9bed-5438f64a6a44
# ╠═0c3131b0-04a0-411d-940f-db5bf24966d0
# ╠═f48fb481-68b9-4c44-941b-13e3eaeb1a1c
# ╟─6edb1b62-0b18-4a05-b42b-c353243a5454
