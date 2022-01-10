export share
"""
`share(f)`

If `f` is a variable that you want to be shared as the parent of many other
variables within a class, use `share(f)(ω)` instead of `f(ω)`.

Suppose we have the following model:
```julia
x = ~ Normal(0, 1)
function f(ω)
  a = ~ Normal(0, 0.001)(ω) + a(ω)
end
f1 = ~ f
f2 = ~ f
f3 = ~ f
randsample((f1, f2, f3))
```

We are hoping that `f1`, `f2` and `f3` will have `a` as a parent.
But this won't be the case; they will instead be completely independent.

Tp ensure that `a` is a shared parent of them all use `shared`

```julia
x = ~ Normal(0, 1)
function f(ω)
  a = ~ Normal(0, 0.001)(ω) + share(a)(ω)
end
f1 = ~ f
f2 = ~ f
f3 = ~ f
randsample((f1, f2, f3))
```
"""
@inline share(f) = ω -> f(rmscope(ω))
