using OmegaCore, Distributions
using Test
import Random
Random.seed!(1)

function test_cond!()
  function f(ω)
    x = (1 ~ Normal(0, 1))(ω)
    cond!(ω, x > 0)
    x
  end
  @test all(randsample(f, 100) .>= 0.0)
end

"Test conditioning on predicate of positive measure"
function test_pos_measure()
  x = 1 ~ Normal(0, 1)
  y(ω) = x(ω) > 0
  x_cond = x |ᶜ y
  samples = randsample(x_cond, 100000; alg = RejectionSample)
  samplemean = mean(samples)
  exactmean = mean(truncated(Normal(0, 1), 0, Inf))
  @test samplemean ≈ exactmean atol = 0.01
end

"Test whether the logpdf is correct"
function test_density_cond()
  rng = Random.MersenneTwister(0)
  μ = 1 ~ Normal(0, 1)
  x = Normalₚ(μ, 1.0)

  μ_ = -0.4321
  x_ = 0.1234
  μₓ = μ |ᶜ (x ==ₚ x_)
  ω = LazyΩ(μ => μ_)
  logpdf_ = logpdf(Normal(0, 1), μ_) + logpdf(Normal(μ_, 1), x_)
  @test logpdf(μₓ, ω) == logpdf_
end

function test_out_of_order_condition()
  x = 1 ~ Poisson(1.3)
  function f(ω)
    n = x(ω)
    x_ = 0.0
    for i = 1:n
      x_ += (i + 1 ~ Normal(0, 1))(ω)
    end
    x_
  end

  x_ = x |ᶜ (f ==ₚ 3.0)
  g_ = ω -> (x(ω), f_(ω))
end

function test_parent()
  μ = 1 ~ Normal(0, 1)
  x = 2 ~ Normal(μ, 1)
  x_ = 0.123
  μ_ = 0.1
  μ |ᶜ x == x_
  ω = defΩ()((1,) => μ_)
  @test logpdf(μ_, ω) = logpdf(Normal(0, 1), μ_) + logpdf(Normal(μ_, 1), x_)
end

function test_condition()
  μ = 1 ~ Normal(0, 1)
  x = 2 ~ Normal(μ, 1)
  x_ = 0.123
  μ_ = 0.987

  μc = μ |ᶜ x ==ₚ x_
  ω = defω()
  ω[(1,)] = μ_
  μc(ω)
  @test x(ω) == x_
  logpdf_ = logpdf(Normal(0, 1), μ) + logpdf(Normal(μ, 1), x_)
  # Will ω have a value for (2,)?
end

@testset "Conditions" begin
  test_cond!()
  test_pos_measure()
  test_density_cond()
  test_out_of_order_condition()
  test_parent()
  test_condition()
end