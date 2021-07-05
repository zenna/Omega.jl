module Sample

using ..Space, ..Util
import Random: AbstractRNG
import Random

export defrandalg, condomegasample, randsample, omegarandsample

"Default sampling algorithm"
function defrandalg end

"`n` samples from `ω::ΩT` such that `yₓ(ω)` is true where `yₓ` are conditions of `x`"
omegasample(rng, ΩT, x, n; kwargs) =
  randsample(rng, ΩT, conditions(x), n; kwargs...) 

"`n` samples from `ω::ΩT` such that `y(ω)` is true"
condomegasample(rng, ΩT, y, n; alg = defrandalg(rng, x, n), kwargs...) = 
  map

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
omegarandsample(rng::AbstractRNG, logenergy, n; alg, kwargs...) =
  omegarandsample(rng, logenergy, n, alg; kwargs...)

omegarandsample(logenergy, n; alg, kwargs...) =
  omegarandsample(Random.GLOBAL_RNG, logenergy, n; alg, kwargs...)

# Convenience methods

"`randsample` using GLOBAL_RNG"
randsample(x, n::Integer; kwargs...) =
  randsample(Random.GLOBAL_RNG, x, n; kwargs...)

randsample(x; kwargs...) = 
  first(randsample(x, 1, kwargs...))
 
randsample(rng::AbstractRNG, xs::Tuple, args...; kwargs...) = 
  randsample(rng, ω -> mapf(ω, xs), args...; kwargs...)
  
# There are two different notions of ΩT
# The first is the return type of the omegas
# Second is Omegas used

end