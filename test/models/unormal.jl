using Mu
using UnicodePlots

μ = normal(0.0, 1.0)
x = normal(μ, 1.0)
samples = rand(μ, x == -30.0, HMC)
histogram(samples)