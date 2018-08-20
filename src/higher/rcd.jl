"Random Conditional Distribution"
rcd(x::RandVar, θ::RandVar) =  ciid(ω -> cond(x, θ == θ(ω)))

"`rcd`, x ∥ y"
x ∥ y = rcd(x, y)