using Omega
using Test

function testreplace1()
  x = uniform(0.0, 1.0)
  y = uniform(x, 1.0)
  z = uniform(y, 1.0)
  intervention = replace(y, uniform(-10.0, -9.0))
  z_ = intervention(z)
  @test mean(z_) < mean(z)

  x = uniform(0.0, 1.0)
  z = uniform(0.0, 1.0)
  y = x + z
  intervention = replace(x, 3.0)
  samples = rand(intervention(y), y ≊ 2.0, n=10000)

  x = uniform(0.0, 1.0)
  z = uniform(0.0, 1.0)
  y = x + z
  y__ = replace(x, 3.0, y)
  rand(y__, y ≊ 2.0, n=10000)
end

testreplace1()

function testreplace2()
  Θ = normal(0.0, 1.0)
  x = normal(Θ, 1.0)
  θnew = normal(100.0, 1.0)
  xnew = replace(x, Θ => θnew)
  @test isapprox(mean(rand(xnew, 1000)), 100, atol=1.0)
  θnewnew = normal(200.0, 1.0)
  xnewnew = replace(xnew, θnew => θnewnew)
  @test isapprox(mean(rand(xnewnew, 1000)), 200, atol=1.0)
end

testreplace2()

function replaceconst()
  μ = uniform(1.0, 2.0)
  σ = uniform(1.0, 2.0)
  x = normal(μ, σ)
  xnew = replace(x, σ => μ)
  rand(xnew)
  xnew = replace(x, σ => 3.432)
  rand(xnew)
  xnew = replace(x, μ => 3.432, σ => 21.2)
  rand(xnew)
  # xnew = replace(x, Dict(μ => 3.432, σ => 21.2))
  # rand(xnew)
end

replaceconst()