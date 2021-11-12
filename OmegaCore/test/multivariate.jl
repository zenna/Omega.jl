using OmegaCore
using OmegaTest
using Distributions
using OmegaDistributions
using Test

function f()
  μ = 5
  xs = manynth(Normal(μ, 1), CartesianIndices((10,)))
  randsample(xs)
  # randsample(xs)
end

@testset "multivariate" begin
  f()
  μ = 5
  # xs = 1 ~ Mv(Normal(5, 1), (1000,))
  xs = manynth(Normal(μ, 1), CartesianIndices((1000,)))
  samples = randsample(xs)
  # @test isinferred(randsample, xs)
  @test mean(samples) ≈ μ atol = 0.3
end

@testset "Multivariate 2" begin
  x = 1 ~ Normal(0, 1)
  function f(id, ω)
    x(ω) + Uniform(0, 1)(id, ω)
  end
  xs = dimsnth(f, (3, 3))
  x_, xs_ = randsample((x, xs))
  @test size(xs_) == (3, 3)
  # @test isinferred(randsample, xs)
  # FIXME: not generalized to arbitrary cartesian N
end
