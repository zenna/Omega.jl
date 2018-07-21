# Omega.jl

[![Build Status](https://travis-ci.org/zenna/Omega.jl.svg?branch=master)](https://travis-ci.org/zenna/Omega.jl)

[![codecov.io](http://codecov.io/github/zenna/Omega.jl/coverage.svg?branch=master)](http://codecov.io/github/zenna/Omega.jl?branch=master)

Minimal but flexible probabilistic programming language

# Documentation

<!-- [![](https://img.shields.io/badge/docs-stable-blue.svg)](https://zenna.github.io/Omega.jl/stable) -->
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://zenna.github.io/Omega.jl/latest)

# Quick start

First import Omega:

```julia
using Omega
```

## Basic Tutorial

In this tutorial we will run through the basics of creating a model and conditioning it.

First let's load Omega:

```julia
using Omega
```

Next, create a beta-bernoulli distribution.
This means, our prior belief about the weight of the coin is [beta](https://en.wikipedia.org/wiki/Beta_distribution) distributed.
A beta distribution is useful because it is continuous and bounded between 0 and 1. 

```julia
weight = betarv(2.0, 2.0)
```

Draw a 10000 samples from `weight` using `rand`

```julia
beta_samples = rand(weight, 10000)
```

Let's see what this distribution looks like using UnicodePlots.  If you don't hae it installed alreay install with:

```julia
(v0.7) pkg> add UnicodePlots
```

To visualize the distribution, plot a histogram of the samples.

```julia
julia> UnicodePlots.histogram(beta_samples)
```

```
             ┌────────────────────────────────────────┐ 
   (0.0,0.1] │▇▇▇▇▇▇ 279                              │ 
   (0.1,0.2] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 727                   │ 
   (0.2,0.3] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1218       │ 
   (0.3,0.4] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1354    │ 
   (0.4,0.5] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1482 │ 
   (0.5,0.6] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1426  │ 
   (0.6,0.7] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1406   │ 
   (0.7,0.8] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1124         │ 
   (0.8,0.9] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 702                    │ 
   (0.9,1.0] │▇▇▇▇▇▇ 282                              │ 
             └────────────────────────────────────────┘
```

The distribution is symmetric around 0.5 but there is nonzero probability that the weight could be anything between 0 and 1.

So far we have not done anything we couldn't do with `Distributions.jl`.

We will create a model representing four flips of the coin.
Since a coin can be heads or tales, the appropriate distribution is the [bernouli distribution](https://en.wikipedia.org/wiki/Bernoulli_distribution):


```julia
nflips = 4
coinflips_ = [bernoulli(weight) for i = 1:nflips]
```

Take note that the `weight` is the random variable defined previously.

`coinflips` is a normal Julia array of Random Variables (`RandVar`s).
For reasons we will elaborate in later sections, it will be useful to have an `Array`-valued `RandVar` (instead of an `Array` of `RandVar`).

One way to do this (there are several ways discuseed later), is to use the function `randarray`

```julia
coinflips = randarray(coinflips)
```

`coinflips` is a `RandVar` and hence we can sample from it with `rand`

```julia
julia> rand(coinflips)
4-element Array{Float64,1}:
 0.0
 0.0
 0.0
 0.0

julia> rand(coinflips)
4-element Array{Float64,1}:
 0.0
 1.0
 0.0
 0.0

julia> rand(coinflips)
4-element Array{Float64,1}:
 1.0
 1.0
 1.0
 1.0
```

Now we can condition the model.
We want to find the conditional distribution over the weight of the coin given some observations.

First we create some fake data, and then use `rand` to draw conditional samples:

```julia
observations = [true, true, true, false]
weight_samples = rand(weight, coinflips == observations, RejectionSample)
```

In this case, `rand<!-- 
TODO: Describe Coin Model In English
TODO: Show Corresponding Omega progromam
- Demonstrate unconditional sampling with `rand`
- Demonstrate pointwise application
- Demonstrate Random Arrays -->
 takes
- A random variable<!-- 
TODO: Describe Coin Model In English
TODO: Show Corresponding Omega progromam
- Demonstrate unconditional sampling with `rand`
- Demonstrate pointwise application
- Demonstrate Random Arrays -->
we want to sample from
- A predicate (type<!-- 
TODO: Describe Coin Model In English
TODO: Show Corresponding Omega progromam
- Demonstrate unconditional sampling with `rand`
- Demonstrate pointwise application
- Demonstrate Random Arrays -->
`RandVar{Bool}`) that we want to condition on, i.e. assert that it is true
- An inference algo<!-- 
TODO: Describe Coin Model In English
TODO: Show Corresponding Omega progromam
- Demonstrate unconditional sampling with `rand`
- Demonstrate pointwise application
- Demonstrate Random Arrays -->
ithm.  Here we use rejction sampling

Plot a histogram of<!-- 
TODO: Describe Coin Model In English
TODO: Show Corresponding Omega progromam
- Demonstrate unconditional sampling with `rand`
- Demonstrate pointwise application
- Demonstrate Random Arrays -->
the weights like before:

```
julia> UnicodePlots<!-- 
TODO: Describe Coin Model In English
TODO: Show Corresponding Omega progromam
- Demonstrate unconditional sampling with `rand`
- Demonstrate pointwise application
- Demonstrate Random Arrays -->
histogram(weight_samples)
             ┌─────<!-- 
TODO: Describe Coin Model In English
TODO: Show Corresponding Omega progromam
- Demonstrate unconditional sampling with `rand`
- Demonstrate pointwise application
- Demonstrate Random Arrays -->
──────────────────────────────────┐ 
   (0.1,0.2] │▇ 4  <!-- 
TODO: Describe Coin Model In English
TODO: Show Corresponding Omega progromam
- Demonstrate unconditional sampling with `rand`
- Demonstrate pointwise application
- Demonstrate Random Arrays -->
                                  │ 
   (0.2,0.3] │▇▇▇ 2<!-- 
TODO: Describe Coin Model In English
TODO: Show Corresponding Omega progromam
- Demonstrate unconditional sampling with `rand`
- Demonstrate pointwise application
- Demonstrate Random Arrays -->
                                  │ 
   (0.3,0.4] │▇▇▇▇▇<!-- 
TODO: Describe Coin Model In English
TODO: Show Corresponding Omega progromam
- Demonstrate unconditional sampling with `rand`
- Demonstrate pointwise application
- Demonstrate Random Arrays -->
▇▇▇▇▇ 69                          │ 
   (0.4,0.5] │▇▇▇▇▇<!-- 
TODO: Describe Coin Model In English
TODO: Show Corresponding Omega progromam
- Demonstrate unconditional sampling with `rand`
- Demonstrate pointwise application
- Demonstrate Random Arrays -->
▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 147             │ 
   (0.5,0.6] │▇▇▇▇▇<!-- 
TODO: Describe Coin Model In English
TODO: Show Corresponding Omega progromam
- Demonstrate unconditional sampling with `rand`
- Demonstrate pointwise application
- Demonstrate Random Arrays -->
▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 185       │ 
   (0.6,0.7] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 226 │ 
   (0.7,0.8] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 203     │ 
   (0.8,0.9] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 120                 │ 
   (0.9,1.0] │▇▇▇▇ 23                                 │ 
             └────────────────────────────────────────┘ 

```

Observe that our belief about the weight has now changed.
We are more convinced the coin is biased towards heads (`true`)