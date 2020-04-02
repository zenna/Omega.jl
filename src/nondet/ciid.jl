"""`ciid(f)`

`RandVar` that is __c__onditionally __i__ndependent given its parents, but __i__dentically  __d__istributed to `f`

`ciid` is the primary mechanism to construct a `RandVar` from a function.

```julia
function x_(ω)
  x = normal(ω, 0, 1)
end
x = ciid(x_)
rand(x)
```

__Important:__  any parents of `f` are shared.
That is, if `X` is a `RandVar`, then `X(ω)` will return the same value from
whatever context it is called.

Example:


```julia
numflips = poisson(2)

flips_(ω) = [bernoulli(ω, 0.5, Bool) for i = 1:numflips(ω)]
flips = ciid(flips_)

"At least one of numflips is true"
anyheads_(ω) = any(flips(ω))
anyheads = ciid(anyheads_)

"All flips are true"
allheads_(ω) = all(flips(ω))
allheads = ciid(allheads_)  # `allheads` and `anyheads` share `flips`

rand((numflips, flips, anyheads, allheads))
```
"""
ciid(f; id = uid()) = URandVar(f, (), id)

"ciid(x::RandVar) \n\n  `RandVar` identically distributed to `x` but conditionally independent given parents`"
ciid(x::T; id = uid()) where T <: RandVar =  T(params(x)..., id)
@spec equaldist(x, _res)

"""$(SIGNATURES) ciid with arguments

If arguments are random variables they are resolved to values.

Equivalent to:

`ciid(ω -> f(ω, (arg isa RandVar ? arg(ω) : arg for arg in args)...))`

Example:

```julia
function f_(ω, n)
  x = 0.0
  for i = 1:n
    x += uniform(ω, 0, 1)
  end
  x
end

f = ciid(f_, poisson(3))
```
"""
ciid(f, args...; id = uid()) = URandVar(reifyapply, (f, args...), id)

@inline reifyapply(ωπ, f, args...) = f(ωπ, reify(ωπ, args)...)
@inline reifyapply(ωπ, f) = f(ωπ)

Base.:~(x::Function) = ciid(x)
Base.:~(id::ID, x::Function) = ciid(x; id = id)
Base.:~(id, x::Function) = ciid(x; id = toid(id))
