

# normal(ω::Omega, μ, σ, ωid::Id) = quantile(Normal(μ, σ), ω[ωid])
# normal(μ::T, σ::T, ωid::Int=ωnew()) where T = RandVar{T, true}(normal, (μ, σ, ωid))
# normal(μ::AbstractRandVar{T}, σ::T, ωid::Int=ωnew()) where T = RandVar{T, true}(normal, (μ, σ, ωid))
# normal(μ::T, σ::AbstractRandVar{T}, ωid::Int=ωnew()) where T = RandVar{T, true}(normal, (μ, σ, ωid))
# normal(μ::AbstractRandVar{T}, σ::AbstractRandVar{T}, ωid::Int=ωnew()) where T = RandVar{T, true}(normal, (μ, σ, ωid))

# "Gamma distribution"
# gammarv(ω::Omega, α, θ, ωi) = quantile(Gamma(α, θ), ω[ωi])
# gammarv(α::T, θ::T, ωid::Id = ωnew()) where T <: Real =
#   RandVar{T, true}(gammarv, (α, θ, ωid))
# gammarv(α::AbstractRandVar{T}, θ::T, ωid::Id = ωnew()) where T <: Real =
#   RandVar{T, true}(gammarv, (α, θ, ωid))
# gammarv(α::T, θ::AbstractRandVar{T}, ωid::Id = ωnew()) where T <: Real =
#   RandVar{T, true}(gammarv, (α, θ, ωid))
# gammarv(α::AbstractRandVar{T}, θ::AbstractRandVar{T}, ωid::Id = ωnew()) where T <: Real =
#   RandVar{T, true}(gammarv, (α, θ, ωid))
# Γ = gammarv

# "Dirichlet distribution"
# function dirichlet(α)
#   gammas = [gammarv(αi, 1.0) for αi in α]
#   Σ = sum(gammas)
#   [gamma/Σ for gamma in gammas]
# end

# # ## Problem here is that
# # "Dirichlet distribution"
# # function dirichlet(α, ω)
# #   gammas = [gammarv(αi, 1.0, ω) for αi in α]
# #   Σ = sum(gammas)
# #   [gamma/Σ for gamma in gammas]
# # end

# "Inverse Gamma"
# inversegamma(ω::Omega, α, θ, ωi) = quantile(InverseGamma(α, θ), ω[ωi])
# inversegamma(α::T, θ::T, ωid::Id = ωnew()) where T <: Real =
#   RandVar{T, true}(inversegamma, (α, θ, ωid))

# "Beta"
# beta(ω::Omega, α, β, ωid::Id) = quantile(Beta(α, β), ω[ωid])
# beta(α::T, β::T, ωid::Id=ωnew()) where T = RandVar{T, true}(Mu.beta, (α, β, ωid))

# "Bernoulli"
# bernoulli(ω::Omega, p, ωid::Id) = quantile(Bernoulli(p), ω[ωid])
# bernoulli(p::T, ωid::Id = ωnew()) where T <: Real = RandVar{T, true}(bernoulli, (p, ωid))
# bernoulli(p::RandVar{T}, ωid::Id = ωnew()) where T = RandVar{T, true}(bernoulli, (p, ωid))

# "Categorical"
# categorical(ω::Omega, p, ωid::Id) = quantile(Categorical(p), ω[ωid])
# categorical(p::Array{T, 1}, ωid::Id = ωnew()) where T <: Real = RandVar{Int, true}(categorical, (p, ωid))
# categorical(p::RandVar{Array{T, 1}, true}, ωid::Id = ωnew()) where T =
#                                         RandVar{Int, true}(categorical, (p, ωid))

# "`uniform(a, b)`"
# uniform(ω::Omega, a::T, b::T, ωid::Id) where T = ω[ωid] * (b - a) + a
# uniform(a::T, b::T, ωid::Id=ωnew()) where T = RandVar{T, true, typeof(uniform), Tuple{T, T, Id}}(uniform, (a, b, ωid))
# uniform(a::AbstractRandVar{T}, b::T, ωid::Id=ωnew()) where T = RandVar{T, true}(uniform, (a, b, ωid))
# uniform(a::T, b::AbstractRandVar{T}, ωid::Id=ωnew()) where T = RandVar{T, true}(uniform, (a, b, ωid))
# uniform(a::AbstractRandVar{T}, b::AbstractRandVar{T}, ωid::Id=ωnew()) where T = RandVar{T, true}(uniform, (a, b, ωid))

# "Poisson"
# poisson(ω::Omega, λ, ωid::Id) = quantile(Poisson(λ), ω[ωid])
# poisson(λ::T, ωid::Id = ωnew()) where T <: Real = RandVar{T, true}(poisson, (λ, ωid))
# poisson(λ::RandVar{T}, ωid::Id = ωnew()) where T = RandVar{T, true}(poisson, (λ, ωid))


# "Discrete Uniform"
uniform(range::UnitRange{T}, ωid=ωnew()) where T =
  RandVar{T, true}(rand, (range,), ωid)

# Multivariate Normal Distribution
mvnormal(ω::Omega, μ, Σ) = rand(ω, MvNormal(μ, Σ))
mvnormal(μ::T1, Σ::T2, ωid::LazyId=LazyId()) where {T1, T2} = 
  RandVar{T1, true}(mvnormal, (μ, Σ), ωid)
mvnormal(μ::AbstractRandVar{T}, Σ::T, ωid::LazyId=LazyId()) where T = 
  RandVar{T, true}(mvnormal, (μ, Σ), ωid)
mvnormal(μ::T, Σ::AbstractRandVar{T}, ωid::LazyId=LazyId()) where T = 
  RandVar{T, true}(mvnormal, (μ, Σ), ωid)
mvnormal(μ::AbstractRandVar{T}, Σ::AbstractRandVar{T}, ωid::LazyId=LazyId()) where T = 
  RandVar{T, true}(mvnormal, (μ, Σ), ωid)

# Normal Distribution
normal(ω::Omega, μ, σ) = rand(ω, Normal(μ, σ))
normal(μ::T, σ::T, ωid::Int=ωnew()) where T <: AbstractFloat = 
  RandVar{T, true}(normal, (μ, σ), ωid)
normal(μ::AbstractRandVar{T}, σ::T, ωid::Int=ωnew()) where T <: AbstractFloat = 
  RandVar{T, true}(normal, (μ, σ), ωid)
normal(μ::T, σ::AbstractRandVar{T}, ωid::Int=ωnew()) where T <: AbstractFloat = 
  RandVar{T, true}(normal, (μ, σ), ωid)
normal(μ::AbstractRandVar{T}, σ::AbstractRandVar{T}, ωid::Int=ωnew()) where T <: AbstractFloat = 
  RandVar{T, true}(normal, (μ, σ), ωid)