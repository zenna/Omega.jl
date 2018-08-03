# Conditionally Independence

Previously we saw that we could use `ciid` to turn a function rng into a `RandVar`.

## Independent Random Variables

Use `iid(x)` to create a random variable that is identical in distribution to `x` but but independent.

## Conditionally Independent Random Variables

Use `ciid(x)` to create a random variable that is identical in distribution to `x` but conditionally independent given its parents.

```julia
μ = uniform(0.0, 1.0)
y1 = normal(μ, 1.0)
y2 = ciid(y1)
rand((y1, y2))
```