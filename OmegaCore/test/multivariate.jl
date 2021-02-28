using OmegaCore
using OmegaTest
using Distributions
using Test

@testset "multivariate" begin
  μ = 5
  # xs = 1 ~ Mv(Normal(5, 1), (1000,))
  xs = ciidn(Normal(μ, 1), CartesianIndices((1000,)))
  samples = randsample(xs)
  @test mean(samples) ≈ μ atol = 0.3
  # @test isinferred(randsample, xs)
end

@testset "Multivariate 2" begin
  x = 1 ~ Normal(0, 1)
  function f(id, ω)
    x(ω) + Uniform(0, 1)(id, ω)
  end
  xs = ciidn(f, CartesianIndices((3, 3)))
  randsample((x, xs))
  # FIXME: not generalized to arbitrary cartesian N
end
