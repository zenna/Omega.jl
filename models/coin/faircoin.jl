using Mu
import UnicodePlots

weight = uniform([0.3, 0.5, 0.7])
thrower_bias = uniform([-0.2, 0.0, 0.2])

nflips = 5
flips = [bernoulli(weight + thrower_bias) for i = 1:nflips]

rcdflipn = mean(flips[end] ∥ (weight, thrower_bias), 10000)

samples = rand(Omega, randarray(flips[1:end-1]) == [0.0 for i = 1:nflips - 1],  RejectionSample)
samples2 = rand(rcdflipn, randarray(flips[1:end-1]) == [float(iseven(i)) for i = 1:nflips - 1], RejectionSample)
