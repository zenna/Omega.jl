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

# Ω Based Memoization

"Memoized Ω: Records values of random variables"
struct MemΩ{ΩT, V}
  ω::ΩT
  cache::Dict{Int, V}
end

mem(ω::ΩT, ::Type{V} = Any) where {ΩT, V} = MemΩ{ΩT, V}(ω, Dict{Int, V}())

"Cache this type of RandVar? (for some types it maybe be faster to not cache)"
willcache(rv::RandVar) = true

proj(mω::MemΩ, rv::RandVar) = MemΩ(proj(mω.ω, rv), mω.cache)

function apl(rv::RandVar, mω::MemΩ)
  # @assert false
  if haskey(mω.cache, rv.id)
    mω.cache[x.id]::(Core.Compiler).return_type(x, typeof((mω.ω,)))
  else
    mω.cache[x.id] = ppapl(rv, proj(mω, rv))
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
@benchmark Omega.mcall(vars, ω) setup = (ω = defΩ()())
```
"""
function mcall(x::RandVar, ω::Ω, ::Type{T} = Any) where T
  ctx = MemoizeCtx(metadata = Dict{Int, T}())
  Cassette.overdub(ctx, x, ω)
end
