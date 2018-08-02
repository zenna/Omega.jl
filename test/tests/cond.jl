using Omega
using Test

function testcond()
  x = normal(0.0, 1.0)
  x_ = cond(x, x < 1.0)
  x_samples = rand(x_, 10000, alg = RejectionSample)
  x_samples = filter(s -> s != nothing, x_samples)
  @test maximum(x_samples) < 1.0
  x__ = cond(x_, x > -1.0)
  x__samples = rand(x__, 10000, alg = RejectionSample)
  x__samples = filter(s -> s != nothing, x__samples)
  @test minimum(x__samples) > -1.0
end

testcond()

function testcond2()
  x = cond(poisson(2.0), iseven)
  xsamples = rand(x, 100, alg = RejectionSample)
  @test all(iseven, xsamples)
end

testcond2()