using OmegaCore
using OmegaTest
using Distributions
using Test

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