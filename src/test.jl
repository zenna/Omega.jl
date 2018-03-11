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

function f(x)
    return function g(y)
        x + y
    end    
end