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

"""

```
using Omega
using Distributions
using SoftPredicates
x = 1 ~ StdNormal{Float64}()
y = 2 ~ StdNormal{Float64}()
z = pw(==ₛ, x, y)
joint_post = @joint(x,y) |ᶜ z
loglikelihood = logerr ∘ softconstraints(joint_post)
# logprior = logenergyexo(x)
logposterior(ω) = logenergyexo(ω) + loglikelihood(ω)
randsample(joint_post, 10; alg = MH, logenergy = logposterior)
```
"""
function OmegaCore.randsample(rng,
                              ΩT,
                              x,
                              n,
                              ::MHAlg;
                              state_init = auto_init(rng, x, ΩT),
                              propose_and_logratio = defpropose_and_logratio(x),
                              logenergy = auto_logenergy(x),
                              kwargs...)
  ωsamples = mh(rng, logenergy, n, state_init, propose_and_logratio; kwargs...) 
  map(x ∘ OmegaCore.tagignorecondition, ωsamples)
end

function OmegaCore.omegarandsample(rng,
                                   ΩT,
                                   logenergy,
                                   n,
                                   ::MHAlg;
                                   state_init = auto_init(rng, logenergy, ΩT),
                                   propose_and_logratio = defpropose_and_logratio(logenergy),
                                   kwargs...)
  ωsamples = mh(rng, logenergy, n, state_init, propose_and_logratio; kwargs...) 
end