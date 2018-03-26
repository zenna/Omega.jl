
"Real+ -> [0, 1]"
f1(x; a=0.00001) = x / (x + a)

"Real+ -> [0, 1]"
f2(x; a=1000.0) = 1 - exp(-a * x)

"Soft Boolean"
struct SoftBool{ET <: Real}
  epsilon::ET
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

softeq(x::Real, y::Real) = SoftBool(1 - f1((x - y)^2))
softgt(x::Real, y::Real) = SoftBool(1 - f1(bound_loss(x, y, Inf)))
Base.:&(x::SoftBool, y::SoftBool) = SoftBool(min(x.epsilon, y.epsilon))
Base.:|(x::SoftBool, y::SoftBool) = SoftBool(max(x.epsilon, y.epsilon))
⪆ = softgt
≊ = softeq