
export auto_init, auto_logenergy, logposterior
import OmegaCore

# FIXME: Remoev soft predicates from here, but how?!?
using SoftPredicates

"Randomly initialize ω"
function auto_init(rng, x, ΩT)
  ω = ΩT()
  ω_ = OmegaCore.tagignorecondition(OmegaCore.tagrng(ω, rng))
  x(ω_)
  ω
end 

"Exo prior soft constraints"
function auto_logenergy(x)
  function logenergyvar_(ω)
    ϵ = OmegaCore.condvarapply(x, ω, SoftPredicates.DualSoftBool{Float64})
    ℓ = OmegaCore.logenergyexo(ω)
    SoftPredicates.logerr(ϵ) + ℓ
  end
end

le(x::Real) = x
le(x::SoftPredicates.AbstractSoftBool) = SoftPredicates.logerr(x)

function logposterior(likelihood)
  function logpost_(ω)
    ϵ = le(likelihood(ω))
    ℓ = OmegaCore.logenergyexo(ω)
    ϵ + ℓ
  end
end