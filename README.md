# Expect.jl

Minimal but flexible probabilistic programming language


# To try

Install Julia 0.6.2

Open a repl (by calling `julia` from bash) and type:

```julia
Pkg.add("Distributions") # If not already installed
Pkg.clone("https://github.com/zenna/expect.git")

using Expect

θ = uniform(0, 1)
println("Expectation of θ is ", expectation(θ))
x = normal(θ, 1)

y = x ∈ Interval(-2, -1)

xy = cond(x, y)

println("sample from conditional random variable x | x in [-2, 1]: ",
        rand(xy))

println("Conditional expectation of x given y ≊",
        expectation(cond(x, y)))

y_ = curry(x, θ) 

println("A random variable y* sampled from y_",
        rand(y_))

Ey = expectation(y_)
println("Expectation of y_ is a random variable, a sample:",
        rand(Ey))

println("Conditional sample from θ given that expectation of y ∈ [0.4, -.6]",
        rand(θ, Ey ∈ Interval(0.4, 0.6)))

# Conditioning is infinitely composable
θ_ = cond(θ, Ey ∈ Interval(0.4, 0.6))
z = normal(θ, 1)
println("Conditional sample from z with θ_",
        rand(z))

r = [rand(z) for i = 1:1000]
println("A thousand samples", r)
```