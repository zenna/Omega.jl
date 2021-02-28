using Omega
using Test
using Statistics: mean
using Distributions

samplemean(x; n = 1000) = mean(randsample(x, n))

function testrid()
  θ = 1 ~ Beta(2.0, 2.0)
  x = 2 ~ Bernoulli(θ)
  ridxθ = rid(x, θ)
  meandist(ω) = samplemean(ridxθ(ω))
  mean1, mean2 = randsample((θ, meandist))
  @test mean1 == mean2
  ω1 = Omega.rand(defΩ())
  ω2 = Omega.rand(defΩ())
  x_ = ridxθ(ω1)
  θ_ = θ(ω1)
  nsamples = 10000
  θ_approx = mean([x_(Omega.rand(defΩ())) for i = 1:nsamples])
  @test isapprox(θ_approx, θ_; atol = 0.01)
end

testrid()

function testrid2()
  t1 = normal(0.0, 1.0)
  t2 = normal(0.0, 1.0)
  x = normal(t1 + t2, 1.0)
  xrid = rid(x, t1, t2)
  samples = rand(t1, meanᵣ(xrid) ==ₛ 0.0, 1000; alg = SSMH)
end

testrid2()