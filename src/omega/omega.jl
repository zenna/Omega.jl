const ωcounter = [0]
"Unique dimension id"
function ωnew()
  global ωcounter
  x::Int = ωcounter[1] += 1
end

"Construct globally unique id for indices for ω"
macro id()
  Omega.ωnew()
end

"Index of Probability Space"
const Id = Int

"Tuple of Ints"
const Ints = NTuple{N, Int} where N

"Id of a random variable"
const RandVarId = Int

"Probability Space indexed with values of type I"
abstract type Ω{I} <: AbstractRNG end

## Rand
## ====
RV = Union{Integer, Random.FloatInterval}
# lookup(::Type{UInt32}) = UInt32, :_UInt32
# lookup(::Type{Close1Open2}) = Float64, :_Float64
# lookup(::Type{CloseOpen}) = Float64, :_Float64