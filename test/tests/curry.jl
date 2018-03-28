using Mu
1+1

mu1 = bernoulli(0.5)
mu2 = bernoulli(0.5)
mu = mu1 + mu2
c1 = curry(normal(mu, 1), mu1)
c2 = curry(normal(m, 1), mu2)
c3 = curry(normal(mu, 1), mu)

1+1
