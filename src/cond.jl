
MaybeSoftBool = Union{Bool, SoftBool}
"Conditional Random Variable `x | y`"
struct CondRandVar{T, RVX, RVB <: RandVar{<:Bool}} <: AbstractRandVar{T}
  x::AbstractRandVar{T} 
  y::RVB
end

# "Conditional Random Variable `x | y`"
Base.cond(x::AbstractRandVar, y::RandVar{<:Bool}) = CondRandVar(x, y)

# "(rejection) Sample from a conditional random variable"
# Base.rand(x::CondRandVar) = rand(x.x, x.y)

# "`x(ω)`"
# (x::CondRandVar)(ω::Ω) = x.y(ω) ? x.x(ω) : throw(ArgumentError("Invalid ω"))
