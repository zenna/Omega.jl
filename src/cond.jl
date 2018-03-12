"Conditional Random Variable `x | y`"
struct CondRandVar{T} <: AbstractRandVar{T}
  x::AbstractRandVar{T}
  y::AbstractRandVar{Bool}
end

"Conditional random variable `x | y`"
Base.cond(x::RandVar, y::RandVar{Bool}) = CondRandVar(x, y)

"(rejection) Sample from a conditional random variable"
Base.rand(x::CondRandVar) = rand(x.x, x.y)

"`x(ω)`"
(x::CondRandVar)(ω::Omega) = x.y(ω) ? x.x(ω) : throw(ArgumentError("Invalid ω"))
