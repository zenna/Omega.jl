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

    Soft predicates are supported (and required) by inference algorithms: SSMH, HMC, HMCFAST, MI.

    If the values `x` and `y` are not standard numeric types you will need to define a notion of distance (even if they are, you may want to wrap them and define a distance for this type).  Override `Omega.d` for the relevant types

    ```@docs
    Omega.d
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

There are two ways to make soft constraints.  The first way is explicitly:

```julia
julia> x = normal(0.0, 1.0)
julia> y = x ==ₛ 1.0
julia> rand(y)
ϵ:-47439.72956833765
```

Suppose we construct a random variable of the form `x == y`.
In the soft version we would write `x ==ₛ y` (or `softeq(x, y)`).

!!! note

    In the Julia REPL and most IDEs ==ₛ is constructed by typing ==\_s [tab].

Softened predicates return values in unit interval `[0, 1]` as opposed to a simply `true` or `false`.
Intuitively, `1` corresponds to `true`, and a high value (such as 0.999) corresonds to "nearly true".
Mathematicallty, they have the form:

```math
k(\rho(x, y))
```

If ``\rho(x, y)`` denote a notion of distance between ``x`` and ``y``.

Rather than actually output values of type `Float64`, soft predicate output values of type `SoftBool`.
As stated a `SoftBool` represents a value in `[0, 1]`, but in log scale for numerical reasons.

```@docs
SoftBool
```

## Controlling the kernel

Omega has a number of built-in kernels:

```@docs
kse
kf1
kpareto
```

By default, the squared exponential kernel is used with a default temperature parameter.
The method `withkernel` can be used to choose which kernel is being applied within the context of a soft boolean operator.

```@docs
withkernel
```