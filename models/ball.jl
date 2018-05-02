using Mu
using Distributions
using Base.Test

# colors of balls
k = 5       
n_obs = 50
weights = Mu.dirichlet([1.0 for i = 1:k])

function y_(ω)
  [Mu.categorical(ω[@id][i], weights(ω[@id][i])) for i = 1:n_obs]
end

y = iid(y_, Vector{Float64})

function ccount(samples, k)
  counts = zeros(k)
  for s in samples
    counts[s] += 1
  end
  counts
end

Mu.lift(:ccount, 2)

# Observations
y_obs = zeros(k)
y_obs[2] = n_obs

c = ccount(y, k)
samples = rand(weights, c == y_obs)
meds = [median(map(x->x[i], samples)) for i = 1:k]
@test findmax(meds)[2] == 2