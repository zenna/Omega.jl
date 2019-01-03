"Soft Boolean.  Value in [o, 1]"
struct SoftBool{ET <: Real}
  logerr::ET
end
@invariant 0 <= err(b::SoftBool) <= 1

"Error in [0, 1]"
err(x::SoftBool) = exp(x.logerr)

"Log error"
logerr(x::SoftBool) = x.logerr

Bool(x::SoftBool) = err(x) == 1.0
SoftBool(::Type{Val{true}}) = SoftBool(0.0)
SoftBool(::Type{Val{false}}) = SoftBool(-Inf)
const trueₛ = SoftBool(Val{true})
const falseₛ = SoftBool(Val{false})

## (In)Equalities
"Soft Equality"
# softeq(x, y, k = globalkernel()) = SoftBool(-k(d(@show(x), @show(y))))
softeq(x, y, k = globalkernel()) = SoftBool(-k(d(x, y)))
softgt(x::Real, y::Real, k = globalkernel()) = SoftBool(-k(bound_loss(x, y, Inf)))
softlt(x::Real, y::Real, k = globalkernel()) = SoftBool(-k(bound_loss(x, -Inf, y)))

## Boolean Operators
## =================
function Base.:&(x::SoftBool, y::SoftBool)
  a = logerr(x)
  b = logerr(y)
  # c = min(a, b)
  c = a + b
  SoftBool(c)
end
# Base.:&(x::SoftBool, y::SoftBool) = SoftBool(logerr(x) +  logerr(y))
Base.:|(x::SoftBool, y::SoftBool) = SoftBool(max(logerr(x), logerr(y)))

Base.all(xs::Vector{<:SoftBool}) = SoftBool(minimum(logerr.(xs)))
Base.all(xs::Vector{<:RandVar}) = RandVar(all, (xs, ))

const >ₛ = softgt
const >=ₛ = softgt
const <=ₛ = softlt
const <ₛ = softlt
const ==ₛ = softeq


## Lifts
## =====

Omega.lift(:softeq, 2)
Omega.lift(:softeq, 3)
Omega.lift(:softgt, 2)
Omega.lift(:softlt, 2)

Omega.lift(:logerr, 1)
Omega.lift(:err, 1)


## Show
## ====
Base.show(io::IO, sb::SoftBool) = print(io, "ϵ:$(logerr(sb))")