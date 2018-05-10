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

function test_ssmc_2()
  x = logistic(1.0, 2.0, (2, 3, 4))
  y = sum(x)
  OmegaT = Mu.SimpleOmega{Int, Array{Float64, 3}}
  rand(x, y == 5.0, MI; OmegaT=OmegaT)
end

test_ssmc_2()