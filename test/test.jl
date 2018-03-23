using Mu
using Base.Test
import Mu: softgt

function test()
  θ = uniform(0, 1)
  println("Expectation of θ is ", mean(θ))
  x = normal(θ, 1)
  y = x ∈ Interval(-2, -1)

  xy = cond(x, y)
  println("sample from conditional random variable x | x in [-2, 1]: ", rand(xy))
  println("Conditional expectation of x given y ≊", mean(cond(x, y), n))

  y_ = curry(x, θ)
  rand(y_)

  Ey = mean(y_)

  cond(θ, Ey ∈ Interval(0.4, 0.6))
end

test()

function soft_test1()
  θ = uniform(0, 1)
  println("Expectation of θ is ", mean(θ))
  x1 = normal(θ, 1)
  x2 = normal(θ, 1)
  y1 = softeq(x1, -1.5)
  y2 = softeq(x2, -1.5)
  y = y1 & y2
  xy = cond(θ, y)
  println("sample from conditional random variable x | x in [-2, 1]: ", rand(xy))
  println("Conditional expectation of x given y ≊", mean(cond(x, y), n))

  y_ = curry(x2, θ)
  rand(y_)

  Ey = mean(y_)

  cond(θ, Ey ∈ Interval(0.4, 0.6))
end

soft_test1()

function soft_test2()
  θ = uniform(0, 1)
  x1 = normal(θ, 1)
  y1 = softeq(x1, 0.5)
  y2 = Mu.softgt(x1, 0.0)
  y1, y2
end

soft_test2()

# nsamples = 1000
# allw = Dict{Int, Vector{Float64}}()
# softbools = Float64[]

# y1, y2 = soft_test()
# xs = 0.0:0.01:1.0
# ys = 0.0:0.01:1.0

# function f(y, w1, w2)
#   w = Mu.Omega()
#   w.d[19] = w1
#   w.d[20] = w2
#   y(w).epsilon
# end