"""Cassette Based Counter-factual

```julia
g(x) = @show 2x + 1
h(x) = @show 2x / 3
x_(rng) = g(rand(rng))
Cassette.@Context G2HCtx
Cassette.overdub(::G2HCtx, ::typeof(g), x) = h(x)
x = ciid(x)
x_ = cf(rv, G2HCtx())
y = x_ + x
rand(y)
```
"""
cf(rv::RandVar, ctx::Cassette.Context) = ciid(ω -> Cassette.overdub(ctx, rv, ω))