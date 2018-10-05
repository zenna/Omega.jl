"Random Conditional Distribution"
rcd(x::RandVar, θ::RandVar, eq = ==) =  ciid(ω -> cond(x, eq(θ, θ(ω))))
rcd(x::RandVar, θs::Tuple, eq = ==) = rcd(x, randtuple(θs), eq)

"`rcd`, x ∥ y"
x ∥ y = rcd(x, y)