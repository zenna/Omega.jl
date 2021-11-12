export auto_init, auto_logenergy, logposterior
import OmegaCore

# # FIXME: Remoev soft predicates from here, but how?!?
# using SoftPredicates

"Randomly initialize `ω::ΩT`"
function auto_init(rng, x, ΩT)
  ω = ΩT()
  ω_ = OmegaCore.tagignorecondition(OmegaCore.tagrng(ω, rng))
  x(ω_)
  ω
end 

"Exo prior soft constraints.  `T` is type of energy"
function auto_logenergy(x, ::Type{T}) where T
  function logenergyvar_(ω)
    ϵ = OmegaCore.condvarapply(x, ω, T) # need this in here for type stability - Julia limitation
    ℓ = OmegaCore.logenergyexo(ω)
    SoftPredicates.logerr(ϵ) + ℓ
  end
end

# le(x::Real) = x
# le(x::SoftPredicates.AbstractSoftBool) = SoftPredicates.logerr(x)

"Random variable that computes `logposterior(ω)` given `loglikelihood`"
function logposterior(likelihood)
  function logpost_(ω)
    ϵ = likelihood(ω)
    ℓ = OmegaCore.logenergyexo(ω)
    ϵ + ℓ
  end
end