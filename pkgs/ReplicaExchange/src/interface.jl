import OmegaCore
"""

```
using OmegaCore
using SoftPredicates
using ReplicaExchange
using InferenceBase

# Model
x = 1 ~ StdNormal{Float64}()
y = 2 ~ StdNormal{Float64}()
z = pw(==ₛ, x, y)
joint_post = @joint(x,y) |ᶜ z

# Target
loglikelihood = logerr ∘ softconstraints(joint_post)
temp_range = [0.001, 0.1, 1, 10, 100]
logposterior(ω) = logenergyexo(ω) + loglikelihood(ω)

struct TemperedLogPosterior{T}
  α::T
end 
(at::TemperedLogPosterior)(ω) = withkernel(kseα(at.α)) do
  logposterior(ω)
end

logenergys = TemperedLogPosterior.(temp_range)
randsample(joint_post, 10; alg = Replica, logenergy = logposterior)

sim_chain_keep_n(rng, logenergy, n; state_init) =
  omegarandsample(rng, logenergy, n, MH; state_init = init_state)
```
"""
function OmegaCore.omegarandsample(rng,
                                   logenergy,
                                   n,
                                   ::ReplicaAlg;
                                   num_swaps = 10,
                                   state_init = auto_init(rng, x),
                                   sim_chain_keep_n,
                                   propose_and_logratio = defpropose_and_logratio(x),
                                   logenergys,
                                   kwargs...)
  samples_per_swap = div(n, num_swaps) # zt: might not fit right
  states_init = # do-something

  ωsamples = re(rng,
                logenergys,
                samples_per_swap,
                num_swaps,
                states_init,
                n,
                state_init,
                sim_chain_keep_n,
                kwargs...) 
end

