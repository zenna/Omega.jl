In Omega, the main thing one does is construct random variables, and then compute inferences from them.  

Omega comes with a small number of built-in primitive distributions.  One example  is the [standard uniform](https://en.wikipedia.org/wiki/Uniform_distribution_(continuous)#Standard_uniform):

```julia
using Omega
x1 = 1 ~ StdUniform{Float64}()
```

What is the `1` doing here?  To explain, we need to introduce the idea of a __random variable class__.  Intuitively, a random variable class is a collection of random variables.

Tec

```julia
using Omega
x1 = 1 ~ StdUniform{Float64}()
```

```julia
using  Distributions
x1 = @~ Uniform(0.0, 1.0)
```

`x1` is a random variable not a sample.
To construct another random variable `x2`, we do the same. 

```julia
x2 = Uniform(0.0, 1.0)
```

`x1` and `x2` are [identically distributed and independent (i.i.d.)](https://en.wikipedia.org/wiki/Independent_and_identically_distributed_random_variables).

```julia
julia> randsample((x1, x2))
(0.5602978842341093, 0.9274576159629635)
```

Contrast this with:

```julia
julia> randsample((x1, x1))
(0.057271529749001626, 0.057271529749001626)
```

### Composition
There are two ways to compose random variables: the statistical style, which can be less verbose, and more intuitive, but has some limitations, and the explicit style, which is more general.

In the statistical style we create random variables by combining a number of primitives.



Statistical style is convenient because it allows us to treat a random variable which returns values of type `T` as if it is a value of type `T`.  For instance the `Uniform(0.0, 1.0)` is `Float64`.  Using the statistical style, we can add, multiply, divide them as if they were values of type `Float64`.


```julia
x3 = x1 .+ x2
```

Note `x3` is a random variable.

This includes inequalities:

```julia
p = x3 .> 1.0
```

```julia
julia> randsample(p)
false
```

A particularly useful case is that primitive distributions which take parameters of type `T`, also accept `RandVar` with `elemtype` `T`

```julia
n = Normal.(x3, 1.0)
```

Suppose you write your own function which take `Float64`s as input:

```julia
myfunc(x::Float64, y::Float64) = (x * y)^2
```

We can't automatically apply `myfunc` to random variables; it will cause a method error

```julia
julia> myfunc(x1, x2)
ERROR: MethodError: no method matching myfunc...
```

However this is easily remedied with the function `lift`:

```julia
pw(myfunc, x1, x2)
```

Or simply:

```julia
myfunc.(x1, x2)
```

## Explicit Style
The above style is convenient but has a few limitations and it hides a lot of the machinery.
To create random variables in the explicit style, create a normal Julia function that takes as input

For instance, to define a bernoulli distribution in explicit style:

```julia
x_(ω) = @~ StdNormal{Float64}()(ω) > 0.5
```

`x_` is just a normal julia function.  

All of the primitive distributions can be used in explicit style by passing the `rng` object as the first parameter (type constraints are added just to show that the return values are not random variables but elements.  But __don't add them to your own code!__ It will prevent automatic differentiation based inference procedures from working): 

```julia
function x_(ω)
  if Bernoulli(ω, 0.5, Bool)::Bool
    normal(ω, 0.0, 1.0)::Float64
  else Bernoulli(ω, 0.5, Bool)
    betarv(ω, 2.0, 2.0)::Float64
  end
end
```

Statistical style and functional style can be combined naturally.
For example:

```julia
x(ω) = (@~ Bernoulli(ω)) > 0.5 ? StdUniform(ω)^2 : sqrt.(StdUniform(ω))
y = Normal(0.0, 1.0)
z = x .+ y
```

### Random Variable Families 

Often we want to parameterize a random variable.  To do this we create functions which return random variables.
For example, we can make a Uniform distribution family (without using Distributions.jl) by defining a function which maps `a` and `b` to a random variable

```julia
"Uniform distribution between `a` and `b`"

unif(a, b) = StdUniform{Float64}() .* (b - a) + b  


# x is uniformly distributed between 10 and 20
x = unif(10, 20)
```

And hence if we wanted to create a method that created independent uniformly distributed random variables, we could do it like so:

```julia
unif2(a,b) =~ rng -> rand(rng) * (b - a) + a

# x is distributed between 30 and 40 (and independent of y)
x = unif2(30, 40)

# y is distributed between 30 and 40 (and independent of x)
y = unif2(30, 40)
```
