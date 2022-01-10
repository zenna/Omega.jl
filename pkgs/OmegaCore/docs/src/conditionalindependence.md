# Conditional Independence

It is useful to create both independent and conditionally independent random variables.


- A __class__ in Omega is simply a function of the type `f(::id, ω::Ω)`.
- `ω -> f(i, ω)` is a random variable that is the `i`th member of that class
- short hand for this is `i ~ f`
- All members of that class are conditionally independent
- Omega has a number of primitive distribution classes.  For example `StdUniform` and `StdNormal`.

Example

```
f = 1 ~ StdNormal{Float64}()
randsample(f)
```

To create your own class

```
function f(id, x)
  a = (id, 1) ~ Normal(0, 1)
  b = (id, 2) ~ Normal(0, 2)
end
```

!!! note
    **TLDR**: `ciid(id, f)` or `id ~ f` to construct the idth element of a class.

    ```




Previously we saw that we could use `ciid` to turn a function rng into a `RandVar`.
Here we cover the meaning of ciid.
Use `ciid(x)` to create a random variable that is identical in distribution to `x` but conditionally independent given its parents.

```julia
μ = uniform(0.0, 1.0)
y1 = normal(μ, 1.0)
y2 =~ y1
rand((y1, y2))
```

```@docs
ciid
```