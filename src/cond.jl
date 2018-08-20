
condf(ω, x, y) = Bool(y(ω)) ? x(ω) : nothing

"""Condition random variable `x` with random predicate RandVar{Bool}

```julia
x = normal(0.0, 1.0)
x_ = cond(x, x > 0)
```
"""
cond(x::RandVar, y::RandVar) where T = URandVar(ω -> condf(ω, x, y))

"Condition random variable with predicate: cond(x, p) = cond(x, p(x))
`cond(poisson(0.5), iseven`"
cond(x::RandVar, f::Function) = cond(x, lift(f)(x))