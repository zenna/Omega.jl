using Omega
using Test

function testrid()
  θ = betarv(2.0, 2.0)
  x = bernoulli(θ)
  ridxθ = Omega.rid(x, θ)
  ω1 = Omega.defaultomega()()
  ω2 = Omega.defaultomega()()
  x_ = ridxθ(ω1)
  θ_ = θ(ω1)
  nsamples = 10000
  θ_approx = mean([x_(Omega.defaultomega()()) for i = 1:nsamples])
  @test isapprox(θ_approx, θ_; atol = 0.01)
end