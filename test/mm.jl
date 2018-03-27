using Mu
using Distributions

# Number of components
k = 3

nobs = 10

# Data
y_obs = vcat((randn(nobs/2) + 50)-10, (randn(nobs/2)))

# Priors depend on data? What is this madness?!
μ_data = mean(y_obs)
σ²data = var(y_obs)

λ = normal(μ_data, sqrt(σ²data))

r = Γ(1, 1/σ²data)

# FIXME: overload Base.vect
μ =  [normal(λ, 1/r) for i = 1:k]

# Inference goal: conditional posterior distribution of means given data
β = inversegamma(1, 1)
w = Γ(1, σ²data)
s = [Γ(β, 1/w) for i = 1:k]

α = Γ(1, 1)
a_k = α / k

π = dirichlet([a_k for i = 1:k])

"Finite Mixture Model"
mm(π, μ, s) = sum([π[i] * normal(μ[i], s[i]) for i = 1:k])

y = [mm(π, μ, s) for _ in y_obs]

y_ = Mu.randvec(y)

# Inference goal: conditional distribution of means given data
samples = rand(Mu.randvec(μ), y_ == y_obs, alg=MH, n=10000)
@show [median(map(x->x[i], samples)) for i=1:k]