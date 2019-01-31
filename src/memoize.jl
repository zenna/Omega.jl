tagmem(ω, ::Type{V} = Any) where V = tag(ω, (cache = Dict{Int, V}(),))

"Don't cache this type of RandVar? (for some `RandVar`s it may be be faster to not cache)"
dontcache(rv::RandVar) = false

@inline function memapl(rv::RandVar, mω::TaggedΩ)
  if dontcache(rv)
    ppapl(rv, proj(mω, rv))
  elseif haskey(mω.tags.cache, rv.id) # FIXME: Avoid two lookups!
    mω.tags.cache[x.id]::(Core.Compiler).return_type(x, typeof((mω.ω,)))
  else
    mω.tags.cache[x.id] = ppapl(rv, proj(mω, rv))
  end
end
