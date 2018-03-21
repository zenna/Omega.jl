MaybeSoftBool = Union{Bool, SoftBool}

"Conditional Random Variable `x | y`"
struct CondRandVar{T, B <: MaybeSoftBool} <: AbstractRandVar{T}
  x::RandVar{T}
  y::RandVar{B}
end

"Conditional Random Variable `x | y`"
Base.cond(x::RandVar, y::RandVar{<:MaybeSoftBool}) = CondRandVar(x, y)

"(rejection) Sample from a conditional random variable"
Base.rand(x::CondRandVar) = rand(x.x, x.y)