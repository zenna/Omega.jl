
@context ChangeCtx

@primitive function (x::RandVar)(ω::Ω) where {__CONTEXT__ <: ChangeCtx}
  rv = if x.id in keys(__context__.metadata)
    __context__.metadata[x.id]
  else
    x
  end
  args = Cassette.overdub(ChangeCtx(metadata = __context__.metadata), map, a->apl(a, ω), rv.args)
  Cassette.overdub(ChangeCtx(metadata = __context__.metadata), rv.f, ω[rv.id], args...)
end

"Causal Intervention: Set `θold` to `θnew` in `x`"
function change(θold::RandVar, θnew::RandVar, x::RandVar{T}) where T
  f = ω -> Cassette.overdub(ChangeCtx(metadata = Dict(θold.id => θnew)), x, ω)
  RandVar{T}(f)
end

"Change where `θconst` is not a randvar, but constant"
change(θold, θconst, x) = change(θold, constant(θconst), x)


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