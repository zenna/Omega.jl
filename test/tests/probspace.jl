using Mu

function Y(rng, n)
  [normal(rng[@id], 0.0, 1.0) for i = 1:n]
end

function X(rng)
  n = rand(rng[@id], 1:10)
  m = rand(rng[@id], 1:10)
  as = Y(rng[@id], n)
  bs = Y(rng[@id], m)
  as, bs
end

rand(X)
