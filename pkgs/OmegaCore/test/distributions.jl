using OmegaCore
using Distributions
using Test
using OmegaTest

@testset "models" begin
  μ = 1 ~ Uniform(1.0, 2.0)
  x = 2 ~ Normal(μ, 1)
  @test isinferred(randsample, x)

  μ = 1 ~ Normal(0, 1)
  y = 2 ~ Normal(μ, 1)
  @test isinferred(randsample, y)
end