# Cheat Sheet

## Core Functions
The major functions that you will use in Omega are:

- [ciid(x)]() : that is equal in distribution to `x` but conditionally independent given parents
- [cond(x, y)](inference.md#cond) : condition random variable `x` on condition `y`
- [cond(ω, ab)](inference.md#cond) : condition random variable that contains statement by force `ab` to be `true`]
- [rand(x, n; alg = Alg)](inference.md#cond) : `n` samples from (possibly conditioned) random variable `x` using algorithm `ALG`
- [replace(x, θold => θnew)](causal.md#replace) : causal intervention in random variable
- [rid(x, θ)]() : random interventional distribution of `x` given `θ`  
- [rcd(x, θ) or x ∥ θ]()  : random conditional distribution of `x` given `θ`

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