
condf(ω, x, y) = Bool(y(ω)) ? x(ω) : nothing

cond(x::RandVar{T}, y::RandVar) where T = RandVar{T}(ω -> condf(ω, x, y))

"`cond(poisson(0.5), iseven`"
cond(x::RandVar, f::Function) = cond(x, pw(() -> f(x)))