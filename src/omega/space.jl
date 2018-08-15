module Space

export Ω, ΩWOW, resolve

"Probability Space indexed with values of type I"
abstract type Ω{I} <: AbstractRNG end

function resolve end

abstract type ΩWOW{I} <: Ω{I} end

## Rand
## ====
"Random ω ∈ Ω"
Base.rand(x::Type{O}) where O <: ΩWOW = defΩ()()

RV = Union{Integer, Random.FloatInterval}
# lookup(::Type{UInt32}) = UInt32, :_UInt32
# lookup(::Type{Close1Open2}) = Float64, :_Float64
# lookup(::Type{CloseOpen}) = Float64, :_Float64


end