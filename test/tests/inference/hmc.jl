module TestNamespace

using Omega
using UnicodePlots

function test_hmc_1()
  μ = uniform(0.0, 1.0)
  x = normal(μ, 5.0)
  samples = rand(μ, x ==ₛ 10.0, 10; alg = HMC, ΩT = Omega.SimpleΩ{Vector{Int}, Float64})
  println(UnicodePlots.histogram(samples))
end

# test_hmc_1()

end