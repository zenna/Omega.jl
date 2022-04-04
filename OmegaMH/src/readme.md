# Conditioning in Omega

Conditioning is designed to meet a number of objectives:

## Basic Mechanism

Conditioning is an operation that transforms random variables.  If `Y` is a random variable (of arbitrary type) and `E` is a random variable of Boolean type then `cond(Y, E)` is a conditioned random variable.

All random variables, including `Y` and `E` are functions of the output of exogenous variables `U_1, U_2, ..., U_n`.  Conditioning restricts the values `Y` can take, which in turn restricts the values that each `U_i` can take.

Most inference algorithms require that we can do two things:
1. Compute the log energy (aka unnormalized density) `e = ℓ/Z` where `ℓ` is the joint logdensity and `Z` is some normalizing constant.

Prior to conditioning, since exogenous variables are independent, their joint density is just the product of the individual terms:

`logenergy(ω) = sum(logenergy(ωi, vi) for (ωi, vi) in ω)`

After conditioning, the value of `e` changes because `Z` changes, but `ℓ` does not change.

This does __not__ mean that the joint density of non-exogenous variables will remain the same, in general they will change.  That's kind of the point.

Conditioning  of the sample space to a subset.

- Q: What variable are we allowed to make proposals on?
  - Primitives -the thing that makes a primitive a primitive is that we know:
    - How to go from a conditioned value to the exogenous variables
    - How to compute logpdf of different values
  - Any random variable as in function from ω
  - Long term goal, any value, including intermediate ones
- Q: If we can change any variable, how do we propagate back to the exogenous variables?
  - Well..., let'
- Q: Does ω store only exogenous variables?
- Q: Does conditioning require more than setting a value in ω?

## Proposals

2. A proposal distribution 

Proposals are transformations that map `ω` to `ω'`

Examples:

In this example, if we condition `f`, say to 100, the value of `A` is determined, as is the corresponding exogenous variable

```julia
A = 1 ~ Normal(0, 1)
function f(ω)
  sqrt(A(ω))
end 
```

Consider an extension below:

```julia
g(ω) = f(ω) + (2 ~ Normal(0, 1))(ω)
```

Here, if `g` is conditioned, we could propose a value for `f`, and then the value of the inner Normal would be determined, as would its exogenous variable.
Or we could propose a value for the Normal, and compute the corresponding value for `f`


```julia
n = 2 ~ Normal(0, 1)
subpropose(rng, g::typeof(g), ω) =
    (θ = randn(rng); (f => ω[g] - θ, n => θ)) 
```