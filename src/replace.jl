
## Tagged Omega Intervention
## =========================
"Mapping from random variable to random variable which replaces it in interved model"
struct Scope{RV}
  id::Int
  rv::RV
end

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
  ω_ = tag(ω, (scope = scope,))
  x(ω_)
end

"Causal Intervention: Set `θold` to `θnew` in `x`"
function Base.replace(x::RandVar{T}, (θold, θnew)::Pair{T1, T2}) where {T, T1 <: RandVar, T2 <: RandVar}
  RandVar{T}(ω -> addscope(ω, θold, θnew, x))
end

## Cassette Powered Intervention
## =============================

@context ChangeCtx

function Cassette.execute(ctx::ChangeCtx, x::RandVar, ω::Ω)
  if ctx.metadata.id === x.id
    return ctx.metadata.x(ω)
  else
    return Cassette.RecurseInstead()
  end
end

"Causal Intervention: Set `θold` to `θnew` in `x`"
function change(θold::RandVar, θnew::RandVar, x::RandVar{T}) where T
  f = ω -> Cassette.overdub(ChangeCtx(metadata = (id = θold.id, x = θnew)), x, ω)
  RandVar{T}(f)
end

"Change where `θconst` is not a randvar, but constant"
change(θold, θconst, x) = change(θold, constant(θconst), x)
