module TestNamespace

using Omega
using UnicodePlots
using Statistics: mean

function test_ssmc_1()
  μ = uniform(0.0, 1.0)
  x = normal(μ, 5.0)
  samples = rand(μ, x ==ₛ 7.0, 10000; alg= SSMH)
  println(histogram([samples...]))
  println(mean(samples))
end

test_ssmc_1()

function test_ssmc_2()
  x = logistic(1.0, 2.0, (2, 3, 4))
  y = sum(x)
  rand(x, y ==ₛ 5.0; alg = SSMH)
end

test_ssmc_2()

function test_sshm_drift()
  x = normal(0.0, 1.0)
  y = normal(1.0, 1.0)
  z = rand(x - y, x ==ₛ y, 10000; alg=SSMH)
  z = convert(Array{Float64}, z)
  println(histogram([z[300:end]...]))
  println(mean(z[300:end]))
end

test_sshm_drift()

end
