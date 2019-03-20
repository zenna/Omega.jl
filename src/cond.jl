
condf(ω, x, y) = Bool(y(ω)) ? x(ω) : error("Condition unsatisfied")

"""$(SIGNATURES)
Condition RandVar `x` with random predicate `y` whose `elemtype`
is an `AbstractBool`

```julia
x = normal(0.0, 1.0)
x_ = cond(x, x > 0)
```
"""
cond(x::RandVar, y::RandVar) = URandVar(ω -> condf(ω, x, y))

"""
$(SIGNATURES)

Convenience function to condition with a predicate

`cond(x, p(x))`

```jldoctest
cond(poisson(0.5), iseven)
```

"""
cond(x::RandVar, p) = cond(x, lift(p)(x))

"""$(SIGNATURES)

Condition intermediate values from within the functional definition of a `RandVar`

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