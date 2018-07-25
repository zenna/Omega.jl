# Causal Inference

Omega supports causal inference through the `change` or `←` function and higher-order causal inference through the random interventional distribution

Causal inference is a topic of much confusion, we recommend this blog

Causal inference is implemented in Omega with the `do` operator.

## The do operator

In Omega we use the syntax:

```julia
X | θold => θnew
```
To mean the random variable `X` where `θold` has been replaced with `θnew`.

Let's look at an example:

```julia
μ = normal(0.0, 1.0)
x = normal(μ, 1.0)
xnew = x | θold ← θnew
rand((x, xnew))
```
