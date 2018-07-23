
condf(ω, x, y) = Bool(y(ω)) ? x(ω) : nothing

Base.cond(x::RandVar{T}, y::RandVar) where T = RandVar{T}(ω -> condf(ω, x, y))

"`cond(poisson(0.5), iseven`"
Base.cond(x::RandVar, f::Function) = cond(x, pw(() -> f(x)))