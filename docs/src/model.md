In Omega a probabilistic model is a collection of  random variable.

The simplest random variable you can construct is the perhaps the standard uniform

```
x1 = uniform(0.0, 1.0)
```

`x` is a random variable not a sample.
To construct another random variable `x2`, we do the same. 

```
x2 = uniform(0.0, 1.0)
```

`x1` and `x2` are identically distributed and independent (i.i.d.)

```julia
julia> rand((x1, x2))
(0.5602978842341093, 0.9274576159629635)
```

Omega comes with a large number of in-built distributions, and so to make complex probabilistic you can simply use these and compose them.

## Explicit Style

The above style is convenient but it hides a lot of the machinery of what is going on.
Omega, as well as all probabilistic programming languages, use programs to represent probability distributions
However, there are several different probability distribution.

Omega is distinct from other probabilistic programming langauges because it represents.
In Omega

```julia
x(\omega) = \omega(1)
```

## Independent Random Variables

Use `iid(x)` to create a random variabel that is identical in distribution to `x` but but independent.

## Conditionally Independent Random Variables

Use `ciid(x)` to create a random variable that is identical in distributio to `x` but conditionally independent given its parents.

```julia
μ = uniform(0.0, 1.0)
y1 = normal(μ, 1.0)
y2 = ciid(y1)
rand((y1, y2))
```