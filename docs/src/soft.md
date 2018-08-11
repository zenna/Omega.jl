# Soft Execution

## TLDR
For inference problems which are continuous or high dimensional, use soft predicates to use more efficient inference routines.

```@docs
==
>ₛ
>=
<=ₛ
<ₛ
```

If the values `x` and `y` are not standard numeric types you will need to define a notation of distance.  Override `Omega.d`

```@docs
d
```

For example:
```julia
struct
  
end
```

## Relaxation
In Omega you condition on predicates.
A predicate is any function whose domain is `Boolean`.
These are sometimes called indicator functions, or characteristic functions.
In particular, in Omega we condition on `Bool` valued random variables:

```julia
x = normal(0.0, 1.0)
y = x == 1.0
rand(y)
```

From this perspective, conditioning means to solve a constraint.
It can be difficult to solve these constraints exactly, and so Omega supports softened constraints to make inference more tractable.

There are two ways to make soft constraints.  The first way is explicitly:

```julia
julia> x = normal(0.0, 1.0)
julia> y = x ≊ 1.0
julia> rand(y)
ϵ:-47439.72956833765
```

Suppose we construct a random variable of the form `x == y`.
The soft version we would write `x ==\_s y` (or `softeq(x, y)`).
These softened functions have the form:

If \rho(x, y) denote a distance between `x` and `y`.

$$
k(\rho(x, y))
$$

```

## Controlling the kernel


Omega has a number of built-in kernels:

```@docs
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

