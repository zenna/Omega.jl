using Omega
using Test

nflips = 10
weight = Omega.betarv(2.0, 2.0)
flips = iid(ω -> [bernoulli(ω, weight(ω)) for i = 1:nflips])

obs = [1.0 for i = 1:nflips]
ps = rand(weight, flips == obs)

@test mean(ps) > 0.5

obs = [0.0 for i = 1:nflips]
ps = rand(weight, flips == obs)

@test mean(ps) < 0.5
