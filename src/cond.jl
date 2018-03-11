"Conditional Random Variable `x | y`"
struct CondRandVar{T} <: AbstractRandVar{T}
  x::RandVar{T}
  y::RandVar{Bool}
end

"Conditional Random Variable `x | y`"
Base.cond(x::RandVar, y::RandVar{Bool}) = CondRandVar(x, y)

"(rejection) Sample from a conditional random variable"
Base.rand(x::CondRandVar) = rand(x.x, x.y)