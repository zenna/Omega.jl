
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

function (x::RandVar)(ω::TaggedΩ{I, E}) where E <: Scoped
  if ω.tag.scope.id === x.id
    return ω.tag.scope.rv(ω)
  else
    return x(ω)
  end
end

function addscope(ω, θold, θnew, x)
  scope = Scope(θold.id, θnew)
  ω_ = tag(ω, (scope = scope))
  x(ω_)
end

"Causal Intervention: Set `θold` to `θnew` in `x`"
function force(θold::RandVar, θnew::RandVar, x::RandVar{T}) where T
  RandVar{T}(ω -> addscope(ω, θold, θnew, x))
end

"""
Causal intervention: set `x1` to `x2`

`intervene` is equivalent to `do` in do-calculus

## Returns
operator(xold::RandVar{T}) -> xnew::RandVar{T}
where 

jldoctest
```
x = uniform(0.0, 1.0)
y = uniform(x, 1.0)
z = uniform(y, 1.0)
o = intervene(y, uniform(-10.0, -9.0))
```
"""
function intervene(x1::RandVar{T}, x2::Union{RandVar{T}, T}) where T
  dointervene(y, _) = y
  function dointervene(y::RandVar{T2, P}, seen::IdDict{Any, Any} = IdDict{Any, Any}()) where {T2, P}
    if y ∈ keys(seen)
      return seen[y]
    end
    args = map(y.args) do arg
      if arg === x1
        x2
      else
        dointervene(arg, seen)
      end
    end
    answer = if all(args .=== y.args)
      y
    else
      RandVar{T2, P}(y.f, args)
    end
    seen[y] = answer
  end
end

intervene(x1, x2, y::RandVar) = intervene(x1, x2)(y)

function intervene(x1, x2, model::RandVar...)
  o = intervene(x1, x2)
  map(o, model)
end

## Notatiosn
x ← Θ = intervene(x, y)

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
