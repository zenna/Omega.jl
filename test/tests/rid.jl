module TestNamespace

using Omega
using Test
using Statistics: mean

function testrid()
  θ = betarv(2.0, 2.0)
  x = bernoulli(θ)
  ridxθ = Omega.rid(x, θ)
  mean1, mean2 = rand((θ, mean(ridxθ)))
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

end