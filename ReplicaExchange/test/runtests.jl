using Test

using OmegaMH
using ReplicaExchange
using Distributions
using Random

# FIXME, and rename
# rescale(l, t) = exp(l, t)

# function custom_proposal(rng = MersenneTwister(0),  nreplicas = 4)
#   m2 = MixtureModel(
# 	  [MvNormal([0.9, 0.0], [0.3, 0.2]),
# 	   MvNormal([2.0, 3.0], [0.3, 0.4]),
# 	   MvNormal([-2.0, -1.0], [0.25, 0.33])],
# 	  [0.5, 0.3, 0.2]);
#   # nreplicas initial start states
#   ωinits = [((x_, ϵ_) = rand(2); (x = x_, ϵ = ϵ_, y = x_ + ϵ_)) for _ = 1:nreplicas]

#   # Create one temperature for each replica
#   logtemps(n, k) = exp.(k * range(-2.0, stop = 1.0, length = n))
#   ctxs = logtemps(nreplicas)

#   function somefunc(alg, temp, ωinit)
#     let ℓ(ω) = logenergy(ω, temp)
#       mh!(rng, ℓ, y, 10000, ωinit, CustomProp(prop))
#     end
#   end

# end

# Gaussian drift proposal
function propose_and_logratio(rng, state)
	prop_dist = MvNormal(state, [0.1, 0.1])
	sample = rand(rng, prop_dist)
	(sample, 0)
end

# Each replica uses a random walk Metropolis Hastings inference method
function simulate_n(rng, logenergy, state, samples_per_swap, i)
  OmegaMH.mh(rng,
        logenergy,
        samples_per_swap,
        state,
        propose_and_logratio)
end

# Construct array of relaxed density functions
function make_test_density(dist; temps = [1.0, 2.0, 20.0, 200.0])
  
  logdensity(state) = logpdf(dist, state);

  logrelax(logdensity, temp) = state -> (1/temp) * logdensity(state)

  function evaluate(temp, state)
    relaxed_logdensity = logrelax(logdensity, temp)
    relaxed_logdensity(state)
  end

  [x -> evaluate(temp, x) for temp in temps]
end

dist_easy = MvNormal([-2.0, -2.0], [0.5, 0.5])

dist_hard = MixtureModel([MvNormal([-2.0, -2.0], [0.5, 0.5]),
                          MvNormal([2.0, 2.0], [0.5, 0.5])],
                          [0.5, 0.5])

@testset "replica_exchange" for dist in [dist_easy, dist_hard]

  logenergys = make_test_density(dist)

  # We need a lot of samples to get pretty good performance.
  samples_per_swap = 1000
  num_swaps = 10000
  num_samples = samples_per_swap * num_swaps

  rng = Random.MersenneTwister(0)
  
  states_init = [rand(2) for i in 1:length(logenergys)]
  states_init_copy = deepcopy(states_init)

  # re returns an array of the right size.
  samples = re(rng, logenergys, samples_per_swap, num_swaps, states_init_copy, simulate_n)
  @test isa(samples, Array{Array{Float64, 1}, 1})
  @test length(samples) == num_samples
  @test all(Bool.([length(samples[i] == 2) for i in 1:num_samples]))

  # re does not modify states_init
  @test all(states_init_copy[i] == states_init[i] for i in 1:length(logenergys))

  # re approximately matches the mean and variance
  @test mean(samples) ≈ mean(dist) atol = 0.3
  @test var(samples) ≈ var(dist) atol = 0.3

  # re approximately matches the proportion in upper right quadrant (easy proxy for capturing multimodality in this special case)
  # Distributions.jl doesn't have a cdf method, so we'll just take a Monte Carlo estimate.
  proportion = mean(sum(hcat(samples...) .> 0, dims = 1) .> 0)
  true_samples = rand(dist, num_samples)
  true_proportion = mean(sum(true_samples .> 0, dims = 1) .> 0)
  @test proportion ≈ true_proportion atol = 0.1

  samples! = re!(rng, logenergys, samples_per_swap, num_swaps, states_init_copy, Vector{eltype(states_init)}(undef, num_samples), simulate_n)

  # re! modifies states_init
  @test all(states_init_copy != states_init[i] for i in 1:length(logenergys))

  # re! approximatgely matches the mean and variance
  @test mean(samples!) ≈ mean(dist) atol = 0.3
  @test var(samples!) ≈ var(dist) atol = 0.3

  # re! approximately matches the proportion in upper right quadrant (easy proxy for capturing multimodality in this special case)
  proportion! = mean(sum(hcat(samples!...) .> 0, dims = 1) .> 0)
  @test proportion! ≈ true_proportion atol = 0.1
end