# Mu.jl

<<<<<<< HEAD
[![Build Status](https://travis-ci.org/zenna/Mu.jl.svg?branch=master)](https://travis-ci.org/zenna/Mu.jl)

[![codecov.io](http://codecov.io/github/zenna/Mu.jl/coverage.svg?branch=master)](http://codecov.io/github/zenna/Mu.jl?branch=master)

Minimal but flexible probabilistic programming language

=======
Minimal but flexible probabilistic programming language


>>>>>>> a9a83184390127ef9309719e8619b4b03a549342
# To try

Install Julia 0.6.2

Open a repl (by calling `julia` from bash) and type:

```julia
Pkg.add("Distributions") # If not already installed
<<<<<<< HEAD
Pkg.clone("https://github.com/zenna/Mu.jl.git")

using Mu
=======
Pkg.clone("https://github.com/zenna/expect.git")

using Expect
>>>>>>> a9a83184390127ef9309719e8619b4b03a549342

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

```