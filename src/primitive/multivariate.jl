# "Dirichlet distribution"
# abstract type Dirichlet <: Dist end

# function dirichlet(ω::Ω, α)
#   gammas = [gammarv(ω[@id][i], αi, 1.0) for (i, αi) in enumerate(α)]
#   Σ = sum(gammas)
#   [gamma/Σ for gamma in gammas]
# end
# # FIXME: Type
# dirichlet(α::MaybeRV{T}) where T = RandVar{T, Dirichlet}(dirichlet, (α,))

# _rand!(rng::AbstractRNG, d::Djl.MvNormal, x::VecOrMat) = add!(unwhiten!(d.Σ, randn!(rng, x)), d.μ)

# mvchol(x, μ, Σ::PDMat) = Distributions.unwhiten(Σ, x) .+ μ

# "Multivariate Normal Distribution with mean vector `μ` and covariance `Σ`"
# abstract type MvNormal <: Dist end

# mvnormal(ω::Ω, μ::Vector, Σ::PDMat) = mvchol(normal(ω, 0.0, 1.0, size(μ)), μ, Σ)
# # mvnormal(ω::Ω, μ, Σ) = rand(ω, MvNormal(μ, Σ))
# mvnormal(μ::MaybeRV{T1}, Σ::MaybeRV{T2}) where {T1, T2} =
#   RandVar{T1, MvNormal}(mvnormal, (μ, PDMat(Σ)))

# lift(:PDMat, 1)
