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

Cassette.@context SubCtx

function dispatch(ctx, (f_, g_)::Pair{FT, FG}, f::FT, args...) where {FT, FG}
  Cassette.recurse(ctx, g_, args...)
end

dispatch(ctx, metadata, f, args...) = Cassette.recurse(ctx, f, args...)

Cassette.overdub(ctx::SubCtx, f, args...) = dispatch(ctx, ctx.metadata, f, args...)

"""
Cassette based function replacement

`replace(rv::RandVar, function => function)`

```julia
x = normal(0, 1)
noisy(f) = x -> (println("applying f"); f(x))
noisysin = noisy(sin)
y = lift(noisysin)(x)
y_ = replace(y, noisysin => noisy(cos))
rand(y_)
rand(y)
xsampl, ysampl, y_sampl = rand((x, y, y_))
@show cos(xsampl) == y_sampl
```
"""
function Base.replace(rv::RandVar,  replmap::Pair{<:Function, <:Function})
  let ctx = SubCtx(metadata = replmap)
    ciid(ω -> Cassette.overdub(ctx, rv, ω))
  end
end