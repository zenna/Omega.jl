# Inference

!!! note
    **TLDR**: `randsample(x |ᶜ y, n; alg = alg)` draws `n` samples from `x` conditioned on `y` using `alg` is the inference procedure.
    ```

The primary purpose of building a probabilistic model is to use it for inference.
The kind of inference we shall describe is called posterior inference, Bayesian inference, conditional inference or simply probabilistic inference.

## Conditional Sampling Algorithms

While there are several kinds of thing you might like to know about a conditional distribution (such as its mode), __conditional sampling__ is one of the most useful.
To sample from a conditional distribution: pass the conditioned random variable to the first aragument of `randsample`

```julia
using Omega, Distributions
weight = @~ Beta(2.0, 2.0)
x = @~ Bernoulli.(weight)
nsamples = 1000
randsample(weight |ᶜ x, nsamples; alg = RejectionSample)
```

It is fine to condition random variables on equalities or inequalities:

```julia
x1 = @~ Normal(0.0, 1.0)
randsample(x1 |ᶜ (x1 .> 0), 1000; alg = RejectionSample)
```

It's also fine to condition on functions of multiple variables

```julia
x1 = @~ Normal(0.0, 1)
x2 = @~ Normal(0.0, 10)
randsample(@joint(x1, x2) |ᶜ (x1 .> x2), 1000; alg = RejectionSample)
```

Note: to sample from more than one random variable, just pass a tuple of `RandVar`s to `rand`.

## Conditioning the Prior

In Bayesian inference the term posterior distribution is often used instead of the conditional distribution.  Mathematically they are the same object, but posterior alludes to the fact that it is the distribution after (a posteriori) observing data. The distribution before observing data is often referred to as the prior.

However, conditioning is a more general concept than observing data, and we can meaningfully "condition the prior".

For example we can truncate a normal distribution through conditioning:

```julia
x = @~ Normal(0, 1)
x_ = x |ᶜ (x .> 0)
```

Or suppose we want a poisson distribution over the even numbers

```julia
julia> x = @~ Poisson(3.0)
julia> randsample(x |ᶜ iseven.(x), 5; alg = RejectionSample)
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
ispos(x) = x > 0
weight = @~ Normal(72, 1.0) |ᶜ ispos.(weight)
height = @~ Normal(1.78, 1.0) |ᶜ ispos.(height)
bmi = weight ./ height
```

`bmi` is a function of both `weight` and `height`, both of which have their own conditions (namely, they are positive).
Omega automatically propagates the conditions from `weight` and `height` onto `bmi`.
