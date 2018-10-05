In Omega a probabilistic model is a collection of random variables.
Random Variables are of type `RandVar`.
There are two ways to construct random variables: the statistical style, which can be less verbose, and more intuitive, but has some limitations, and the explicit style, which is more general.

## Statistical Style
In the statistical style we create random variables by combining a number of primitives.
Omega comes with a number of built-in primitive distributions, the simplest of which is (arguably) the [standard uniform](https://en.wikipedia.org/wiki/Uniform_distribution_(continuous)#Standard_uniform):

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

Contrast this with:

```julia
julia> rand((x1, x1))
(0.057271529749001626, 0.057271529749001626)
```

### Composition
Statistical style is convenient because it allows us to treat a `RandVar{T}` as if it is a value of type `T`.  For instance the `typeof(uniform(0.0, 1.0))` is `RandVar{Float64}`.  Using the statistical style, we can add, multiply, divide them as if they were values of type `Float64`.

```julia
x3 = x1 + x2
```

Note `x3` is a `RandVar{Float64}` like `x1` and `x2`

This includes inequalities:

```julia
p = x3 > 1.0
```

`p` is of type `RandVar{Bool}`

```julia
julia> rand(p)
false
```


A particularly useful case is that primitive distributions which take parameters of type `T`, also accept `RandVar{T}`

```julia
n = normal(x3, 1.0)
```

Suppose you write your own function defined on the reals:

```julia
myfunc(x::Float64, y::Float64) = (x * y)^2
```

We can't automatically apply `myfunc` to `RandVar`s; it will cause a method error

```julia
julia> myfunc(x1, x2)
ERROR: MethodError: no method matching myfunc(::RandVar..., ::RandVar...)
```

However this is easily remedied with the function `lift`:

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

However, in order to use `x` for conditional or causal inference we must turn it into a `RandVar`.
One way to do this (we discuss others in [conditonalindependence]) is using `ciid`.

```julia
x = ciid(x_)
```

All of the primitive distributions can be used in explicit style by passing the `rng` object as the first parameter (type constraints are added just to show that the return values are not random variables but elements): 

```julia
function x_(rng)
  if bernoulli(rng, 0.5, Bool)
    normal(rng, 0.0, 1.0)::Float64
  else bernoulli(rng, 0.5, Bool)
    betarv(rng, 2.0, 2.0)::Float64
  end
end

ciid(x_)
```

Statistical style and functional style can be combined naturally.
For example:

```julia
x = ciid(rng -> rand(rng) > 0.5 ? rand(rng)^2 : sqrt(rand(rng)))
y = normal(0.0, 1.0)
z = x + y
```

### Random Variable Families 

Often we want to parameterize a random variable.  To do this we create functions with addition argument,
and pass arguments to `ciid`.

```julia
unif(rng, a, b) = rand(rng) * (b - a) + b  
x = ciid(unif, 10, 20)
```

And hence if we wanted to create a method that created independent uniformly distributed random variables, we could do it like so:

```julia
uniform(a, b) = ciid(rng -> rand(rng) * (b - a) + b)
```