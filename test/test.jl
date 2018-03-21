using Mu
using Base.Test

function test()
  θ = uniform(0, 1)
  println("Expectation of θ is ", expectation(θ))
  x1 = normal(θ, 1)
  x2 = normal(x1, 1)

  y = x ∈ Interval(-2, -1)

  xy = cond(x, y)
  println("sample from conditional random variable x | x in [-2, 1]: ", rand(xy))
  println("Conditional expectation of x given y ≊", expectation(cond(x, y), n))

  y_ = curry(x2, θ)
  rand(y_)

  Ey = expectation(y_)

  cond(θ, Ey ∈ Interval(0.4, 0.6))
end

function test2()
  θ = uniform(0, 1)
  println("Expectation of θ is ", expectation(θ))
  x1 = normal(θ, 1)
  x2 = normal(θ, 1)
  y1 = softeq(x1, -1.5)
  y2 = softeq(x2, -1.5)
  y = y1 & y2
  xy = cond(θ, y)
  println("sample from conditional random variable x | x in [-2, 1]: ", rand(xy))
  println("Conditional expectation of x given y ≊", expectation(cond(x, y), n))

  y_ = curry(x2, θ)
  rand(y_)

  Ey = expectation(y_)

  cond(θ, Ey ∈ Interval(0.4, 0.6))
end

test2()

function soft_test()
  θ = uniform(0, 1)
  x1 = normal(θ, 1)
  y = softeq(x1, -1.5)
  xy = cond(θ, y)
end
