export Unit, Choice, 𝕀, ℝ
export PrimitiveParam, Param

# # Primitives
# These are primitive parameters.

abstract type PrimitiveParam end

"Nondeterministic choice of true or false"
struct BinaryChoice{T <: Integer} <: PrimitiveParam end
Base.eltype(::Type{BinaryChoice{T}}) where T = T

"A Real-valued variable of type `T` in the unit interval: [0, 1]"
struct Unit{T} <: PrimitiveParam end
Base.eltype(::Type{Unit{T}}) where T = T
const 𝕀 = Unit

# # Families of parameters
"Parameter family"
abstract type Param end

"Nondeterministic choice of values in collection"
struct Choice{T} <: Param
  of::T
end
@inline f(d::Choice, id, ω) =
  resolve(StdNormal(), id, ω) * d.σ + d.μ

"The Real numbers"
struct Reals{T} end
ℝ = Reals