using Omega
using Test

function testintervene1()
  x = uniform(0.0, 1.0)
  y = uniform(x, 1.0)
  z = uniform(y, 1.0)
  intervention = intervene(y, uniform(-10.0, -9.0))
  z_ = intervention(z)
  @test mean(z_) < mean(z)

  x = uniform(0.0, 1.0)
  z = uniform(0.0, 1.0)
  y = x + z
  intervention = intervene(x, 3.0)
  samples = rand(intervention(y), y ≊ 2.0, n=10000)

  x = uniform(0.0, 1.0)
  z = uniform(0.0, 1.0)
  y = x + z
  y__ = intervene(x, 3.0, y)
  rand(y__, y ≊ 2.0, n=10000)
end

function changetest()
  Θ = normal(0.0, 1.0)
  x = normal(Θ, 1.0)
  θnew = normal(100.0, 1.0)
  xnew = change(Θ, θnew, x)
  @test isapprox(mean(rand(xnew, 1000)), 100, atol=1.0)
  xnewnew = change(θnew, normal(200.0, 1.0), xnew)
  @test isapprox(mean(rand(xnewnew, 1000)), 200, atol=1.0)
end

