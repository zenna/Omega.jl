using Mu
using UnicodePlots

function test_ssmc_1()
  μ = uniform(0.0, 100.0)
  x = normal(μ, 5.0)
  samples = rand(μ, x == 7.0, SSMH, n=10000)
  println(histogram(samples))
  println(mean(samples))
end

test_ssmc_1()
