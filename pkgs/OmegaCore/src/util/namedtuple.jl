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

@pre rmkey(nt, key) = key in keys(nt) "Key `key` not in `nt`"
@post rmkey(nt, key) = keys(__ret__) == setdiff(keys(nt), key) "Keys of returned nt same as nt minus key"
@post rmkey(nt, key) = all([__ret__[k] == nt[k] for k in __ret__]) "Values of returned nt same as nt minus key"

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
  # FIXME, return named tuple
  Expr(:tuple, args...)
end
@post update(nt, key) = keys(__ret__) == keys(nt) "Keys of returned nt same as nt"
@post update(nt, key) = all([__ret__[k] == nt[k] for k in setdiff(keys(nt), key)])
@post update(nt, key) = __ret__[key] == val "Value of key updated in result"

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

@post mergef(f, nt1, nt2) = keys(__ret__) == keys(nt1) ∪ keys(nt2)
@post mergef(f, nt1, nt2) = all((__ret__[k] == nt1[k] for k in keys if k in nt1 && k ∉ nt2))
@post mergef(f, nt1, nt2) = all((__ret__[k] == nt2[k] for k in keys if k in nt2 && k ∉ nt1))
@post mergef(f, nt1, nt2) = all((__ret__[k] == f(nt1[k], nt2[k]) for k in keys if k in nt1 && k ∉ nt2))