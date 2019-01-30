tagmem(ω, ::Type{V} = Any) where V = tag(ω, (cache = Dict{Int, V}(),))

"Memoized Ω: Records values of random variables"
struct MemΩ{I, ΩT, V} <: ShellΩ{I, ΩT}
  ω::ΩT
  cache::Dict{Int, V}
  MemΩ(ω::ΩT , ::Type{V} = Any) where {ΩT, V} = MemΩ{ΩT, V}(ω, Dict{Int, V}())

end

Omega.shell(ω, mω::MemΩ) = MemΩ(ω, mω.cache)

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
