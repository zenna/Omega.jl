
applymany(fs, x) = map(xi->xi(x), fs)
@spec all([_res[i] = f[i](x) for f in fs])

"""
Transpose for nested list / tuples.
Useful for output of rand(::NTuple{RandVar})
  
```jldoctest
x = normal(0.0, 1.0)
y = normal(0.0, 1.0)
samples = rand((x, y), x == y)
x_, y_ = ntranspose(samples)
```
"""
ntranspose(xs) = [[x[i] for x in xs] for i = 1:length(xs[1])]
@spec :incomplete same([length(x) for x in xs])

"Counter"
mutable struct Counter
  count::Int
end
Counter() = Counter(0)

"Increment counter"
increment!(c::Counter) = x::Int = c.count += 1
@spec UTupleec c.count == _pre(c.count) += 1

reset!(c::Counter) = c.count = 1

UTuple{T} = Tuple{Vararg{T, N}} where N

# FIXME, dynamic dispatch
"merge using combine if key is shared.
Assumes result of combine same type as in `b`

```jldoctest
x = (a = 1, b = 2)
y = (b = 2, c = 3)
merge(*, x, y)
```
"
function Base.merge(combine::Function, a::NamedTuple{an}, b::NamedTuple{bn}) where {an, bn}
  names = merge_names(an, bn)
  types = merge_types(names, typeof(a), typeof(b))
  function resolve(n)
    if sym_in(n, bn)
      if sym_in(n, an)
        combine(Val{n}, getfield(a, n), getfield(b, n))
      else
        getfield(b, n)
      end
    else
      getfield(a, n)
    end
  end
  NamedTuple{names, types}(map(resolve, names))::NamedTuple{names, types} # Inference fails without this
end

"Symbol concatenation"
x::Symbol *ₛ y::Symbol = Symbol(string(x), string(y)) # Is there better way?