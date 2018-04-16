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

"Probability Space indexed with values of type I"
abstract type Omega{I} <: AbstractRNG end

"Projection of `ω` onto compoment `id`"
struct OmegaProj{O, I} <: Omega{I}
  ω::O
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