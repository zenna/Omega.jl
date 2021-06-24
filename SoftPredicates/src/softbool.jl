
"Soft Boolean.  Value in [0, 1]"
struct SoftBool{ET <: Real} <: AbstractSoftBool
  logerr::ET
  SoftBool(l::T) where {T} = new{T}(l)
  # SoftBool(l::T) where {T <: ForwardDiff.Dual} = new{T}(l) # Resolves type ambiguity (from flux)
end
@invariant 0 <= err(b::SoftBool) <= 1

"Error in [0, 1]"
err(x::SoftBool) = exp(x.logerr)

"Log error in `[-Inf, 0]`"
logerr(x::SoftBool) = x.logerr
Bool(x::SoftBool) = logerr(x) == 0.0
ssofttrue(::Type{T} = Float64) where T = SoftBool(zero(t))
ssoftfalse(::Type{T} = Float64) where T = SoftBool(-inf(T))

# (In)Equalities #

"Kernel return type as function of arguments"
kernelrettype(x::T, y::T) where T = T

softeq(a::Bool, b::Bool) = softeq(float(a), float(b))
softeq(a::Integer, b::Integer) = softeq(float(a), float(b))

"Soft Equality"
function ssofteq(x, y, k = globalkernel())
  r = d(x, y)
  SoftBool(k(r)::typeof(r))
end

"Soft >"
function ssoftgt(x::Real, y::Real, k = globalkernel())
  r = bound_loss(x, y, Inf)
  SoftBool(k(r)::typeof(r))
end

"Soft <"
function ssoftlt(x::Real, y::Real, k = globalkernel())
  r = bound_loss(x, -Inf, y)
  SoftBool(k(r)::typeof(r))
end

# Boolean Operators #
function Base.:&(x::SoftBool, y::SoftBool)
  a = logerr(x)
  b = logerr(y)
  # c = min(a, b)
  c = a + b
  SoftBool(c)
end
Base.:|(x::SoftBool, y::SoftBool) = SoftBool(max(logerr(x), logerr(y)))
# zt: FIXME abstractvector?
Base.all(xs::Vector{<:SoftBool}) = SoftBool(minimum(logerr.(xs)))

# Arithmetic #
Base.:*(x::SoftBool{T}, y::T) where T <: Real = SoftBool(x.logerr * y)
Base.:*(x::T, y::SoftBool{T}) where T <: Real = SoftBool(x * y.logerr)

# Show #
Base.show(io::IO, sb::SoftBool) = print(io, "ϵ:$(logerr(sb))")