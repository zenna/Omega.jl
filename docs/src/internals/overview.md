# Omega Internals

Omega is a library for causal and probabilistic inference in Julia.  It shares many characteristics with other probabilistic languages, such as Pyro, Gen, Stan, and Turing, but has a few important differences.  At a high level, the salient properties of Omega are that:


<!-- The conceptual model of Omega could be summarized as follows: -->


## Random Variables

A very important type of object in Omega is a *random variable*.  The simplest kind of random variable is a primitive random variable.  There is an infintie set of primitive variables, that are all mutually independent.  Random variables in this set can be constructed using `~`.  For example:

```julia
ID = 1
X = ID ~ StdUniform{Float64}()
```

`StdUniform{Flaot64}` is a singleton type -- it has a single element `StdUniform{Float64}()`.

A random variable in Omega is a function of the form

```math
X : \Omega \to T
```

In Julia, a random variable is any function `X` such that `X(\omega::AbstractΩ)` is well-defined, that is, the method exists, and `X(\omega::AbstractΩ)` for all \omega::AbstractΩ is well-defined.

For those familiar with other probabilistic programming languages, the conceptual differences with Omega are that:
1. Omega random variables are pure functions
2. 

### Patterns
```
μ = ~ Normal(0, 1)
X1 = Normal(μ, 1)
X2 = Normal(μ, 1)
X3 = Normal(μ, 1)
```


### Sampling
Unlike other PPLs, random variables in Omega are not smaplers themselves, per-se.  They can be sampled from, using `randsample`.

```julia
X = ID ~ StdUniform{Float64}()
randsample(X)
```

### Distribution Families

### Probabilistic Models
In Omega, there is no explicit notion of a probabilistic model, there are only random variables.
Conceptually, it can be useful to think of a probabilsitic model as a collection of random variables.

## Independence and Conditional Independence

When constructing a probabilistic model, it's common to want to:
1. Construct multiple random variables that are 
2. 

## Conditioning
In Omega, conditioning is a process that transforms a random variable into a new one.

Conditioning is performed by a function `cnd`, which naturally has the type:

```math
cnd : (\Omega \to T) \times (\Omega \to Bool) \to (\Omega \to T)
```

## Likelihood-free inference

## Likelihood-based inference

## Higher-order Inference

## Interventnions