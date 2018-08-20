
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

"""Condition within a function

```
function x_(ω)
  x = 0.0
  xs = Float64[]
  while bernoulli(ω, 0.8, Bool)
    x += uniform(ω, -5.0, 5.0)
    cond(ω, x <=ₛ 1.0)
    cond(ω, x >=ₛ -1.0)
    push!(xs, x)
  end
  xs
end

x = ciid(x_)
samples = rand(x, 100; alg = SSMH)
```
"""
cond(ω::Ω, bool) = nothing