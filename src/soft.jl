## Kernels 
## =======

"Real+ -> [0, 1]"
kf1(x, β = 0.0001) = x / (x + β)
kf1β(β) = d -> kf1(d, β)
lift(:kf1β, 1)

"Squared exponential kernel `α = 1/2l^2`, higher α is lower temperature  "
kse(d, α = 20.0) = 1 - exp(-α * d)
kseα(α) = d -> kse(d, α) 
lift(:kseα, 1)

"Power law relation "
kpow(d, α = 1.0, k = 2) = α*d^(-k)

kpareto(x, xm = 0, α = 1.0) = (α * xm) / (x^(α + 1))
kpareto2(x, xm = 1.0, α = 11) = (α * xm) / (x+xm^(α + 1))
kpareto3(x, xm = 1.0, α = 3) = xm / (x+xm^(α + 1))

burr(x, c = 1, k = 40) =  c * k * x^(c - 1) / (1 + x^c)^(k + 1) 

const GLOBALKERNEL_ = Function[kse]

"Global Kernel"
function globalkernel!(k)
  global GLOBALKERNEL_
  GLOBALKERNEL_[1] = k
end

"Retrieve global kernel"
function globalkernel()
  global GLOBALKERNEL_
  GLOBALKERNEL_[1]
end

"Temporarily set global kernel"
function withkernel(thunk, k)
  globalkernel!(k)
  res = thunk()
  globalkernel!(kse)
  res
end

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

randbool(f, x, y) = RandVar{Bool, false}(SoftBool ∘ f, (x, y))
lograndbool(f, x, y) = RandVar{Bool, false}(LogSoftBool ∘ f, (x, y))
randbool(ϵ::RandVar) = RandVar{Bool, false}(SoftBool, (ϵ,))

## Soft Logic
## ==========
"Soft Boolean"
struct SoftBool{ET <: Real}
  epsilon::ET
end
@invariant 0 <= epsilon(b::SoftBool) <= 1

struct LogSoftBool{ET <: Real}
  logepsilon::ET
end

epsilon(x::SoftBool) = x.epsilon
epsilon(x::LogSoftBool) = exp(x.logepsilon)

logepsilon(x::SoftBool) = log(x.epsilon)
logepsilon(x::LogSoftBool) = x.logepsilon

## (In)Equalities
## ==============
@inline d(x::Real, y::Real) = (xy = (x - y); xy * xy)
# @inline d(x::Vector{<:Real}, y::Vector{<:Real}) = norm(x - y)
@inline d(x::Vector{<:Real}, y::Vector{<:Real}) = minimum((d.(x,y)))
@inline d(x::Array{<:Real}, y::Array{<:Real}) = norm(x[:] - y[:])

"Soft Equality"
softeq(x, y, k = globalkernel()) = SoftBool(1 - k(d(x, y)))

"Unbounded soft equality"
usofteq(x, y, k = globalkernel()) = SoftBool(k(d(x, y)))

# softeq(x::Vector{<:Real}, y::Vector{<:Real}) = SoftBool(1 - mean(f1.(x - y)))

softgt(x::Real, y::Real, k = globalkernel()) = SoftBool(1 - k(bound_loss(x, y, Inf)))
softlt(x::Real, y::Real, k = globalkernel()) = SoftBool(1 - k(bound_loss(x, -Inf, y)))

## Boolean Operators
## =================
Base.:&(x::SoftBool, y::SoftBool) = SoftBool(min(x.epsilon, y.epsilon))
Base.:|(x::SoftBool, y::SoftBool) = SoftBool(max(x.epsilon, y.epsilon))
Base.:|(x::RandVar, y::RandVar) = RandVar{SoftBool, false}(|, (x, y))

Base.all(xs::Vector{<:SoftBool}) = SoftBool(minimum(epsilon.(xs)))
Base.all(xs::Vector{<:RandVar}) = RandVar{SoftBool}(all, ())

const ⪆ = softgt
const ≊ = softeq
const ueq = usofteq

## Lifts
## =====

Mu.lift(:softeq, 2)
Mu.lift(:usofteq, 2)
Mu.lift(:usofteq, 3)
Mu.lift(:softeq, 3)
Mu.lift(:softgt, 2)
Mu.lift(:softlt, 2)

## Show
## ====
Base.show(io::IO, sb::SoftBool) = print(io, "ϵ:$(epsilon(sb))")