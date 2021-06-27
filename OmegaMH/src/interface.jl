"Randomly initialize ω"
function auto_init(rng, ΩT, x)
  ω = ΩT()
  ω_ = OmegaCore.tagignorecondition(OmegaCore.tagrng(ω, rng))
  x(ω_)
  ω
end 

"Exo prior soft constraints"
function logenergyvar(x)
  function logenergyvar_(ω)
    # ϵ = OmegaCore.logcondvarapply(x, ω)
    ϵ = rand()
    ℓ = OmegaCore.logenergyexo(ω)
    ϵ + ℓ
  end
end 

"""

```
using Omega
using Distributions
x = 1 ~ Normal(0, 1)
y = 2 ~ Normal(0, 1)
z = pw(==ₛ, x, y)
randsample(@joint(x,y) |ᶜ z, 10; alg = MH)
```
"""
function OmegaCore.randsample(rng,
                              ΩT,
                              x,
                              n,
                              ::MHAlg;
                              state_init = auto_init(rng, ΩT, x),
                              propose_and_logratio = defpropose_and_logratio(x),
                              kwargs...)
  ωsamples = mh(rng, logenergyvar(x), n, state_init, propose_and_logratio; kwargs...) 
  map(x ∘ OmegaCore.tagignorecondition, ωsamples)
end