import Base.Random: Close1Open2, CloseOpen

const ωcounter = [0]
"Unique dimension id"
function ωnew()
  global ωcounter
  x::Int = ωcounter[1] += 1
end

"Construct globally unique id for indices for ω"
macro id()
  Mu.ωnew()
end

"Index of Probability Space"
Id = Int

"Tuple of Ints"
const Ints = NTuple{N, Int} where N

"Id of a random variable"
const RandVarId = Int

"Probability Space indexed with values of type I"
abstract type Omega{I} <: AbstractRNG end

"Root Omega mapping random variable ids to components of omega"
struct NestedOmega{O <: Omega} <: Omega{Int} # Hack FIXME
  vals::Dict{RandVarId, O}
end

Base.getindex(ω::NestedOmega{O}, i::Int) where O = get!(ω.vals, i, O())
NestedOmega{O}() where O = NestedOmega(Dict{RandVarId, O}())

"Root Omega mapping random variable ids to components of omega"
struct NestedOmegaRandVar{O <: Omega} <: Omega{Int} # Hack FIXME
  vals::NestedOmega{O}
  id::RandVarId
end

Base.rand(T, nω::NestedOmegaRandVar) = rand(T, nω[0])
Base.rand(nω::NestedOmegaRandVar, T) = rand(nω[0], T)

resetcount!(nω::NestedOmegaRandVar) = resetcount!(nω.vals[nω.id])

"Projection of `ω` onto compoment `id`"
struct OmegaProj{O, I} <: Omega{I}
  ω::NestedOmegaRandVar{O}
  id::I
end

## Rand
## ====
RV = Union{Integer, Base.Random.FloatInterval}
lookup(::Type{UInt32}) = UInt32, :_UInt32
lookup(::Type{Close1Open2}) = Float64, :_Float64
lookup(::Type{CloseOpen}) = Float64, :_Float64

function Base.rand(ωπ::OmegaProj, ::Type{T}) where {T <: RV}
  closeopen(T, ωπ)
end