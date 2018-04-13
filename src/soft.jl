## Distance Functions
## =================

"Real+ -> [0, 1]"
f1(x; a=0.00001) = x / (x + a)

"Real+ -> [0, 1]"
f2(x; a=1) = 1 - exp(-a * x)

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
end

softeq(x::Real, y::Real) = SoftBool(1 - f1((x - y)^2))
softgt(x::Real, y::Real) = SoftBool(1 - f1(bound_loss(x, y, Inf)))
function softeq(x::Vector{<:Real}, y::Vector{<:Real})
  SoftBool(1 - f2(norm(x - y)))
end
# softeq(x::Vector{<:Real}, y::Vector{<:Real}) = SoftBool(1 - mean(f1.(x - y)))

Base.:&(x::SoftBool, y::SoftBool) = SoftBool(min(x.epsilon, y.epsilon))
Base.:|(x::SoftBool, y::SoftBool) = SoftBool(max(x.epsilon, y.epsilon))
⪆ = softgt
≊ = softeq

softeq(x::RandVar{Real}, y::Real) = RandVar{SoftBool}(ω -> SoftBool(1 - f1((x(ω) - y)^2)), ωids(x))
softgt(x::RandVar{Real}, y::Real) = RandVar{SoftBool}(ω -> SoftBool(softgt(x(ω), y)),  ωids(x))

Base.:&(x::RandVar{SoftBool}, y::RandVar{SoftBool}) =
  RandVar{SoftBool}(ω -> SoftBool(min(x(ω).epsilon, y(ω).epsilon)),
                   union(ωids(x), ωids(y)))

Base.:|(x::RandVar{SoftBool}, y::RandVar{SoftBool}) =
  RandVar{SoftBool}(ω -> x(ω) | y(ω), union(ωids(x), ωids(y)))
