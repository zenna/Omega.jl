using OmegaCore
using Distributions
using Test

@testset "Pointwie" begin
  x = 1 ~ Normal(0, 1)
  y = abs(x)
  y_, x_ = randsample((y, x))
  @test y_ == abs(x_)
  @test isinferred(randsample, x)
end

@testset "Pointwise" begin
  x = 1 ~ Normal(0, 1)
  y = abs(x)
  y_, x_ = randsample((y, x))
  @test y_ == abs(x_)
  @test isinferred(randsample, x)
end

@testset "Pointwise class" begin
  xs = Normal(0, 1)
  x = @~ xs
  ys = xs .+ x
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