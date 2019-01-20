# Cassette Based Memoization
Cassette.@context MemoizeCtx

function Cassette.overdub(ctx::MemoizeCtx, x::RandVar, args...)
  if x.id in keys(ctx.metadata)
    ctx.metadata[x.id]  
  else
    Cassette.recurse(ctx, x, args...)
  end
end

function Cassette.posthook(ctx::MemoizeCtx, retval, x::RandVar, args...)
  ctx.metadata[x.id] = retval
end

## Tagging Based
struct MemΩ{ΩT, V}
  ω::ΩT
  cache::Dict{Int, V}
end

# Ω Based Memoization

mem(ω::ΩT, ::Type{V} = Any) where {ΩT, V} = MemΩ{ΩT, V}(ω, Dict{Int, V}())

"Cache this type of RandVar? (for some types it maybe be faster to not cache)"
willcache(rv::RandVar) = true

@inline ppapl(rv::RandVar, mω::MemΩ) =  rv.f(ωπ, rv.args...)

function apl(rv::RandVar, mω::MemΩ)
  if haskey(mω.cache, x.id)
    mω.cache[x.id]::(Core.Compiler).return_type(x, typeof((mω.ω,)))
  else
    mω.cache[x.id] = apl(x, mω.ω)
  end
end

"""
```julia
using LinearAlgebra
using BenchmarkTools
x = normal(0, 1, (1000, 1000))
h(x) = (println("call!"); svd(x).S)
y = lift(h)(x)
vars = randtuple((y, y*10, y*20))
@benchmark vars(ω) setup = (ω = defΩ()())
@benchmark mcall(vars, ω) setup = (ω = defΩ()())
```
"""
function mcall(x::RandVar, ω::Ω, ::Type{T} = Any) where T
  ctx = MemoizeCtx(metadata = Dict{Int, T}())
  Cassette.overdub(ctx, x, ω)
end