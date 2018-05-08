## Distance Functions
## =================

"Real+ -> [0, 1]"
f1(x; a=0.00001) = x / (x + a)

"Squared exponential kernel α = 1/2l^2"
kse(d, α=3.1) = 1 - exp(-α * d)

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
@inline d(x::Vector{<:Real}, y::Vector{<:Real}) = norm(x - y)
@inline d(x::Array{<:Real}, y::Array{<:Real}) = norm(x[:] - y[:])
softeq(x, y, k=kse) = SoftBool(1 - k(d(x, y)))

# softeq(x::Vector{<:Real}, y::Vector{<:Real}) = SoftBool(1 - mean(f1.(x - y)))

softgt(x::Real, y::Real) = SoftBool(1 - kse(bound_loss(x, y, Inf)))
softlt(x::Real, y::Real) = SoftBool(1, kse(bound_loss(x, -Inf, y)))


## Boolean Operators
## =================
Base.:&(x::SoftBool, y::SoftBool) = SoftBool(min(x.epsilon, y.epsilon))
Base.:|(x::SoftBool, y::SoftBool) = SoftBool(max(x.epsilon, y.epsilon))
const ⪆ = softgt
const ≊ = softeq


## Lifts
## =====

Mu.lift(:softeq, 2)
Mu.lift(:softgt, 2)
Mu.lift(:softlt, 2)