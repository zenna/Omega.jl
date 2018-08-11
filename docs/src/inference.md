# Inference

The primary purpose of building a probabilistic model is to use it for inference.

## Conditional Sampling Algorithms

While there are several kinds of things you would like to know about a conditional distribution (e.g., its mode) currently, all inference algorithms perform conditional sampling only.
To sample from a conditional distribution: pass two random variables to `rand`, the distribution you want to sample from, and the predicate you want to condition on. For example:

```julia
weight = β(2.0, 2.0)
x = bernoulli()
rand(weight, x == 0)
```

It is fine to condition random variables on equalities or inequalities:

```julia
x1 = normal(0.0, 1.0)
x2 = normal(0.0, 10)
rand((x1, x2), x1 + x2 > == 0.0)
```

Note: to sample from more than one random variable, just pass a tuple of `RandVar`s to `rand`, e.g.:

```@docs
Omega.rand
```

## Conditioning with `cond` 

`rand(x, y)` is simply a shorter way of saying `rand(cond(x, y))`.
That is, the primary mechanism for inference in Omega is conditioning random variables using `cond`.

```@docs
cond
```

## Conditioning the Prior
In Bayesian inference the term posterior distribution is often used instead of conditional distribution.  Mathematically they are the same objec, but posterior alludes to the fact that it is the distribution after (post) observing data. Prior to observing data, your distribution is the prior.

However, conditioning is a more general concept than observing data, and we can meaningfully "condition the prior".

For example we can make a truncated normal distribution with:

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
cond(poission(1.0), iseven)
```

## Conditions Propagate
When you compose condiitoned random variables together, their conditions propagate.  That is, if `x` is conditioned, and `y` is conditioned, and `z` depends on `x` and `y`, then `z` inherits all the conditions of `x` and `y` automatically.  For example:

```julia
ispos(x) = x > 0.0
weight = cond(normal(72, 1.0), ispos)
height = cond(normal(1.78, 1.0), ispos)
bmi = weight / height
```

`bmi` is a function of both `weight` and `height`, both of which have their own conditions (namely, they are positive).
Omega automatically propagates the conditions from `weight` and `height` onto `bmi` respects these conditions.