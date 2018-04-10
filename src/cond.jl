
MaybeSoftBool = Union{Bool, SoftBool}
# "Conditional Random Variable `x | y`"
# struct CondRandVar{T <: RandVar{T}, B <: RandVar{<:Bool}} <: RandVar{T}
#   x::AbstractRandVar{T} 
#   y::B
# end

# "Conditional Random Variable `x | y`"
# Base.cond(x::AbstractRandVar, y::RandVar{<:Bool}) = CondRandVar(x, y)

# "(rejection) Sample from a conditional random variable"
# Base.rand(x::CondRandVar) = rand(x.x, x.y)

# "`x(ω)`"
# (x::CondRandVar)(ω::Omega) = x.y(ω) ? x.x(ω) : throw(ArgumentError("Invalid ω"))
