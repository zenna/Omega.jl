using Mu
using Distributions
using Base.Test

k = 5       # colors of balls
n_obs = 50

# if i want dirichlet to construct a randvar
# then 

"Dirichlet distribution"
function uvec(ωids::Mu.LazyId, ω::Mu.Omega)
  k = rand(1:20)
  gammas = [uniform(0.0, 1.0, ωids[i], ω::Mu.Omega) for i = 1:k]
end

"Dirichlet distribution"
function uvec(ωids::Mu.LazyId = Mu.LazyId())
  Mu.RandVar{Vector{Float64}, true, typeof(uvec),  Tuple{Mu.LazyId}}(uvec, (ωids,))
end

## Doing this makes weird dependencies, because now i becomes dependent with randvars outside htis world
## what if it just always took a new random idnex
## Then uniform would no longer be a pure transformationm of omega, which is problematic
#3 What we want:
## 1) it to be pure transformation of omega
## 2) two different uvecs would be independent
#3 3) 


## Problem 1. threading through Omega everywhere gets cumbersome
## Problem 2. the ids!!
## Problem with thisi s that all the ids need to be chosen up front

weights = randarray(Mu.dirichlet([1.0 for i = 1:k])) # TODO
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
