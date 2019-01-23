
"Soft Boolean.  Value in [o, 1]"
struct SoftBool{ET <: Real} <: AbstractSoftBool
  logerr::ET
end
@invariant 0 <= err(b::SoftBool) <= 1

"Error in [0, 1]"
err(x::SoftBool) = exp(x.logerr)

"Log error"
logerr(x::SoftBool) = x.logerr
Bool(x::SoftBool) = err(x) == 1.0
ssofttrue() = SoftBool(0.0)
ssoftfalse() = SoftBool(-Inf)

## (In)Equalities
"Soft Equality"
# softeq(x, y, k = globalkernel()) = SoftBool(-k(d(@show(x), @show(y))))
ssofteq(x, y, k = globalkernel()) = SoftBool(k(d(x, y)))
ssoftgt(x::Real, y::Real, k = globalkernel()) = SoftBool(k(bound_loss(x, y, Inf)))
ssoftlt(x::Real, y::Real, k = globalkernel()) = SoftBool(k(bound_loss(x, -Inf, y)))

## Boolean Operators
## =================
function Base.:&(x::SoftBool, y::SoftBool)
  a = logerr(x)
  b = logerr(y)
  # c = min(a, b)
  c = a + b
  SoftBool(c)
end
Base.:|(x::SoftBool, y::SoftBool) = SoftBool(max(logerr(x), logerr(y)))
Base.all(xs::Vector{<:SoftBool}) = SoftBool(minimum(logerr.(xs)))
Base.all(xs::Vector{<:RandVar}) = RandVar(all, (xs, ))

# Arithmetic
Base.:*(x::SoftBool{T}, y::T) where T = SoftBool{T}(x.logerr * y)

## Show
## ====
Base.show(io::IO, sb::SoftBool) = print(io, "ϵ:$(logerr(sb))")