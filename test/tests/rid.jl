using Omega
using Test
using Statistics: mean

function testrid()
  θ = betarv(2.0, 2.0)
  x = bernoulli(θ)
  ridxθ = Omega.rid(x, θ)
  mean1, mean2 = rand((θ, lmean(ridxθ)))
  @test mean1 == mean2
  ω1 = Omega.defΩ()()
  ω2 = Omega.defΩ()()
  x_ = ridxθ(ω1)
  θ_ = θ(ω1)
  nsamples = 10000
  θ_approx = mean([x_(Omega.defΩ()()) for i = 1:nsamples])
  @test isapprox(θ_approx, θ_; atol = 0.01)
end

testrid()

function testrid2()
  t1 = normal(0.0, 1.0)
  t2 = normal(0.0, 1.0)
  x = normal(t1 + t2, 1.0)
  xrid = rid(x, t1, t2)
  samples = rand(t1, lmean(xrid) ==ₛ 0.0, 1000; alg = SSMH)
end

testrid2()