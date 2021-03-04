export Unit,
       Choice,
       𝕀,
       ℝ,
       BinaryChoice
export PrimitiveParam, Param

# # Primitives
# These are primitive parameters.

abstract type PrimitiveParam end
(pp::PrimitiveParam)(id, ω) = ω[Member(id, pp)]

"Nondeterministic choice of true or false"
struct BinaryChoice{T <: Integer} <: PrimitiveParam end
Base.eltype(::Type{BinaryChoice{T}}) where T = T

"A Real-valued variable of type `T` in the unit interval: [0, 1]"
struct Unit{T} <: PrimitiveParam end
Base.eltype(::Type{Unit{T}}) where T = T
const 𝕀 = Unit

"The Real numbers"
struct Reals{T} <: PrimitiveParam end
Base.eltype(::Type{Reals{T}}) where T = T
const ℝ = Reals

# # Families of parameters
# # Non primtiives
"Parameter family"
abstract type Param end

"Parametric choice of values in collection"
struct Choice{T} <: Param
  of::T
end
(c::Choice)(id, ω) = c.of[]

"One of many other parametric choices"
struct Disjunction{XS} <: Param
  xs::XS
end
(c::Disjunction)(id, ω) = c.of[]


"Interval `[a, b]`"
struct Interval{T} <: Param
  a::T
  b::T
end

struct Permutation
  n
end

struct Shuffle
end