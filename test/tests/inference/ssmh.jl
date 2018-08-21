module TestNamespace

using Omega
using UnicodePlots

function test_ssmc_1()
  μ = uniform(0.0, 1.0)
  x = normal(μ, 5.0)
  samples = rand(μ, x ≊ 7.0, 10000; alg= SSMH)
  println(histogram([samples...]))
  println(mean(samples))
end

test_ssmc_1()

function test_ssmc_2()
  x = logistic(1.0, 2.0, (2, 3, 4))
  y = sum(x)
  ΩT = Omega.SimpleΩ{Vector{Int}, Array{Float64, 3}}
  rand(x, y ≊ 5.0; alg = SSMH, ΩT=ΩT)
end

test_ssmc_2()

end