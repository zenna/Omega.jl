
## Tagged Omega Intervention
## =========================


Scoped{T} = Union{
  Tuple{Scope},
  Tuple{T, Scope},
  Tuple{Scope, T},
}

function (rv::RandVar{T, true})(tω::TaggedΩ{I, E, ΩT}) where {T, I, E <: Scoped, ΩT <: ΩWOW}
  # @show "hello"
  @show rv.id, tω.tags.scope
  if tω.tags.scope.id === rv.id
    return tω.tags.scope.rv(tω)
  else
    args = map(a->apl(a, tω), rv.args)
    (rv.f)(tω[rv.id][1], args...)
  end
end

function (rv::RandVar{T, false})(tω::TaggedΩ{I, E, ΩT}) where {T, I, E <: Scoped, ΩT <: ΩWOW}
  if tω.tags.scope.id === rv.id
    return tω.tags.scope.rv(tω)
  else
    args = map(a->apl(a, tω), rv.args)
    (rv.f)(args...)
  end
end

function addscope(ω, θold, θnew, x)
  scope = Scope(θold.id, θnew)
  ω_ = tag(ω, ScopeTag(scope))
  x(ω_)
end

"Causal Intervention: Set `θold` to `θnew` in `x`"
function Base.replace(x::RandVar{T}, pair::Pair{T1, T2}) where {T, T1 <: RandVar, T2 <: RandVar}
  θold, θnew = pair
  RandVar{T}(ω -> addscope(ω, θold, θnew, x))
end
