
"Alias for `cond`"
|ₚ(x, y) = cond(x, y)

"""
$(SIGNATURES)

Convenience function to condition random variable `x` with a predicate `p`

`condp(x, p) = cond(x, p(x))`

```jldoctest
a = condp(poisson(0.5), iseven)
b = a |ₚ (x -> x < 10)
```

"""
condp(x, p) = cond(x, lift(p)(x))

# "Alias for `condp`"
# |ₚ(x, p) = condp(x, p)