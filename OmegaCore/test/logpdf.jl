using OmegaCore
using OmegaTest
using Distributions
using Test

function gen_samples()
  using Random
  using Distributions
  n = 1_000_000
  z = 1.0
  pinvert(θ, z) = z - θ, θ
  x = 1 ~ StdNormal{Float64}()
  y = 2 ~ StdNormal{Float64}()
  z = x .+ y
  z_ = 1.0
  evidence = z .== z_
  model = @joint(x, y) |^̧ evidence

  # FIXME: TYPES!
  propagate_to_exo(ω, evidence::typeof(evidence), evidence_) = 
    evidence_ ? propagate(ω, z, z_)
  
  function propagate_to_exo(ω, z::typeof(z), z_)
    θ = StdNormal{Float64}()(@uid(), ω)
    x, y = pinvert(θ, z_)
    propagate_to_exo(ω, x, x_)
    propagate_to_exo(ω, y, y_)
  end

  function logdensity(θ_)
      x, y = pinvert(θ_)
      logpdf(Normal(0, 1), θ_) + logpdf(Normal(0, 1), y) + logpdf(Normal(0, 1), x)
  end
  propose_and_logratio(ω, x) = rand(ω, Normal(x, 0.1)), 0.0 
  rng = Random.MersenneTwister(0)
  samples = mh(rng, logdensity, n, 0.5, propose_and_logratio)
  pinvert.(samples)
end

# function test_logpdf_ucond()
#   a = 1 ~ Normal(0, 1)
#   b = 2 ~ Normal(2, 3)
#   z(ω) = (a(ω), b(ω))
#   ω, ℓ = propose(Random.GLOBAL_RNG, z)
#   @test isinferred(propose, Random.GLOBAL_RNG, z)
#   a_, b_ = z(ω)
#   @test ℓ == logpdf(Normal(0, 1), a_) + logpdf(Normal(2, 3), b_)
# end

# # Test doesn't double count
# function test_logpdf_ucond_nodouble()
#   a = 1 ~ Normal(0, 1)
#   b = 2 ~ Normal(2, 3)
#   z(ω) = (a(ω), b(ω), a(ω))
#   ω, ℓ = propose(Random.GLOBAL_RNG, z)
#   @test isinferred(propose, Random.GLOBAL_RNG, z)
#   a_, b_ = z(ω)
#   @test ℓ == logpdf(Normal(0, 1), a_) + logpdf(Normal(2, 3), b_)
# end

# function test_logpdf_cond()
#   μ = 1 ~ Normal(0, 1)
#   x = 2 ~ Normalₚ(μ, 1)
#   μ_ = 0.1234
#   x_ = -0.54321
#   μc = μ |ᶜ x == x_
#   ω, ℓ = propose(Random.GLOBAL_RNG, μc)
# end

# @testset "Logpdf" begin
#   test_logpdf_ucond()
#   test_logpdf_ucond_nodouble()
# end