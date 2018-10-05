"Probability Space indexed with values of type I"
abstract type Ω{I} <: Random.AbstractRNG end

"This is base Omega - Sample Space Object"
abstract type ΩBase{I} <: Ω{I} end

idtype(::Type{OT}) where {I, OT <: Ω{I}} = I

# Must implement:
# * Base.==
# * Base.isempty
# * Base.merge! ( -- currently unused)
# ? others
function resolve end

"Linearize ω into flat vector"
function linearize end

"Inverse of `linearize`, structure vector into ω"
function unlinearize end

## Rand

"Random ω ∈ Ω"
Base.rand(x::Type{O}) where O <: ΩBase = O()()

Random.rng_native_52(ω::Ω) = Random.rng_native_52(Random.GLOBAL_RNG)