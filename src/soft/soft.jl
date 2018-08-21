# Soft Logic

"Soft Boolean"
struct SoftBool{ET <: Real}
  logepsilon::ET
end
@invariant 0 <= epsilon(b::SoftBool) <= 1

"Error in [0, 1]"
epsilon(x::SoftBool) = x.logepsilon |> exp

"Log error"
logepsilon(x::SoftBool) = x.logepsilon

Bool(x::SoftBool) = epsilon(x) == 1.0
SoftBool(::Type{Val{true}}) = SoftBool(0.0)
SoftBool(::Type{Val{false}}) = SoftBool(-Inf)
const trueₛ = SoftBool(Val{true})
const falseₛ = SoftBool(Val{false})

## (In)Equalities

"Distance between two values"
function d end

@inline d(x::Real, y::Real) = (xy = (x - y); xy * xy)
# @inline d(x::Vector{<:Real}, y::Vector{<:Real}) = norm(x - y)
@inline d(x::Vector{<:Real}, y::Vector{<:Real}) = sum(d.(x,y))
@inline d(x::Array{<:Real}, y::Array{<:Real}) = norm(x[:] - y[:])

"Soft Equality"
softeq(x, y, k = globalkernel()) = SoftBool(-k(d(x, y)))

"Unbounded soft equality"
usofteq(x, y, k = globalkernel()) = SoftBool(k(d(x, y)))

# softeq(x::Vector{<:Real}, y::Vector{<:Real}) = SoftBool(1 - mean(f1.(x - y)))

function bound_loss(x, a, b)
  # @pre b >= a
  if x < a
    a - x
  elseif x > b
    x - b
  else
    zero(x)
  end
end

softgt(x::Real, y::Real, k = globalkernel()) = SoftBool(-k(bound_loss(x, y, Inf)))
softlt(x::Real, y::Real, k = globalkernel()) = SoftBool(-k(bound_loss(x, -Inf, y)))

## Boolean Operators
## =================
function Base.:&(x::SoftBool, y::SoftBool)
  a = logepsilon(x)
  b = logepsilon(y)
  c = min(a, b)
  SoftBool(c)
end
# Base.:&(x::SoftBool, y::SoftBool) = SoftBool(logepsilon(x) +  logepsilon(y))
Base.:|(x::SoftBool, y::SoftBool) = SoftBool(max(logepsilon(x), logepsilon(y)))

Base.all(xs::Vector{<:SoftBool}) = SoftBool(minimum(logepsilon.(xs)))
Base.all(xs::Vector{<:RandVar}) = RandVar(all, (xs, ))

const >ₛ = softgt
const >=ₛ = softgt
const <=ₛ = softlt
const <ₛ = softlt
const ==ₛ = softeq

const ⪆ = softgt
const ⪅ = softlt
const ≊ = softeq
const ueq = usofteq

## Lifts
## =====

Omega.lift(:softeq, 2)
Omega.lift(:usofteq, 2)
Omega.lift(:usofteq, 3)
Omega.lift(:softeq, 3)
Omega.lift(:softgt, 2)
Omega.lift(:softlt, 2)

## Show
## ====
Base.show(io::IO, sb::SoftBool) = print(io, "ϵ:$(logepsilon(sb))")