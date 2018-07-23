# Soft Execution

In Omega you condition on predicates.
A predicate is any function whose domain is the `Boolean`.
These are sometimes called indicator functions, or characteristic functions.
In particular, in Omega we condition on `Bool` valued random variables:

```julia
x = normal(0.0, 1.0)
y = x == 1.0
rand(y)
```

From this perspective, conditioning means to solve a constraint.
It can be difficult to solve these constraints exactly, and so Omega can soften constraints to make inference more tractable.

There are two ways to make soft constraints.  The first way is explicitly:

```julia
julia> x = normal(0.0, 1.0)
julia> y = x ≊ 1.0
julia> rand(y)
ϵ:-47439.72956833765
```

These soft kernels have the form

MATH HERE

```
withkernel
```

Omega has a number of built-in kernels:

```@doc
kse
```

## Soft Function Application
There are a couple of drawbacks from explicitly using soft constraints in the model:

1. We have changed the model for what is a problem of inference
2. Often we may be using pre-existing code and not be able to easily replace all the constraints with soft constraints

Omega has an experimental feature which automatically does soft execution of a normal predicate.  Soft application relies on e

```julia
julia> g(x::Real)::Bool = x > 0.5
julia> softapply(g, 0.3)
ϵ:-2000.0
```

This feature is experimental because Cassette is waiting on a number of compiler optimizations to make this efficient.

