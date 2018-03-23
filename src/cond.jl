MaybeSoftBool = Union{Bool, SoftBool}

"Conditional Random Variable `x | y`"
struct CondRandVar{T, B <: MaybeSoftBool} <: AbstractRandVar{T}
  x::AbstractRandVar{T} 
  y::AbstractRandVar{B}
end

"Conditional Random Variable `x | y`"
Base.cond(x::AbstractRandVar, y::RandVar{<:MaybeSoftBool}) = CondRandVar(x, y)

"(rejection) Sample from a conditional random variable"
Base.rand(x::CondRandVar) = rand(x.x, x.y)

"`x(ω)`"
(x::CondRandVar)(ω::Omega) = x.y(ω) ? x.x(ω) : throw(ArgumentError("Invalid ω"))
