using Mu
using UnicodePlots

function test_hmc_1()
  μ = uniform(0.0, 1.0)
  x = normal(μ, 5.0)
  samples = rand(μ, x == 30.0, HMC, n=10000)
  println(histogram(samples))
end

test_hmc_1()