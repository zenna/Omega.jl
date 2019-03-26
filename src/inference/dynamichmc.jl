using DynamicHMC
using LogDensityProblems
using TransformVariables: as𝕀, as
import TransformVariables
using ForwardDiff
using Omega.Space: flat

"No U-Turn Sampler"
struct NUTSAlg <: SamplingAlgorithm end

isapproximate(::NUTSAlg) = true

"No U-Turn Sampler"
const NUTS = NUTSAlg()
defcb(::NUTSAlg) = default_cbs()
defΩ(::NUTSAlg) = Omega.LinearΩ{Vector{Int64}, UnitRange{Int64}, Vector{ForwardDiff.Dual}}

"""Dynamic Hamiltonian Monte Carlo

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
                   ϵ = 0.0001,
                   offset = 0) where {OT <: Ω}
  ω = ωinit
  # init
  logdensity(ω)

  # Ω is unit hypercube.  Do inference on infinite hypercube and transform
  t = as(Array, as𝕀, Omega.Space.nelem(ω))

  flatlogdensity = flat(logdensity, ω)
  P = TransformedLogDensity(t, flatlogdensity)
  ∇P = ADgradient(:ForwardDiff, P)
  chain, NUTS_tuned = NUTS_init_tune_mcmc(rng, ∇P, n, ϵ = ϵ)
  vecuntransformed = get_position.(chain)
  vecsamples = t.(vecuntransformed)
  [unlinearize(floatvec, ω) for floatvec in vecsamples]
end