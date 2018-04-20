MaybeRV{T} = Union{T, AbstractRandVar{T}} where T

"Gamma distribution"
gammarv(ω::Omega, α::AbstractFloat, θ::AbstractFloat) = quantile(Gamma(α, θ), rand(ω))
gammarv(α::MaybeRV{T}, θ::MaybeRV{T}, ωid::Id = ωnew()) where T <: Real =
  RandVar{T, true}(gammarv, (α, θ), ωid)
Γ = gammarv

"Inverse Gamma distribution"
inversegamma(ω::Omega, α, θ, ωi) = quantile(InverseGamma(α, θ), rand(ω))
inversegamma(α::MaybeRV{T}, θ::MaybeRV{T}, ωid::Id = ωnew()) where T <: Real =
  RandVar{T, true}(inversegamma, (α, θ), ωid)

"Dirichlet distribution"
function dirichlet(ω::Omega, α)
  gammas = [gammarv(ω, αi, 1.0) for αi in α]
  Σ = sum(gammas)
  [gamma/Σ for gamma in gammas]
end
# FIXME: Type 
dirichlet(α::MaybeRV{T}, ωid::Id = ωid::Id=ωnew()) where T = RandVar{T, true}(dirichlet, (α,), ωid)

"Beta distribution"
betarv(ω::Omega, α::AbstractFloat, β::AbstractFloat) = quantile(Beta(α, β), rand(ω))
betarv(α::MaybeRV{T}, β::MaybeRV{T}, ωid::Id=ωnew()) where T <: AbstractFloat = RandVar{T, true}(Mu.betarv, (α, β), ωid)

"Bernoulli with weight `p`"
bernoulli(ω::Omega, p::AbstractFloat) = quantile(Bernoulli(p), rand(ω))
bernoulli(p::MaybeRV{T}, ωid::Id = ωnew()) where T <: AbstractFloat = RandVar{Float64, true}(bernoulli, (p,), ωid)

"Categorical distribution with probability weight vector `p`"
categorical(ω::Omega, p::Vector) = quantile(Categorical(p), rand(ω))
categorical(p::MaybeRV{Vector{T}}, ωid::Id = ωnew()) where T <: Real = RandVar{Int, true}(categorical, (p,), ωid)

"Poisson distribution with rate parameter `λ`"
poisson(ω::Omega, λ::Real) = quantile(Poisson(λ), rand(ω)) # FIXME Wish rand wasn't here, should be pure
poisson(λ::MaybeRV{T}, ωid::Id = ωnew()) where T <: Real = RandVar{Int, true}(poisson, (λ,), ωid)

"Uniform distribution with lower bound `a` and upper bound `b`"
uniform(ω::Omega, a::T, b::T) where T = rand(ω) * (b - a) + a
uniform(a::MaybeRV{T}, b::MaybeRV{T}, ωid::Id=ωnew()) where T <: AbstractFloat =
  RandVar{T, true}(uniform, (a, b), ωid)


"Uniform sample from vector"
uniform(ω::Omega, a::T) where T = rand(ω, a)
uniform(a::MaybeRV{T}, ωid::Id=ωnew()) where T <: Vector =
  RandVar{T, true}(uniform, (a,), ωid)
  
  
"Discrete uniform distribution with range `range`"
uniform(range::UnitRange{T}, ωid=ωnew()) where T =
  RandVar{T, true}(rand, (range,), ωid)

"Multivariate Normal Distribution with mean vector `μ` and covariance `Σ`"
mvnormal(ω::Omega, μ, Σ) = rand(ω, MvNormal(μ, Σ))
mvnormal(μ::MaybeRV{T1}, Σ::MaybeRV{T2}, ωid::Id = ωnew()) where {T1, T2} = 
  RandVar{T1, true}(mvnormal, (μ, Σ), ωid)

"Normal Distribution with mean μ and variance σ"
normal(ω::Omega, μ, σ) = quantile(Normal(μ, σ), rand(ω))
# normal(ω::Omega, μ, σ) = rand(ω, Normal(μ, σ))
# normal(ω::Omega, μ, σ, ωid::Id = ωnew()) = normal(parent(ω)[ωid], μ, σ)
normal(μ::MaybeRV{T}, σ::MaybeRV{T}, ωid::Id = ωnew()) where T <: AbstractFloat = 
  RandVar{T, true}(normal, (μ, σ), ωid)