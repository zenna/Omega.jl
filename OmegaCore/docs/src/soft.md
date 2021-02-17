# Soft Execution

!!! note
    **TLDR**: For inference problems which are continuous or high dimensional, use soft predicates to use more efficient inference routines.

    ```@docs
    ==ₛ
    >ₛ
    >=
    <=ₛ
    <ₛ
    ```

    Soft predicates are supported (and required) by inference algorithms: SSMH, HMCFAST, NUTS, Replica.

    If the values `x` and `y` are not standard numeric types you will need to define a notion of distance (even if they are, you may want to wrap them and define a distance for this type).  Override `Omega.d` for the relevant types

    ```@docs
    Omega.d(x, y)
    ```

## Relaxation
In Omega you condition on predicates.
A predicate is any function whose domain is `Boolean`.
These are sometimes called indicator functions or characteristic functions.
In particular, in Omega we condition on `Bool` valued random variables:

```julia
x = normal(0.0, 1.0)
y = x == 1.0
rand(y)
```

From this perspective, conditioning means to solve a constraint.
It can be difficult to solve these constraints exactly, and so Omega supports softened constraints to make inference more tractable.

To soften predicates, use soft counterparts to primitive predicates.
Suppose we construct a random variable of the form `x == y`.
In the soft version we would write `x ==ₛ y` (or `softeq(x, y)`).

```julia
julia> x = normal(0.0, 1.0)
julia> y = x ==ₛ 1.0
julia> rand(y)
ϵ:-47439.72956833765
```

!!! note

    In the Julia REPL and most IDEs ==ₛ is constructed by typing ==\\_s [tab].

Softened predicates return values in unit interval `[0, 1]` as opposed to a simply `true` or `false`.
Intuitively, `1` corresponds to `true`, and a high value (such as 0.999) corresonds to "nearly true".
In practice, we encode this number in log scale `[-Inf, 0]` for numerical reasons.
Mathematicallty, soft predicates they have the form:

```math
k_\alpha(\rho(x, y))
```

If ``\rho(x, y)`` denotes a notion of distance between ``x`` and ``y``.
Distances are determined by the method `Omega.d`

```@docs
Omega.d
```

Rather than output values of type `Float64`, soft predicate output values of type `SoftBool`.

```@docs
SoftBool
```

## Distances and Kernels

Omega has a number of built-in kernels:

```@docs
kse
kf1
kpareto
```

By default, the squared exponential kernel `kse` is used with a default temperature parameter.
The method `withkernel` can be used to choose which kernel is being applied within the context of a soft boolean operator.

```@docs
withkernel
```