tagmem(ω, ::Type{V} = Any) where V = tag(ω, (cache = Dict{ID, V}(),))

"Don't cache this type of RandVar? (for some `RandVar`s it may be be faster to not cache)"
dontcache(rv::RandVar) = false

@inline function memapl(rv::RandVar, mω::TaggedΩ)
  if dontcache(rv)
    ppapl(rv, proj(mω, rv))
  elseif haskey(mω.tags.cache, rv.id) # FIXME: Avoid two lookups!
    mω.tags.cache[rv.id]::(Core.Compiler).return_type(rv, typeof((mω.taggedω,)))
  else
    mω.tags.cache[rv.id] = ppapl(rv, proj(mω, rv))
  end
end

"""
```julia
using LinearAlgebra, BenchmarkTools
x = normal(0, 1, (1000, 1000))
h(x) = (println("call!"); svd(x).S)
y = lift(h)(x)
vars = randtuple((y, y*10, y*20))
@benchmark vars(ω) setup = (ω = defΩ()())
@benchmark vars(ω) setup = (ω = tagmem(defΩ()()))
```
"""
mem(rv::RandVar, ::Type{V} = Any) where V = ciid(ω -> apl(rv, tagmem(ω, V)))