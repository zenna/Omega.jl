module AdvancedHMC

using AdvancedHMC

import Omega: SamplingAlgorithm

"No U-Turn Sampler"
struct AHMCAlg <: SamplingAlgorithm end

"""Advanced Hamiltonian Monte Carlo

$(SIGNATURES)

Sample `n` `ω::ΩT` 

# Arguments
- `rng`: Random number generator
- `logdensity`: Real valued `RandVar` defining log-density
- `n`: Number of samples
- `ωinit`: starting position
- `ϵ`: Initial step size
  
# Returns
- `ωs::Vector{ΩT}`: Samples from `logdensity`

"""
function Base.rand(rng,
                   ΩT::Type{OT},
                   logdensity::RandVar,
                   n::Integer,
                   alg::NUTSAlg;
                   ωinit = ΩT(),
                   n_adapts = 2_000,
                   ϵ = 0.0001,
                   gradalg = Omega.TrackerGrad,
                   offset = 0) where {OT <: Ω}
  ω = ωinit
  # init
  logdensity(ω)

  # Flatten
  D = Omega.Space.nelem(ω)

  # Ω is unit hypercube.  Do inference on infinite hypercube and transform
  t = as(Array, as𝕀, D)
  flatlogdensity = flat(logdensity, ω)
  P = TransformedLogDensity(t, flatlogdensity)

  # Gradient
  function gradlogdensity(params)
    lineargradient(logdensity, )

  end
  
  # Draw a random starting points
  θ_init = randn(D)

  # Define metric space, Hamiltonian, sampling method and adaptor
  metric = DiagEuclideanMetric(D)
  h = Hamiltonian(metric, ℓπ, ∂ℓπ∂θ)
  int = Leapfrog(find_good_eps(h, θ_init))
  prop = NUTS{MultinomialTS, GeneralisedNoUTurn}(int)
  adaptor = StanHMCAdaptor(n_adapts, Preconditioner(metric), NesterovDualAveraging(0.8, int.ϵ))

  # Draw samples via simulating Hamiltonian dynamics
  # - `samples` will store the samples
  # - `stats` will store statistics for each sample
  samples, stats = sample(h, prop, θ_init, n_samples, adaptor, n_adapts; progress = true)
end

end