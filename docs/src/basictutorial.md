# Basic Tutorial

In this tutorial we will run through the basics of creating a model and conditioning it.
This tutorial is available in [notebook version](https://github.com/zenna/OmegaModels.jl/blob/master/models/small/coin.ipynb).

First load Omega:

```julia
using Omega
```
If you tossed a coin and observed the sequqnce `HHHHH`, you would be a little suspicious, `HHHHHHHH` would make you very suspicious.
Elementary probability theory tells us that for a fair coin, `HHHHHHHH` is just a likely outcome as `HHTTHHTH`.  What gives?
 We will use Omega to model this behaviour, and see how that belief about a coin changes after observing a number of tosses.

Model the coin as a bernoulli distribution.  The weight of a bernoulli determines the probability it comes up true (which represents heads). Use a [beta distribution](https://en.wikipedia.org/wiki/Beta_distribution) to represent our prior belief weight of the coin.

```julia
weight = β(2.0, 2.0)
```

A beta distribution is appropriate here because it is bounded between 0 and 1. 

Draw a 10000 samples from `weight` using `rand`:

```julia
beta_samples = rand(weight, 10000)
```

Let's see what this distribution looks like using UnicodePlots.  If you don't have it installed already install with:

```julia
] add UnicodePlots
```

To visualize the distribution, plot a histogram of the samples:

```julia
using UnicodePlots
UnicodePlots.histogram(beta_samples)
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

The distribution is symmetric around 0.5 and has support over the the interval [0, 1].

So far we have not done anything we couldn't do with `Distributions.jl`.
A primary distinction between a package like `Distribution.jl`, is that `Omega.jl` allows you to __condition__ probability distributions.

Create a model representing four flips of the coin.
Since a coin can be heads or tales, the appropriate distribution is the [bernouli distribution](https://en.wikipedia.org/wiki/Bernoulli_distribution):


```julia
nflips = 4
coinflips_ = [bernoulli(weight, Bool) for i = 1:nflips]
```

Take note that `weight` is the random variable defined previously.
`bernoulli` takes a type as its secoond argument; `Bool` indicates the result will be a `Bool` rather than an `Int`.

`coinflips` is a normal Julia array of Random Variables (`RandVar`s).
For reasons we will elaborate in later sections, it will be useful to have an `Array`-valued `RandVar` (instead of an `Array` of `RandVar`).

One way to do this (there are several ways discuseed later), is to use the function `randarray`

```julia
coinflips = randarray(coinflips_)
```

`coinflips` is a `RandVar` and hence we can sample from it with `rand`

```julia
julia> rand(coinflips)
4-element Array{Bool,1}:
  true
 false
 false
 false
```

Now we can condition the model.
We want to find the conditional distribution over the weight of the coin given some observations.

First create some fake data
```julia
observations = [true, true, true, false]
```

Create a predicate that tests whether simulating from the model matches the observed data:

```julia
condition = coinflips ==ᵣ observations
```

`condition` is a random variable; we can sample from it.  The function `==ᵣ` (and more generally functions subscripted with ᵣ) should be read as "a realization of coinflips == observations"

We can use `rand` to sample from the model conditioned on `condition` being true:

```julia
weight_samples = rand(weight, condition, 10; alg = RejectionSample)
```

`weight_samples` is a set of `10` samples from the conditional (sometimes called posterior) distribution of `weight` condition on the fact that coinflips == observations.

In this case, `rand` takes
- A random variable we want to sample from
- A predicate (type `RandVar` which evaluates to a `Bool`) that we want to condition on, i.e. assert that it is true
- An inference algorithm.  Here we use rejection sampling.

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
We are more convinced the coin is biased towards heads (`true`).