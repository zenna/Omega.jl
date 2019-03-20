using Omega
using Test
using Statistics: mean

function testreplace2()
  θ = normal(0.0, 1.0)
  x = normal(θ, 1.0)
  θnew = normal(100.0, 1.0)
  xnew = Omega.replace(x, θ => θnew)
  @test isapprox(mean(rand(xnew, 1000)), 100, atol = 1.0)
  θnewnew = normal(200.0, 1.0)
  xnewnew = replace(xnew, θnew => θnewnew)
  @test isapprox(mean(rand(xnewnew, 1000)), 200, atol = 1.0)
  y = xnewnew^2
  ynew = replace(y, xnewnew => 10.0)
  @test rand(ynew) == 10.0^2
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
end

replaceconst()