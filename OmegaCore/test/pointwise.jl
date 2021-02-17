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

