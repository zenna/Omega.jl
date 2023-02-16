using Omega
using Distributions
import Omega: complete
using Random: MersenneTwister
using Test

struct ϵType end
const ϵ = ϵType()

function test_complete()
  rng = MersenneTwister(0);
  M = @~ Normal(0, 1);
  C = @~ Normal(0, 1);
  x = 0.3
  ϵ_ = ϵ ~ Normal(0, 1)
  y = M .* x .+ C .+ ϵ_

  m = 0.8
  c = 1.2
  y_ = m * x + c + randn()

  evidence = (y .== y_)
  ypost = M |ᶜ evidence

  initω = defω()
  auxω = defω()
  completeω = complete(auxω, ypost, initω)
  @test y(completeω) == y_
end

function propagate_test()
  x = 1 ~ Normal(0, 5)
  propagate(nothing, x, 1.3)

  μ = :μ ~ Normal(0, 1)
  y = :y ~ Normal.(μ, 1)
  evidence = pw(==, y, 2.3)
  propagate(defω(), evidence, true)

  evidence2 = pw(==, 2.3, y)
  propagate(defω(), evidence2, true)

  # x_post = cnd(x, pw(y, 2.3))
  # propagate(nothing, x_post, )
end