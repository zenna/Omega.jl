using Omega
using UnicodePlots
using Base.Test

θ = uniform(0.0, 1.0)
x = normal(θ, 1.0)
# rand(cond(θ, x == 2.0))