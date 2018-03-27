using Mu
import Mu: randvec
nflips = 10
weight = Mu.beta(2.0, 2.0)
coin = [bernoulli(weight) for i = 1:nflips]
obs = [1.0 for i = 1:nflips]
rand(randvec(weight), randvec(flips) == obs)