
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

Sample `n` `ω::ΩT` 

# Arguments
- logdensity: Real valued `RandVar` defining log-density

"""
function Base.rand(ΩT::Type{OT},
                   logdensity::RandVar,
                   n::Integer,
                   alg::NUTSAlg;
                   cb = donothing) where {OT <: Ω}
  ω = ΩT()
  logdensity(ω) # init
  t = as(Array, as𝕀, Omega.Space.nelem(ω))
  flatlogdensity = flat(logdensity, ω)
  P = TransformedLogDensity(t, flatlogdensity)
  ∇P = ADgradient(:ForwardDiff, P)
  chain, NUTS_tuned = NUTS_init_tune_mcmc(∇P, n)
  vecsamples = TransformVariables.transform.(Ref(∇P.transformation), get_position.(chain));
  [unlinearize(floatvec, ω) for floatvec in vecsamples]
end

function Base.rand(x::RandVar,
                   n::Integer,
                   alg::NUTSAlg,
                   ΩT::Type{OT};
                   cb = donothing)  where {OT <: Ω}
  logdensity = logerr(indomain(x))
  map(ω -> applynotrackerr(x, ω),
      rand(ΩT, logdensity, n, alg; cb = cb))
end