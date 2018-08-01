# Inference

Omega have several inference algorithms built in, and provides the mechanism to build your own.

## Conditional Samples

If you have a random variable `x` and a Boolean-valued random variable `y`, to sample from a conditional distribution use `rand(x,y)`.

```@docs
Omega.rand
```

For example:

```julia
weight = β(2.0, 2.0)
x = bernoulli()
rand(weight, x == 0)
```

To sample from more than one random variable, just pass a tuple of `RandVar`s to `rand`, e.g.:

```julia
weight = β(2.0, 2.0)
x = bernoulli()
rand(weight, x == 0)
```

## Conditioning with `cond` 

`rand(x, y)` is simply a shorter way of saying `rand(cond(x, y))`.
That is, the mechanism for inference in Omega is conditioning random variables:

```@docs
cond
```

## Conditioning as Prior
Conditioning Random Variables allows you to add constraints to your mode.

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
cond(poission(1.0), iseven
```

```julia
ispos(x) = x > 0.0
weight = cond(normal(72, 1.0), ispos)
height = cond(normal(1.78, 1.0), ispos)
bmi = weight / height
```

`bmi` is a function of both `weight` and `height`, both of which have their own conditions.
Omega automatically propagates the conditions from `weight` and `height` onto `bmi`, so that if we sample from all of them with 

`rand((bmi, weight, height), alg = Rejection))`

