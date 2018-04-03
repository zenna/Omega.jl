using Mu
using Base.Test
import Mu: softgt

function test()
  θ = uniform(0, 1)
  x = normal(θ, 1)
  xy = cond(x, y)
  mean(cond(x, y))
  y_ = curry(x, θ)
  Ey = mean(y_)
  Ey_ = cond(Ey, θ > 0.5)
  rand(Ey_)
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
  y1 = softeq(x1, 1.5)
  y2 = Mu.softgt(x1, 0.0)
  y1, y2
  y = y1 & y2
end

soft_test2()

function test()
  θ = uniform(0, 1)
  x = normal(θ, 1)
  # y = softeq(x, 1.5)
  # xy = cond(x, y)
  y_ = curry(x, θ)
  Ey = mean(y_)
  Mu.softgt(Ey,  0.5) | softeq(θ, 0.1) 
end