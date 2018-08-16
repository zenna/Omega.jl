"Primitive random variable of known distribution"
abstract type PrimRandVar{T} <: RandVar{T} end  

name(t::T) where {T <: PrimRandVar} = t.name.name
name(::T) where {T <: PrimRandVar} = Symbol(T)
ppapl(rv::PrimRandVar, ωπ) = rvtransform(rv)(ωπ, reify(ωπ, params(rv))...)
id(rv::PrimRandVar) = rv.id

# Beta
struct Beta{T, A <: MaybeRV{T}, B <: MaybeRV{T}} <: PrimRandVar{T}
  α::A
  β::B
  id::ID
end
params(rv::Beta) = (rv.α, rv.β)
rvtransform(rv::Beta, ω, α, β) = quantile(Djl.Beta(α, β), rand(ω))

ppapl(rv::Beta{T, T, T}, ωπ::ΩProj) where {T <: Float64} = rvtransform(rv, ωπ, rv.α, rv.β)
betarv(alpha::T, beta::T) where {T <: Real} = Beta{T, T, T}(alpha, beta, uid())
betarv(alpha::MaybeRV{T}, beta::MaybeRV{T}) where {T <: Real} = Beta{T, typeof(alpha), typeof(beta)}(alpha, beta, uid())
const β = betarv
@inline (rv::Beta)(ω::Ω) = apl(rv, ω)

# Bernoulli
struct Bernoulli{T, A <: MaybeRV} <: PrimRandVar{T}
  p::A
  id::ID
end
@inline (rv::Bernoulli)(ω::Ω) = apl(rv, ω)
params(rv::Bernoulli) = (rv.p,)
bernoulli(ω, p, T::Type{RTT} = Int) where {RTT <: Real} = T(quantile(Djl.Bernoulli(p), rand(ω)))
ppapl(rv::Bernoulli{T}, ωπ) where T = bernoulli(ωπ, reify(ωπ, params(rv))..., T)

rvtransform(::Bernoulli) = bernoulli
bernoulli(p::MaybeRV{T}, RT::Type{RTT} = Int) where {T <: Real, RTT <: Real} = Bernoulli{RT, typeof(p)}(p, uid())

"Constant Random Variable"
constant(x::T) where T = URandVar{T}(ω -> x)

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

"Poisson distribution with rate parameter `λ`"
struct Poisson{T, A <: MaybeRV} <: PrimRandVar{T}
  λ::A
  id::ID
end
@inline (rv::Poisson)(ω::Ω) = apl(rv, ω)
params(rv::Poisson) = (rv.λ,)
rvtransform(::Poisson) = poisson

poisson(ω::Ω, λ::Real) = quantile(Djl.Poisson(λ), rand(ω))
poisson(λ::MaybeRV{T}) where T <: Real = Poisson{Int, typeof(λ)}(λ, uid())

# Uniform
struct Uniform{T, A <: MaybeRV{T}, B <: MaybeRV{T}} <: PrimRandVar{T}
  a::A
  b::B
  id::ID
  Uniform{T}(a::A, b::B, id = uid()) where {T, A, B} = new{T, A, B}(a, b, id)
end
@inline (rv::Uniform)(ω::Ω) = apl(rv, ω)
params(rv::Uniform) = (rv.a, rv.b)
rvtransform(::Uniform) = uniform

"Uniform distribution with lower bound `a` and upper bound `b`"
uniform(ω::Ω, a::T, b::T) where T = rand(ω) * (b - a) + a
uniform(a::MaybeRV{T}, b::MaybeRV{T}) where T <: Real = Uniform{T}(a, b, uid())

# "Uniform sample from vector"
# uniform(ω::Ω, a::T) where T = rand(ω, a)
# uniform(a::MaybeRV{T}) where {V, T <: Vector{V}} =
#   RandVar{V, Uniform}(uniform, (a,))

# "Discrete uniform distribution with range `range`"
# uniform(range::UnitRange{T}) where T = RandVar{T, Uniform}(rand, (range,))

"Normal Distribution with mean μ and variance σ"
struct Normal{T, A <: MaybeRV{T}, B <: MaybeRV{T}} <: PrimRandVar{T}
  μ::A
  σ::B
  id::ID
end
@inline (rv::Normal)(ω::Ω) = apl(rv, ω)
params(rv::Normal) = (rv.μ, rv.σ)
normal(ω::Ω, μ, σ) = quantile(Djl.Normal(μ, σ), rand(ω))
rvtransform(::Normal) = normal
normal(μ::MaybeRV{T}, σ::MaybeRV{T}) where T <: AbstractFloat = Normal{T, typeof(μ), typeof(σ)}(μ, σ, uid())


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

"Logistic Distribution with mean μ and shape s"
struct Logistic{T, A <: MaybeRV{T}, B <: MaybeRV{T}} <: PrimRandVar{T}
  μ::A
  s::B
  id::ID
  Logistic{T}(μ::A, s::B, id = uid()) where {T, A, B} = new{T, A, B}(μ, s, id)
end
@inline (rv::Logistic)(ω::Ω) = apl(rv, ω)
params(rv::Logistic) = (rv.μ, rv.s)
rvtransform(::Logistic) = logistic

logistic(ω::Ω, μ, s) = (p = rand(ω); μ + s * log(p / (1 - p)))
logistic(ω::Ω, μ::Array, s::Array) = (p = rand(ω, size(μ)); μ .+ s .* log.(p ./ (1 .- p)))
logistic(μ::MaybeRV{T}, s::MaybeRV{T}) where T = Logistic{T}(μ, s, uid())
logistic(μ::MaybeRV{T}, s::MaybeRV{T}, sz::NTuple{N, Int}) where {N, T <: Real} =
  Logistic{Array{T, N}}(fill(μ, sz), fill(s, sz))

@spec size(μ) == size(s)

# logistic(μ::MaybeRV{T}, s::MaybeRV{T}, dims::MaybeRV{Dims{N}}) where {N, T} =
#   RandVar{Array{T, N}, Logistic}(logistic, (μ, s, dims))

# logistic(ω::Ω, μ, s, sz::Dims) =  (p = rand(ω, sz); μ .+ s .* log.(p ./ (1 .- p)))
# logistic(ω::Ω, μ::Array, s::Array) = (p = rand(ω, size(μ)); μ .+ s .* log.(p ./ (1 .- p)))

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
