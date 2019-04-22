# Built In Distributions

Omega comes with a number of built-in probability distributions.

## Univariate Distributions

```@docs
bernoulli
betarv
categorical
constant
exponential
gammarv
invgammarv
kumaraswamy
logistic
poisson
normal
uniform
rademacher
```

## Multivariate Distributions

```@docs
mvnormal
dirichlet
```
## Describe distributional functions

Omega comes with some functions which summarize an entire distribution.
Most of these are inherited from [Distributions.jl](https://github.com/JuliaStats/Distributions.jl)

```@docs
mean
prob
```