using Mu
import Mu: randarray
using Base.Test

nflips = 10
weight = Mu.betarv(2.0, 2.0)
flips = [bernoulli(weight) for i = 1:nflips]

obs = [1.0 for i = 1:nflips]
ps = rand(weight, Mu.randarray(flips) == obs)

@test mean(ps) > 0.5

obs = [0.0 for i = 1:nflips]
ps = rand(weight, randarray(flips) == obs)

@test mean(ps) < 0.5
