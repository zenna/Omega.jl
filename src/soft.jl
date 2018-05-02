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

## Soft Logic
## ==========
"Soft Boolean"
struct SoftBool{ET <: Real}
  epsilon::ET
  logepsilon::ET
  uselog::Bool
end

SoftBool(x) = SoftBool(x, zero(x), false)
LogSoftBool(x) =  SoftBool(zero(x), x, true)
logepsilon(x) = x.uselog ? x.logepsilon : x.epsilon |> log
softeq(x::Real, y::Real) = SoftBool(1 - f2((x - y)^2))
softgt(x::Real, y::Real) = SoftBool(1 - f2(bound_loss(x, y, Inf)))
function softeq(x::Vector{<:Real}, y::Vector{<:Real})
  SoftBool(1 - f2(norm(x - y)))
end

function softeq(x::Array{<:Real}, y::Array{<:Real})
  SoftBool(1 - f2(norm(x[:] - y[:])))
end

# softeq(x::Vector{<:Real}, y::Vector{<:Real}) = SoftBool(1 - mean(f1.(x - y)))

Base.:&(x::SoftBool, y::SoftBool) = SoftBool(min(x.epsilon, y.epsilon))
Base.:|(x::SoftBool, y::SoftBool) = SoftBool(max(x.epsilon, y.epsilon))
const ⪆ = softgt
const ≊ = softeq