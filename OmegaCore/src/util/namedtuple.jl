export rmkey, update, mergef

"""
Remove a `key` from named tuple `nt` has been removed

```jldoctest
x = (a = 3, b = 4, c =12)
rmkey(tag, Val{:c})
(a = 3, b = 4)
```
"""
@generated function rmkey(nt::NamedTuple{K, V}, key::Type{Val{T}}) where {K, V, T}
  T isa Symbol || throw(ArgumentError("Usage: `rmkey(x, Val{:X})`"))
  # args = [:($k = nt.$k) for k in K if k != T]
  ks = tuple((k for k in K if k != T)...)
  vs = [:(nt.$k) for k in K if k != T]
  # FIXME: This can be made more efficient, using TAGS  
  # Expr(:tuple, args...)
  :(NamedTuple{$ks}(($(vs...),)))
end


@post keys(@ret) == setdiff(keys(nt), key)
@post all([res[k] == nt[k] for k in setdiff(keys(nt), key)])

"""
Update a named tuple

```
update((x = 3, y = 2, z = 1), Val{:x}, 7)
(x = 7, y = 2, z = 1)
```

"""
@generated function update(nt::NamedTuple{K, V}, key::Type{Val{T}}, val) where {K, V, T}
  args = []
  for k in K
    if k == T
      push!(args, :($k = val))
    else
      push!(args, :($k = nt.$k))
    end
  end
  Expr(:tuple, args...)
end
@post keys(res) == keys(nt)
@post all([res[k] == nt[k] for k in setdiff(keys(nt), key)])
@post res[key] == val


"""
Merge `nt1` with `nt2`.
For each key :key_i which clashes (is in both `n1` and `n2`), returns 
`f(:Val{:key_i}, nt1.key_i, nt2.key_i)`

```
nt1 = (x = 2, y = 4)
nt2 = (x = 4, a = 2)
mergef(f, nt1, nt2)
```
"""
@generated function mergef(f, nt1::NamedTuple{K1, V1}, nt2::NamedTuple{K2, V2}) where {K1, K2, V1, V2}
  if isempty(K1 ∩ K2)
    :(merge(nt1, nt2))
  else
    :(f(nt1, nt2))
  end
end

@post keys(res) == keys(nt1) ∪ keys(nt2)
@post all((res[k] == nt1[k] for k in keys if k in nt1 && k ∉ nt2))
@post all((res[k] == nt2[k] for k in keys if k in nt2 && k ∉ nt1))
@post all((res[k] == f(nt1[k], nt2[k]) for k in keys if k in nt1 && k ∉ nt2))
