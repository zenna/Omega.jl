# Omega.jl

| **Documentation**                       | **Build Status**                                                                                |
|:--------------------------------------- |:----------------------------------------------------------------------------------------------- |
| [![][docs-latest-img]][docs-latest-url] | [![][travis-img]][travis-url] [![][codecov-img]][codecov-url] |

Omega is a library for causal and probabilistic inference in Julia.

# Quick start

## Install

Omega is built in Julia 0.7 but not yet in the official Julia Package repository.  You can still easily install it from a Julia repl with:

```julia
(v0.7) pkg> add https://github.com/zenna/Omega.jl.git
```

Check Omega is working and gives reasonable results with: 

```julia
julia> using Omega

julia> rand(normal(0.0, 1.0))
0.7625637212030862
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


In this case, `rand` takes
- A random variable we want to sample from
- A predicate (type `RandVar{Bool}`) that we want to condition on, i.e. assert that it is true
- An inference algorithm.  Here we use rejction sampling

Plot a histogram of the weights like before:

```
julia> UnicodePlots.histogram(weight_samples)
             ┌────────────────────────────────────────┐ 
   (0.1,0.2] │▇ 4                                     │ 
   (0.2,0.3] │▇▇▇ 22                                  │ 
   (0.3,0.4] │▇▇▇▇▇▇▇▇▇▇▇ 69                          │ 
   (0.4,0.5] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 147             │ 
   (0.5,0.6] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 185       │ 
   (0.6,0.7] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 226 │ 
   (0.7,0.8] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 203     │ 
   (0.8,0.9] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 120                 │ 
   (0.9,1.0] │▇▇▇▇ 23                                 │ 
             └────────────────────────────────────────┘ 

```

Observe that our belief about the weight has now changed.
We are more convinced the coin is biased towards heads (`true`)


[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-latest-url]: https://zenna.github.io/Omega.jl/latest

[travis-img]: https://travis-ci.org/zenna/Omega.jl.svg?branch=master
[travis-url]: https://travis-ci.org/zenna/Omega.jl

[codecov-img]: https://codecov.io/github/zenna/Omega.jl/coverage.svg?branch=master
[codecov-url]: http://codecov.io/github/zenna/Omega.jl?branch=master
