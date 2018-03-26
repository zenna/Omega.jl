using Mu
using Distributions

# Number of components
k = 3

# Data
y_obs = randn(10)

# Priors depend on data? What is this madness?!
μ_data = mean(y_obs)
σ²data = var(y_obs)

λ = normal(μ_data, sqrt(σ²data))
r = gamma(1, 1/σ_data)
μ =  [normal(λ, 1/r) for i = 1:k]

# Inference goal: conditional posterior distribution of means given data
β = inversegamma(1, 1) # Sampled or 
w = gamma(1, σ²data)
s = [gamma(β, 1/w) for i = 1:k]

α = gamma(1, 1)
a_k = α / k
π = dirichlet([a_k for i = 1:k])

"Finite Mixture Model"
mm(π, μ, s, ω) = sum([π[i] * normal(μ[i], s[i]) for i = 1:k]

y = [mm(π, μ, s) for _ in y_obs]

# Inference goal: conditional distribution of means given data
rand(μ, y == y_obs, alg=MH)