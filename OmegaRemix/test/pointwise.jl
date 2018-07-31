using Omega
using Test

function testpw()
  x = normal(0.0, 1.0)
  f(x::Real, y::Real) = x * y
  y = pw() do
    f(x, x)
  end
  x_, y_ = rand((x, y))
  @test y_ == x_ * x_
end