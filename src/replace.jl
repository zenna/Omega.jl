
## Tagged Omega Intervention
## =========================

function (rv::RandVar{T, true})(tω::TaggedΩ{I, E, ΩT}) where {T, I, E <: Union{ScopeTag, HybridTag}, ΩT <: ΩWOW}
  if rv.id ∈ keys(tω.tags.scope.idmap) 
    return tω.tags.scope.idmap[rv.id](tω)
  else
    args = map(a->apl(a, tω), rv.args)
    (rv.f)(tω[rv.id][1], args...)
  end
end

function (rv::RandVar{T, false})(tω::TaggedΩ{I, E, ΩT}) where {T, I, E <: Union{ScopeTag, HybridTag}, ΩT <: ΩWOW}
  if rv.id ∈ keys(tω.tags.scope.idmap) 
    return tω.tags.scope.idmap[rv.id](tω)
  else
    args = map(a->apl(a, tω), rv.args)
    (rv.f)(args...)
  end
end

function addscope(ω, pairs::Dict{Int, RV}, x) where {RV <: RandVar}
  ω_ = tag(ω, ScopeTag(Scope(pairs)))
  x(ω_)
end

## Conversion
mcv(x::RandVar) = x
mcv(x) = constant(x)
upconv(x::Dict{RV}) where RV = Dict(k.id => mcv(v) for (k, v) in x)
upconv(pairs::Pair...) = Dict(k.id => mcv(v) for (k, v) in pairs)
upconv(pair) = Dict(pair.first.id => mcv(pair.second))

"Causal Intervention: Set `θold` to `θnew` in `x`"
function Base.replace(x::RandVar{T}, tochange::Union{Dict, Pair}...) where T
  let d = upconv(tochange...)
    RandVar{T}(ω -> addscope(ω, d, x))
  end
end
