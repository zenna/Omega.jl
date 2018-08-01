In Omega a probabilistic model is a collection of random variables.
Random Variables are of type `RandVar`.
There are two ways to construct random variables: the statistical style, which can be less verbose, and more intuitive, but has some limitations, and the explicit style, which is more general.

## Statistical Style
In the statistical style we create random variables by combining a number of primitives.
Omega comes with a number of built-in primitive distributions, the simplest of which is (arguably) the standard uniform:

```
x1 = uniform(0.0, 1.0)
```

`x1` is a random variable not a sample.
To construct another random variable `x2`, we do the same. 

```
x2 = uniform(0.0, 1.0)
```

`x1` and `x2` are identically distributed and independent (i.i.d.).

```julia
julia> rand((x1, x2))
(0.5602978842341093, 0.9274576159629635)
```

### Composition
Statistical style is convenient because it allows us to treat a `RandVar{T}` as if it is a value of type `T`.  For instance the `typeof` `uniform(0.0, 1.0)` is `RandVar{Float64}`.  Using the statistical style, we can add, multiply, divide them as if theyh were `Float64`

```julia
x3 = x1 + x2
```

This includes functions which return a Boolean

```julia
p = x3 > 1.0
```

A particularly useful case is that primitive distributions which take parameters of type `T`, also accept `RandVar{T}`

```julia
n = normal(x3, 1.0)
```

Suppose you write your own function

```julia
myfunc(x::Float64, y::Float64) = (x * y)^2
```

We can't automatically apply `myfunc` to `RandVar`s; it will cause a method error

```julia
myfunc(x1, x2)
```

However this is easily remedied with the function `lift`

```julia
lift(myfunc)(x1, x2)
```

## Explicit Style

The above style is convenient but has a few limitations and it hides a lot of the machinery.
To create random variables in the explicit style, create a normal julia sampler, but it is essential to pass through the `rng` object.

For instance, to define a bernoulli distribution in explicit style:

```julia
x_(rng) = rand(rng) > 0.5
```

`x_` is just a normal julia function.  We could sample from it by passing in the `GLOBAL_RNG`

```julia
julia> x_(Base.Random.GLOBAL_RNG)
true
```

However, in order to use `x` for conditional or causal inference we must turn it into a `RandVar` using `ciid`.

```julia
x = ciid(x_)
```

<!-- Mathematically, a sampler is a slightly different kind of object than a random variable. -->

## Independent Random Variables

Use `iid(x)` to create a random variable that is identical in distribution to `x` but but independent.

## Conditionally Independent Random Variables

Use `ciid(x)` to create a random variable that is identical in distribution to `x` but conditionally independent given its parents.

```julia
μ = uniform(0.0, 1.0)
y1 = normal(μ, 1.0)
y2 = ciid(y1)
rand((y1, y2))
```