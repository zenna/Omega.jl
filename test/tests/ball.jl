using Mu
using Distributions
using Base.Test

k = 5       # colors of balls
n_obs = 50
weights = randarray(Mu.dirichlet([1.0 for i = 1:k]))
y = randarray([Mu.categorical(weights) for i = 1:n_obs])
function ccount(samples, k)
    counts = zeros(k)
    for s in samples
        counts[s] += 1
    end
    counts
end

eval(Mu.lift(:ccount, 0))

y_obs = zeros(k)
y_obs[2] = n_obs
c = ccount(y, k)
post = rand(weights, c == y_obs, n=10000)
