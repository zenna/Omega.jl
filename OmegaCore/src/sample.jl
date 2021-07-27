module Sample

using ..Space, ..Util
import Random: AbstractRNG
import Random

export defrandalg, condomegasample, randsample, omegarandsample

"Default sampling algorithm"
function defrandalg end

function omegarandsample end
function omegarandsample1 end

"""
`n` random samples from `x` such that `yₓ(ω)` is true where `yₓ` are conditions of `x
using `alg` algorithm

```
x = 1 ~ StdNormal()
randsample(x |ᶜ x >ₚ 2.0, 3; alg = RejectionSample)
'''
"""
randsample(rng::AbstractRNG, x, n; alg = defrandalg(x), ΩT = defΩ(), kwargs...) =
  randsample(rng, ΩT, x, n, alg; kwargs...)

"""
Sample `n` `ω::AbstractΩ` according to function `logenergy(ω)` using inference algorithm `alg`

# Arguments 
`rng` : random number generator
`logenergy` : 
 
Returns
Vector of `n` samples 
"""
omegarandsample(rng::AbstractRNG, logenergy, n; ΩT = defΩ(), alg, kwargs...) =
  omegarandsample(rng, ΩT, logenergy, n, alg; kwargs...)

omegarandsample(logenergy, n; ΩT = defΩ(), alg, kwargs...) =
  omegarandsample(Random.GLOBAL_RNG, logenergy, n; ΩT, alg, kwargs...)

# Convenience methods

"`randsample` using GLOBAL_RNG"
randsample(x, n::Integer; kwargs...) =
  randsample(Random.GLOBAL_RNG, x, n; kwargs...)

randsample(x; kwargs...) = 
  first(randsample(x, 1, kwargs...))
 
randsample(rng::AbstractRNG, xs::Tuple, args...; kwargs...) = 
  randsample(rng, ω -> mapf(ω, xs), args...; kwargs...)

end