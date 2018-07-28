
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

function addscope(ω, pairs::Dict{RV1, RV2}, x) where {RV1 <: RandVar, RV2 <: RandVar}
  addscope(ω, Dict(k.id => v for (k, v) in pairs), x)
end

"Causal Intervention: Set `θold` to `θnew` in `x`"
Base.replace(x::RandVar, pair::Pair) = replace(x, Dict(pair.first.id => pair.second))

"Causal Intervention: Set `θold` to `θnew` in `x`"
function Base.replace(x::RandVar{T}, pairs::Dict{RV, RV}) where {T, RV <: RandVar}
  RandVar{T}(ω -> addscope(ω, pairs, x))
end
