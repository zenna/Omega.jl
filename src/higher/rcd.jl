"Random Conditional Distribution"
rcd(x::RandVar, θ::RandVar, eq = ==ₛ) =  ciid(ω -> cond(x, eq(θ, θ(ω))))

"`rcd`, x ∥ y"
x ∥ y = rcd(x, y)