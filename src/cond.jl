
condf(ω, x, y) = Bool(y(ω)) ? x(ω) : nothing

Base.cond(x::RandVar{T}, y) where T = RandVar{T}(ω -> condf(ω, x, y))