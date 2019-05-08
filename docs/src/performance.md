# Performance Tips

## Check that the type of random variables are inferred.

By default, a random variable will print the inferred return type.
If this type is broader than you expect, you may be losing type information.

```julia
julia> x = normal(0, 1)
3:Normal(0, 1)::Float64

julia> ciid(ω -> bernoulli(ω, 0.5, Bool) ?  poisson(ω, 0.3) : uniform(ω, 0.0, 1.0))
15:getfield(Main, Symbol("##19#20"))()()::Union{Float64, Int64}
```

### Use `const`

It's common in Omega models to have globally defined random variables be paraents of other variables.
If `const` is not used, this can lead to type instability.
For example:

```julia
x = normal(0, 1)
16:Normal(0, 1)::Float64

y_(ω) = 3.0 + x(ω)

y = ciid(y_)
17:y_()::Any
```

Observe that `y_` has Any as the return type

```julia
const x = normal(0, 1)

y_(ω) = 3.0 + x(ω)

y = ciid(y_)
4:y_()::Float64

```
