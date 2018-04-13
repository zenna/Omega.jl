using Mu
using Distributions

# Number of components
k = 3

nobs = 10

# Data
y_obs = vcat((randn(div(nobs, 2)) + 50)-10, (randn(div(nobs,2))))

# Priors depend on data? What is this madness?!
μ_data = mean(y_obs)
σ²data = var(y_obs)

λ = normal(μ_data, sqrt(σ²data))

r = Γ(1.0, 1/σ²data)

# FIXME: overload Base.vect
μ =  [normal(λ, 1/r) for i = 1:k]

# Inference goal: conditional posterior distribution of means given data
β = inversegamma(1.0, 1.0)
w = Γ(1.0, σ²data)
s = [Γ(β, 1/w) for i = 1:k]

α = Γ(1.0, 1.0)
a_k = α / k

π = dirichlet([a_k for i = 1:k])

"Finite Mixture Model"
mm(π, μ, s) = sum([π[i] * normal(μ[i], s[i]) for i = 1:k])

y = [mm(π, μ, s) for _ in y_obs]

y_ = Mu.randarray(y)

# Inference goal: conditional distribution of means given data
samples = rand(Mu.randarray(μ), y_ == y_obs, MH, n=10000)
@show [median(map(x->x[i], samples)) for i=1:k]


samples_π = rand(Mu.randarray(π), y_ == y_obs, SSMH, n=10000)
@show [median(map(x->x[i], samples_π)) for i=1:k]



## Generate a mixture choosing from different distributions
## instead of computing a weighted average

mixture(c, θ, w::Mu.Omega) = θ[c]
mixture(c::T1, θ::Array{T2, 1}) where T1 <: Integer where T2 <: Real  =
  Mu.RandVar{T2, true}(mixture, (c, θ))
mixture(c::Mu.AbstractRandVar{T1}, θ::Array{T2, 1}) where T1 <: Integer where T2 <: Real =
  Mu.RandVar{T2, true}(mixture, (c, θ))
mixture(c::T1, θ::Mu.AbstractRandVar{Array{T2, 1}}) where T1 <: Integer where T2 <: Real =
  Mu.RandVar{T2, true}(mixture, (c, θ))
mixture(c::Mu.AbstractRandVar{T1}, θ::Mu.AbstractRandVar{Array{T2, 1}}) where T1 <: Integer where T2 <: Real =
  Mu.RandVar{T2, true}(mixture, (c, θ))

c_i = Mu.categorical(Mu.randarray(π))
mm() = mixture(c_i, Mu.randarray([normal(μ[i], s[i]) for i = 1:k]))
y = [mm() for _ in y_obs]
y_ = Mu.randarray(y)
samples = rand(Mu.randarray(μ), y_ == y_obs, MH, n=10000)
@show [median(map(x->x[i], samples)) for i=1:k]