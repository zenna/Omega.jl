MaybeRV{T} = Union{T, RandVar{T}} where T

abstract type PrimRandVar{T} <: RandVar{T} end

struct Beta{T, A <: MaybeRV{T}, B <: MaybeRV{T}} <: PrimRandVar{T}
  α::A
  β::B
  id::Int
end

params(rv::Beta) = (rv.α, rv.β)
transform(ω, α, β) = quantile(Djl.Beta(α, β), rand(ω))
fapl(rv::Beta{T, T, T}, ωπ::ΩProj) where {T <: Float64} = transform(ωπ, rv.α, rv.β)
fapl(rv::Beta, ωπ::ΩProj) = transform(ωπ, reify(ωπ, params(rv))...)

reify(ω, params) = map(x -> apl(x, ω), params)

# Constructors
betarv(alpha::T, beta::T) where {T <: Real} = Beta{T, T, T}(alpha, beta, uid())
betarv(alpha::MaybeRV{T}, beta::MaybeRV{T}) where {T <: Real} = Beta{T, typeof(alpha), typeof(beta)}(alpha, beta, uid())

const β = betarv
@inline (rv::Beta)(ω::Ω) = apl(rv, ω)

# abstract type Beta <: Dist end
# "Beta distribution (alias β) parameters `α`  and `β`"
# betarv(ω::Ω, α::AbstractFloat, β::AbstractFloat) = quantile(Djl.Beta(α, β), rand(ω))
# betarv(α::MaybeRV{T}, β::MaybeRV{T}) where T <: AbstractFloat = RandVar{T, Beta}(Omega.betarv, (α, β))
# const β = betarv

# ## ===============================================================================================

# abstract type Beta <: Dist end
# "Beta distribution (alias β) parameters `α`  and `β`"
# betarv(ω::Ω, α::AbstractFloat, β::AbstractFloat) = quantile(Djl.Beta(α, β), rand(ω))
# betarv(α::MaybeRV{T}, β::MaybeRV{T}) where T <: AbstractFloat = RandVar{T, Beta}(Omega.betarv, (α, β))
# const β = betarv

# abstract type Bernoulli <: Dist end
# "Bernoulli with weight `p`"
# bernoulli(ω::Ω, p::AbstractFloat) = quantile(Djl.Bernoulli(p), rand(ω))
# bernoulli(p::MaybeRV{T}) where T <: AbstractFloat = RandVar{Float64, Bernoulli}(bernoulli, (p,))

# "Bool - valued Bernoulli distribution (as opposed to Float64 valued)"
# boolbernoulli(args...) = RandVar{Bool, Bernoulli}(Bool, (bernoulli(args...),))

# abstract type Constant <: Dist end
# "Constant Random Variable"
# constant(x::T) where T = RandVar{T, Constant}(ω -> x, ())

# "Gamma distribution (alias Γ)"
# abstract type Gamma <: Dist end

# gammarv(ω::Ω, α::AbstractFloat, θ::AbstractFloat) = quantile(Djl.Gamma(α, θ), rand(ω))
# gammarv(α::MaybeRV{T}, θ::MaybeRV{T}) where T <: Real =
#   RandVar{T, Gamma}(gammarv, (α, θ))
# const Γ = gammarv

# "Inverse Gamma distribution"
# abstract type InverseGamma <: Dist end

# inversegamma(ω::Ω, α, θ, ωi) = quantile(Djl.InverseGamma(α, θ), rand(ω))
# inversegamma(α::MaybeRV{T}, θ::MaybeRV{T}) where T <: Real =
#   RandVar{T, InverseGamma}(inversegamma, (α, θ))

# "Dirichlet distribution"
# abstract type Dirichlet <: Dist end

# function dirichlet(ω::Ω, α)
#   gammas = [gammarv(ω[@id][i], αi, 1.0) for (i, αi) in enumerate(α)]
#   Σ = sum(gammas)
#   [gamma/Σ for gamma in gammas]
# end
# # FIXME: Type
# dirichlet(α::MaybeRV{T}) where T = RandVar{T, Dirichlet}(dirichlet, (α,))

# "Rademacher distribution"
# abstract type Rademacher <: Dist end
# rademacher(ω::Ω, p) = bernoulli(ω, p) * 2.0 - 1.0
# rademacher(p::MaybeRV{T}) where T = RandVar{T, Rademacher}(rademacher, (p,))

# "Categorical distribution with probability weight vector `p`"
# abstract type Categorical <: Dist end
# categorical(ω::Ω, p::Vector) = quantile(Djl.Categorical(p), rand(ω))
# categorical(p::MaybeRV{Vector{T}}) where T <: Real = RandVar{Int, Categorical}(categorical, (p,))

# "Poisson distribution with rate parameter `λ`"
# abstract type Poisson <: Dist end
# poisson(ω::Ω, λ::Real) = quantile(Djl.Poisson(λ), rand(ω))
# poisson(λ::MaybeRV{T}) where T <: Real = RandVar{Int, Poisson}(poisson, (λ,))

# "Uniform distribution with lower bound `a` and upper bound `b`"
# abstract type Uniform <: Dist end
# uniform(ω::Ω, a::T, b::T) where T = rand(ω) * (b - a) + a
# uniform(a::MaybeRV{T}, b::MaybeRV{T}) where T <: AbstractFloat =
#   RandVar{T, Uniform}(uniform, (a, b))
# uniform(ω::Ω, a, b, sz::Dims) = p = rand(ω, sz) .* (b .- a) .+ a
# uniform(a::MaybeRV{T}, b::MaybeRV{T}) where T =
#   RandVar{T, Uniform}(uniform, (a, b))
# uniform(a::MaybeRV{T}, b::MaybeRV{T}, dims::MaybeRV{Dims{N}}) where {N, T} =
#   RandVar{Array{T, N}, Uniform}(uniform, (a, b, dims))

# "Uniform sample from vector"
# uniform(ω::Ω, a::T) where T = rand(ω, a)
# uniform(a::MaybeRV{T}) where {V, T <: Vector{V}} =
#   RandVar{V, Uniform}(uniform, (a,))

# "Discrete uniform distribution with range `range`"
# uniform(range::UnitRange{T}) where T = RandVar{T, Uniform}(rand, (range,))

# normalinvt(p, μ, σ) = quantile(Normal(μ, σ), p)

# "Normal Distribution with mean μ and variance σ"
# abstract type Normal <: Dist end

# normal(ω::Ω, μ, σ) = normalinvt(rand(ω), μ, σ)
# normal(ω::Ω, μ, σ, sz::Dims) = normalinvt.(rand(ω, sz), μ, σ)
# normal(μ::MaybeRV{T}, σ::MaybeRV{T}) where T <: AbstractFloat =
#   RandVar{T, Normal}(normal, (μ, σ))
# normal(μ::MaybeRV{T}, σ::MaybeRV{T}, dims::MaybeRV{Dims{N}}) where {N, T <: AbstractFloat} =
#   RandVar{Array{T, N}, Normal}(normal, (μ, σ, dims))
# # normal(ω::Ω, μ, σ) = rand(ω, Normal(μ, σ))
# # normal(ω::Ω, μ, σ) = normal(parent(ω)[ωid], μ, σ)

# _rand!(rng::AbstractRNG, d::Djl.MvNormal, x::VecOrMat) = add!(unwhiten!(d.Σ, randn!(rng, x)), d.μ)

# mvchol(x, μ, Σ::PDMat) = Distributions.unwhiten(Σ, x) .+ μ

# "Multivariate Normal Distribution with mean vector `μ` and covariance `Σ`"
# abstract type MvNormal <: Dist end

# mvnormal(ω::Ω, μ::Vector, Σ::PDMat) = mvchol(normal(ω, 0.0, 1.0, size(μ)), μ, Σ)
# # mvnormal(ω::Ω, μ, Σ) = rand(ω, MvNormal(μ, Σ))
# mvnormal(μ::MaybeRV{T1}, Σ::MaybeRV{T2}) where {T1, T2} =
#   RandVar{T1, MvNormal}(mvnormal, (μ, PDMat(Σ)))

# lift(:PDMat, 1)

# "Logistic Distribution"
# abstract type Logistic <: Dist end
# logistic(ω::Ω, μ, s) = (p = rand(ω); μ + s * log(p / (1 - p)))
# logistic(ω::Ω, μ::Array, s::Array) = (p = rand(ω, size(μ)); μ .+ s .* log.(p ./ (1 .- p)))
# logistic(ω::Ω, μ, s, sz::Dims) =  (p = rand(ω, sz); μ .+ s .* log.(p ./ (1 .- p)))
# logistic(μ::MaybeRV{T}, s::MaybeRV{T}) where T =
#   RandVar{T, Logistic}(logistic, (μ, s))
# logistic(μ::MaybeRV{T}, s::MaybeRV{T}, dims::MaybeRV{Dims{N}}) where {N, T} =
#   RandVar{Array{T, N}, Logistic}(logistic, (μ, s, dims))

# "Exponential Distribution with λ"
# abstract type Exponential <: Dist end
# exponential(ω::Ω, λ) = -log(1 - rand(ω)) / λ
# exponential(ω::Ω, λ, sz::Dims) = log.(1 - rand(ω, sz)) ./ λ
# exponential(λ::MaybeRV{T}) where T = RandVar{T, Exponential}(exponential, (λ,))
# exponential(λ::MaybeRV{T}, dims::MaybeRV{Dims{N}}) where {N, T} = RandVar{T, Exponential}(exponential, (λ, dims))

# kumaraswamyinvcdf(p, a, b) = (1 - (1 - p)^(1/b))^(1/a)

# "Kumaraswamy distribution, similar to beta but easier"
# abstract type Kumaraswamy <: Dist end

# kumaraswamy(ω::Ω, a, b) = kumaraswamyinvcdf(rand(ω), a, b)
# kumaraswamy(ω::Ω, a, b, dims::Dims) = kumaraswamyinvcdf.(rand(ω, dims), a, b)
# kumaraswamy(a::MaybeRV{T}, b::MaybeRV{T}) where T =
#   RandVar{T, Kumaraswamy}(kumaraswamy, (a, b))
# kumaraswamy(a::MaybeRV{T}, b::MaybeRV{T}, dims::MaybeRV{Dims{N}}) where {N, T} =
#   RandVar{T, Kumaraswamy}(kumaraswamy, (a, b, dims))
