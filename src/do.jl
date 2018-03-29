
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
  function dointervene(y::RandVar{T2, P}, seen::ObjectIdDict = ObjectIdDict()) where {T2, P}
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