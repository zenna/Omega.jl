using OmegaCore
using Distributions
using OmegaDistributions
using Test

@testset "Pointwie" begin
  x = 1 ~ Normal(0, 1)
  y = abs.(x)
  y_, x_ = randsample((y, x))
  @test y_ == abs(x_)
  @test isinferred(randsample, x)
end

@testset "Pointwise class" begin
  μ = @~ Normal(0, 1)
  ϵs = ~ Normal(0, 1)
  ys = μ .+ ϵs
  y1 = 1 ~ ys
  y2 = 2 ~ ys
  randsample((y1, y2))
end

@testset "Pointwise func" begin
  issin = @~ Bernoulli(0.5)
  f = ifelse.(issin, sin, sqrt)
  μ = @~ Normal(0, 1)
  ϵs = ~ Normal(0, 1)
  ys = μ .+ ϵs
  y1 = 1 ~ ys
  y2 = 2 ~ ys
  randsample((y1, y2))
end

function f()
  y = @~ Normal(0, 1)
  z = y .+ y
  randsample(z)
  ω = defω()
  z(ω)
end