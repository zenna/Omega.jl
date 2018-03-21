
"Real+ -> [0, 1]"
f1(x; a=0.1) = x / (x + a)

"Real+ -> [0, 1]"
f2(x; a=1.0) = 1 - exp(-a * x)

"Soft Boolean"
struct SoftBool{ET <: Real}
  epsilon::ET
end

softeq(x::Real, y::Real) = SoftBool(1 - f1((x - y)^2))
Base.:&(x::SoftBool, y::SoftBool) = SoftBool(min(x.epsilon, y.epsilon))
Base.:|(x::SoftBool, y::SoftBool) = SoftBool(max(x.epsilon, y.epsilon))
