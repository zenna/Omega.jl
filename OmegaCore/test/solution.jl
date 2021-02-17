using Distributions
using OmegaCore
using Test

function testsolution()
  μ = 1 ~ Normal(0, 1)
  y = 2 ~ ((id, ω) -> Normal(μ(ω), 1)(id, ω)) 
  μc = μ |ᶜ (y ==ₚ 5.0)
  @test_throws OmegaCore.ConditionException μc(defω())
  sol = solution(μc)
end

function testlogpdfsol()
  μ = 1 ~ Normal(0, 1)
  y = 2 ~ ((id, ω) -> Normal(μ(ω), 1)(id, ω)) 
  μc = μ |ᶜ (y ==ₚ 5.0)
  ω = solution(μc)
  μ_ = μ(ω)
  @test logpdf(ω) == logpdf(Normal(0, 1), μ_) + logpdf(Normal(μ_, 1), 5.0)
end

function test_solution_intervene()
  μ = 1 ~ Normal(0, 1)
  y = 2 ~ ((id, ω) -> Normal(μ(ω), 1)(id, ω)) 
  μc = μ |ᶜ (y ==ₚ 5.0)
  yi = y |ᵈ (μ => (ω -> 100.0))
  yi2 = y |ᵈ (μ => (ω -> 100))
  ω = solution(μc)
  a, b = (yi(ω), y(ω))
  @test a != b
end

@testset "Solution" begin
  testsolution()
  testlogpdfsol()
  test_solution_intervene()
end