# Cheat Sheet

## Core Functions
The major functions that you will use in Omega are:

- [ciid(x)]() : that is equal in distribution to `x` but conditionally independent given parents
- [cond(x, y)](inference.md#cond) : condition random variable `x` on condition `y`
- [cond(ω, ab)](inference.md#cond) : condition random variable that contains statement by force `ab` to be `true`]
- [rand(x, n; alg=Alg)](inference.md#cond) : `n` samples from (possibly conditioned) random variable `x` using algorithm `ALG`
- [replace(x, θold => θnew)](causal.md#replace) : causal intervention in random variable
- [rid(x, θ)]() : random interventional distribution of `x` given `θ`  
- [rcd(x, θ) or x ∥ θ]()  : random conditional distribution of `x` given `θ`

## FAQ

- How to sample from a joint distribution (more than one random variable at a time)?
Pass a tuple of random variables, e.g: `rand((x, y, z))`

- How do I apply transformation `f` to a random variable 
Some are already defined, e.g. `sqrt(uniform(0, 1))`, for everything else use `lift`, e.g. `lift(f(x))`

- What's the difference between Omega and Probabilistic Programming Language X

Omega is designed to be more expressive than other PPLs:
- Omega supports allows you to condition on predicates.  This is a form of likelihood-free inference
- Omega supports higher order inference
- Omega supports counterfactual inference
- Omega is fast (largely thank to Julia)
- Omega is type stable

The main techncial distinction between Omega and other PPLs is that Omega that both random variables (as opposed to stochastic samplers) and sample space objects are first class probabilistic constructs.  This choice makes the above features of Omega more straight-forward to implement. 

On the other hand:
- Omega does not support likeihood based inference (yet!)
- Omega does not support variational inference (yet!)
- Omega does not yet have as many inference algorithms implemented as other packages, e.g. Turing

## Terminology

- Causal Inference:
- Conditioning: Restricts a RandVar to be consistent with a predicate.  Conceptually, conditioning is the mechanism to add knowledge (observations, declarative facts, etcs) to a model.  
- Intervention: A change to a model.  Interventions support counterfactual "what if" questions. 
- Lift: To lift a function means to construct a new function that transforms random variables.
- Model: A collection of Random Variables.
- Prior: Unconditioned distribution.  In Bayesian inference terms, prior to having observed data
- Posterior: Technically identical to conditional distribution.  The term posterior is used commonly in the context of Bayesian inference where the conditional distribution is having observed more data.
- Random Variable: a random variable is one kind of representation of a probability distribution.
- Realization (or outcome) space: Space (or type) of values that a random variable can take.  Since Random Variable are functions, technically this is its domain.  In Omega: `elemtype(x)` is its realization space 
- Realization of a random variable: a value in the realization space, typically understood to be drawn according to its distribution.  In Omega, the result of `rand(x)` is a realizataion of `x`
- Probability Space: A tuple $(Ω, Σ, μ)$ where  $Ω$ is a sample space, Σ is a sigma algebra (roughly, set of all subsets of Ω, and μ is a probability measure).  In Omega: 


## Built-in Distributions

[bernoulli(w)](distributions.md#Omega.bernoulli) [boolbernoulli(w)](distributions.md#Omega.boolbernoulli)
betarv
categorical
constant
exponential
gammarv
invgamma
kumaraswamy
logistic
poisson
normal
uniform
rademacher

## Built-in Inference Algorithms

RejectionSample
MI
SSMH
SSMHDrift
HMC
HMCFAST