# Inference

!!! note
    **TLDR**: `rand(x, y, n; alg = alg)` draws `n` samples from `x` (any `RandVar`) conditioned on `y` (any `RandVar` whose elementype is Bool) and `alg` is the inference procedure.
    ```


The primary purpose of building a probabilistic model is to use it for inference.
The kind of inference we shall describe is called posterior inference, Bayesian inference, conditional inference or simply probabilistic inference.

## Conditional Sampling Algorithms

While there are several kinds of thing you might like to know about a conditional distribution (such as its mode), currently, all inference algorithms perform conditional sampling only.
To sample from a conditional distribution: pass two random variables to `rand`, the distribution you want to sample from, and the predicate you want to condition on. For example:

```julia
weight = β(2.0, 2.0)
x = bernoulli()
rand(weight, x == 0)
```

It is fine to condition random variables on equalities or inequalities:

```julia
x1 = normal(0.0, 1.0)
rand(x1, x1 > 0.0)
```

It's also fine to condition on functions of multiple variables

```julia
x1 = normal(0.0, 1.0)
x2 = normal(0.0, 10)
rand((x1, x2), x1 > x2)
```

Note: to sample from more than one random variable, just pass a tuple of `RandVar`s to `rand`.

## Conditioning with `cond` 

`rand(x, y)` is simply a shorter way of saying `rand(cond(x, y))`.
That is, the primary mechanism for inference in Omega is conditioning random variables using `cond`.

```@docs
cond(::RandVar, ::RandVar)
```

## Conditioning the Prior

In Bayesian inference the term posterior distribution is often used instead of of the term conditional distribution.  Mathematically they are the same object, but posterior alludes to the fact that it is the distribution after (a posteriori) observing data. The distribution before observing data is often referred to as the prior.

However, conditioning is a more general concept than observing data, and we can meaningfully "condition the prior".

For example we can truncate a normal distribution through conditioning:

```julia
x = normal(0.0, 1.0)
x_ = cond(x, x > 0.0)
```

A shorter way to write this is to pass a unary function as the second argument to `cond`

```julia
x = cond(normal(0.0, 1.0), rv -> rv > 0.0)
```

Or suppose we want a poisson distribution over the even numbers

```julia
julia> x = cond(poisson(3.0), iseven)
julia> rand(x, 5; alg = RejectionSample)
5-element Array{Int64,1}:
 2
 6
 2
 4
 0
```

## Conditions Propagate
When you compose conditoned random variables together, their conditions propagate.  That is, if `θ` is conditioned, and `x` depends on `θ`, then `x` inherits all the conditions of `θ` automatically.  For example:

```julia
ispos(x) = x > 0.0
weight = cond(normal(72, 1.0), ispos)
height = cond(normal(1.78, 1.0), ispos)
bmi = weight / height
```

`bmi` is a function of both `weight` and `height`, both of which have their own conditions (namely, they are positive).
Omega automatically propagates the conditions from `weight` and `height` onto `bmi`.