
using DynamicHMC
using LogDensityProblems
using TransformVariables: as𝕀, as
import TransformVariables
using ForwardDiff
using Omega.Space: flat

"No U-Turn Sampler"
struct NUTSAlg <: SamplingAlgorithm end

"No U-Turn Sampler"
const NUTS = NUTSAlg()
defcb(::NUTSAlg) = default_cbs()
defΩ(::NUTSAlg) = Omega.LinearΩ{Vector{Int64}, Omega.Space.Segment, Real}

"""Dynamic Hamiltonian Monte Carlo

$(SIGNATURES)

Sample `n` `ω::ΩT` 

# Arguments
- `rng`: Random nubmer generator
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
                   cb = donothing,
                   ωinit = ΩT(),
                   ϵ = 0.0001) where {OT <: Ω}
  
  ω = ωinit
  logdensity(ω) # init
  t = as(Array, as𝕀, Omega.Space.nelem(ω))
  # @grab t
  flatlogdensity = flat(logdensity, ω)
  P = TransformedLogDensity(t, flatlogdensity)
  ∇P = ADgradient(:ForwardDiff, P)
  # NUTS_init(rng, ℓ; q = initpos, κ = init, p, max_depth, ϵ, report)

  chain, NUTS_tuned = NUTS_init_tune_mcmc(∇P, n, ϵ = ϵ)
  vecsamples = TransformVariables.transform.(Ref(∇P.transformation), get_position.(chain));
  [unlinearize(floatvec, ω) for floatvec in vecsamples]
end