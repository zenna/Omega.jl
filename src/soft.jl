## Distance Functions
## =================

"Real+ -> [0, 1]"
f1(x; a=0.00001) = x / (x + a)

"Real+ -> [0, 1]"
f2(x; a=1000) = 1 - exp(-a * x)

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

## Soft Logic
## ==========
"Soft Boolean"
struct SoftBool{ET <: Real}
  epsilon::ET
end

struct LogSoftBool{ET <: Real}
  logepsilon::ET
end

epsilon(x::SoftBool) = x.epsilon
epsilon(x::LogSoftBool) = exp(x.logepsilon)

logepsilon(x::SoftBool) = log(x.epsilon)
logepsilon(x::LogSoftBool) = x.logepsilon

## (In)Equalities
## ==============
softeq(x::Real, y::Real) = SoftBool(1 - f2((x - y)^2))
softgt(x::Real, y::Real) = SoftBool(1 - f2(bound_loss(x, y, Inf)))
function softeq(x::Vector{<:Real}, y::Vector{<:Real})
  SoftBool(1 - f2(norm(x - y)))
end

function softeq(x::Array{<:Real}, y::Array{<:Real})
  println("Here")
  # @grab x
  # @grab y
  SoftBool(1 - f2(norm(x[:] - y[:])))
end

# softeq(x::Vector{<:Real}, y::Vector{<:Real}) = SoftBool(1 - mean(f1.(x - y)))

## Boolean Operators
## =================
Base.:&(x::SoftBool, y::SoftBool) = SoftBool(min(x.epsilon, y.epsilon))
Base.:|(x::SoftBool, y::SoftBool) = SoftBool(max(x.epsilon, y.epsilon))
const ⪆ = softgt
const ≊ = softeq