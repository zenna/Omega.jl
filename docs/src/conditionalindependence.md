# Conditional Independence

!!! note
    A class in Omega is similar to a "plate" in Bayesian networks.

    ```

A class in Omega is a function of the form `f(id,  ω::Ω)`.
It represents a sequence of random variables.
To get the nth member of a class use the function `nth`.

There are primitive random variable classes in Omega.

```julia
A1 = nth(StdNormal, 1)
A2 = nth(StdNormal, 2)
A3 = nth(StdNormal, 3)
```

Or equivalently, use `~`:

```julia
A1 = 1 ~ StdNormal, 1
A2 = 2 ~ StdNormal, 2
A3 = 3 ~ StdNormal, 3
```


Of course, you can specify your own classes simply by constructing a function.
In 

```julia
using Omega, Distributions
μ = 1 ~ StdNormal{Float64}()
function Xs(id, ω)
  id ~ Normal(ω, μ(ω), 1) 
end
x1 = 1 ~ Xs
x2 = 2 ~ Xs
```

To construct a random variable over collections from a class, use `Mv` 

A very important property of classes is that the members of a class are conditionally independent, given the shared parents.
In the above exmaple, `x1` and `x2` are conditionally independent given `μ`.

```@docs
ciid
```

# Independence

Sometimes we need to construct random variables that are independent.  The function `iid` constructs a class of random variables that are independent.