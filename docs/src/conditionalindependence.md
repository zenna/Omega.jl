# Conditional Independence


!!! note
    **TLDR**: Use `ciid` to convert a function `f(ω::) = ...` into a `RandVar`.
    If the function calls other random variables

    ```

Previously we saw that we could use `ciid` to turn a function rng into a `RandVar`.
Here we cover the meaning of ciid.
Use `ciid(x)` to create a random variable that is identical in distribution to `x` but conditionally independent given its parents.

```julia
μ = uniform(0.0, 1.0)
y1 = normal(μ, 1.0)
y2 = ciid(y1)
rand((y1, y2))
```

```@docs
ciid
```