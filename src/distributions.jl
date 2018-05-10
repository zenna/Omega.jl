MaybeRV{T} = Union{T, AbstractRandVar{T}} where T
Dims = UTuple{Int}

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
  gammas = [gammarv(ω[@id][i], αi, 1.0) for (i, αi) in enumerate(α)]
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

boolbernoulli(args...) = RandVar{SoftBool, false}(SoftBool, (bernoulli(args...),))

"Rademacher distribution"
rademacher(p::MaybeRV{T}, ωid::Id = ωnew()) where T = bernoulli(p, ωid::Id) * 2.0 - 1.0

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
uniform(ω::Omega, a, b, sz::Dims) = p = rand(ω, sz) .* (b .- a) .+ a
uniform(a::MaybeRV{T}, b::MaybeRV{T}, ωid::Id = ωnew()) where T =
  RandVar{T, true}(uniform, (a, b), ωid)
uniform(a::MaybeRV{T}, b::MaybeRV{T}, dims::MaybeRV{Dims{N}}, ωid::Id = ωnew()) where {N, T} =
  RandVar{Array{T, N}, true}(uniform, (a, b, dims), ωid)

"Uniform sample from vector"
uniform(ω::Omega, a::T) where T = rand(ω, a)
uniform(a::MaybeRV{T}, ωid::Id=ωnew()) where T <: Vector =
  RandVar{T, true}(uniform, (a,), ωid)

"Discrete uniform distribution with range `range`"
uniform(range::UnitRange{T}, ωid=ωnew()) where T =
  RandVar{T, true}(rand, (range,), ωid)



"Normal Distribution with mean μ and variance σ"
normalinvt(p, μ, σ) = quantile(Normal(μ, σ), p)
normal(ω::Omega, μ, σ) = normalinvt(rand(ω), μ, σ)
normal(ω::Omega, μ, σ, sz::Dims) = normalinvt.(rand(ω, sz), μ, σ)
normal(μ::MaybeRV{T}, σ::MaybeRV{T}, ωid::Id = ωnew()) where T <: AbstractFloat =
  RandVar{T, true}(normal, (μ, σ), ωid)
normal(μ::MaybeRV{T}, σ::MaybeRV{T}, dims::MaybeRV{Dims{N}}, ωid::Id = ωnew()) where {N, T <: AbstractFloat} =
  RandVar{Array{T, N}, true}(normal, (μ, σ, dims), ωid)
# normal(ω::Omega, μ, σ) = rand(ω, Normal(μ, σ))
# normal(ω::Omega, μ, σ, ωid::Id = ωnew()) = normal(parent(ω)[ωid], μ, σ)

_rand!(rng::AbstractRNG, d::MvNormal, x::VecOrMat) = add!(unwhiten!(d.Σ, randn!(rng, x)), d.μ)

mvchol(x, μ, Σ::PDMat) = Distributions.unwhiten(Σ, x) .+ μ
"Multivariate Normal Distribution with mean vector `μ` and covariance `Σ`"
mvnormal(ω::Omega, μ::Vector, Σ::PDMat) = mvchol(normal(ω, 0.0, 1.0, size(μ)), μ, Σ)
# mvnormal(ω::Omega, μ, Σ) = rand(ω, MvNormal(μ, Σ))
mvnormal(μ::MaybeRV{T1}, Σ::MaybeRV{T2}, ωid::Id = ωnew()) where {T1, T2} =
  RandVar{T1, true}(mvnormal, (μ, PDMat(Σ)), ωid)

lift(:PDMat, 1)

"Logistic Distribution"
logistic(ω::Omega, μ, s) = (p = rand(ω); μ + s * log(p / (1 - p)))
logistic(ω::Omega, μ::Array, s::Array) = (p = rand(ω, size(μ)); μ .+ s .* log.(p ./ (1 .- p)))
logistic(ω::Omega, μ, s, sz::Dims) =  (p = rand(ω, sz); μ .+ s .* log.(p ./ (1 .- p)))
logistic(μ::MaybeRV{T}, s::MaybeRV{T}, ωid::Id = ωnew()) where T =
  RandVar{T, true}(logistic, (μ, s), ωid)
logistic(μ::MaybeRV{T}, s::MaybeRV{T}, dims::MaybeRV{Dims{N}}, ωid::Id = ωnew()) where {N, T} =
  RandVar{Array{T, N}, true}(logistic, (μ, s, dims), ωid)

exponential(ω::Omega, λ) = -log(1 - rand(ω)) / λ
exponential(ω::Omega, λ, sz::Dims) = log.(1 - rand(ω, sz)) ./ λ
exponential(λ::MaybeRV{T}, ωid::Id = ωnew()) where T = RandVar{T, true}(exponential, (λ,), ωid)
exponential(λ::MaybeRV{T}, dims::MaybeRV{Dims{N}}, ωid::Id = ωnew()) where {N, T} = RandVar{T, true}(exponential, (λ, dims), ωid)

"Kumaraswamy distribution, similar to beta but easier"
kumaraswamyinvcdf(p, a, b) = (1 - (1 - p)^(1/b))^(1/a)
kumaraswamy(ω::Omega, a, b) = kumaraswamyinvcdf(rand(ω), a, b)
kumaraswamy(ω::Omega, a, b, dims::Dims) = kumaraswamyinvcdf.(rand(ω, dims), a, b)
kumaraswamy(a::MaybeRV{T}, b::MaybeRV{T}, ωid::Id = ωnew()) where T =
  RandVar{T, true}(kumaraswamy, (a, b), ωid)
kumaraswamy(a::MaybeRV{T}, b::MaybeRV{T}, dims::MaybeRV{Dims{N}}, ωid::Id = ωnew()) where {N, T} =
  RandVar{T, true}(kumaraswamy, (a, b, dims), ωid)
