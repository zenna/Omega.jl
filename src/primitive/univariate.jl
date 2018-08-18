
# Beta
struct Beta{T, A <: MaybeRV{T}, B <: MaybeRV{T}} <: PrimRandVar{T}
  α::A
  β::B
  id::ID
  Beta(α::MaybeRV{T}, β::MaybeRV{T}, id = uid()) where T = new{T, typeof(α), typeof(β)}(α, β, id)
end
rvtransform(rv::Beta, ω, α, β) = quantile(Djl.Beta(α, β), rand(ω))
betarv(α::T, β::T) where {T <: Real} = Beta{T, T, T}(α, β, uid())
betarv(α::MaybeRV{T}, β::MaybeRV{T}) where {T <: Real} = Beta(α, β, uid())
const β = betarv
@inline (rv::Beta)(ω::Ω) = apl(rv, ω)

# Bernoulli
struct Bernoulli{T, A <: MaybeRV} <: PrimRandVar{T}
  p::A
  id::ID
end
@inline (rv::Bernoulli)(ω::Ω) = apl(rv, ω)
bernoulli(ω, p, T::Type{RTT} = Int) where {RTT <: Real} = T(quantile(Djl.Bernoulli(p), rand(ω)))
ppapl(rv::Bernoulli{T}, ωπ) where T = bernoulli(ωπ, reify(ωπ, params(rv))..., T)
rvtransform(::Bernoulli) = bernoulli
bernoulli(p::MaybeRV{T}, RT::Type{RTT} = Int) where {T <: Real, RTT <: Real} = Bernoulli{RT, typeof(p)}(p, uid())

"Categorical distribution with probability weight vector `p`"
struct Categorical{T, A} <: PrimRandVar{T}
  p::A  # Probability Vector
  Categorical(p::A, T = Int, id = uid()) where A = new{T, A}(p)
end
@inline (rv::Categorical)(ω::Ω) = apl(rv, ω)
categorical(ω::Ω, p::Vector) = quantile(Djl.Categorical(p), rand(ω))
categorical(p::MaybeRV{Vector{T}}) where T <: Real = Categorical(p)

"Constant random variable which always outputs `c`"
constant(c::T) where T = URandVar{T}(ω -> c)

struct Gamma{T, A <: MaybeRV{T}, B <: MaybeRV{T}} <: PrimRandVar{T}
  α::A
  θ::B
  id::ID
  Gamma(α::MaybeRV{T}, θ::MaybeRV{T}) where T = new{T, typeof(α), typeof(θ)}(α, θ)
end
@inline (rv::Gamma)(ω::Ω) = apl(rv, ω)
gammarv(ω::Ω, α::Real, θ::Real) = quantile(Djl.Gamma(α, θ), rand(ω))
gammarv(α::MaybeRV{T}, θ::MaybeRV{T}) where T <: Real = Gamma(α, θ)
const Γ = gammarv

struct InverseGamma{T, A, B} <: PrimRandVar{T}
  α::A
  θ::B
  id::ID
  InverseGamma(α::MaybeRV{T}, θ::MaybeRV{T}) where T = new{T, typeof(α), typeof(θ)}(α, θ)
end
@inline (rv::InverseGamma)(ω::Ω) = apl(rv, ω)
invgamma(ω::Ω, α::Real, θ::Real) = quantile(Djl.InverseGamma(α, θ), rand(ω))
invgamma(α::MaybeRV{T}, θ::MaybeRV{T}) where T <: Real = InverseGamma(α, θ)
const invΓ = invgamma

"Rademacher distribution"
struct Rademacher{T} <: PrimRandVar{T}
  id::ID
  Rademacher{T}(id = uid()) where T = new{T}(id) 
end
@inline (rv::Rademacher)(ω::Ω) = apl(rv, ω)
rademacher(ω::Ω) = bernoulli(ω, 0.5) * 2 - 1
rademacher(T = Int) = Rademacher{T}()

"Poisson distribution with rate parameter `λ`"
struct Poisson{T, A <: MaybeRV} <: PrimRandVar{T}
  λ::A
  id::ID
end
@inline (rv::Poisson)(ω::Ω) = apl(rv, ω)
rvtransform(::Poisson) = poisson
poisson(ω::Ω, λ::Real) = quantile(Djl.Poisson(λ), rand(ω))
poisson(λ::MaybeRV{T}) where T <: Real = Poisson{Int, typeof(λ)}(λ, uid())

"Normal Distribution with mean μ and variance σ"
struct Normal{T, A <: MaybeRV{T}, B <: MaybeRV{T}} <: PrimRandVar{T}
  μ::A
  σ::B
  id::ID
end
@inline (rv::Normal)(ω::Ω) = apl(rv, ω)
# params(rv::Normal) = (rv.μ, rv.σ)
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
rvtransform(::Logistic) = logistic
logistic(ω::Ω, μ, s) = (p = rand(ω); μ + s * log(p / (1 - p)))
logistic(ω::Ω, μ::Array, s::Array) = (p = rand(ω, size(μ)); μ .+ s .* log.(p ./ (1 .- p)))
logistic(μ::MaybeRV{T}, s::MaybeRV{T}) where T = Logistic{T}(μ, s, uid())
logistic(μ::MaybeRV{T}, s::MaybeRV{T}, sz::NTuple{N, Int}) where {N, T <: Real} =
  Logistic{Array{T, N}}(fill(μ, sz), fill(s, sz))

"Exponential Distribution with λ"
struct Exponential{T, A} <: PrimRandVar{T}
  λ::A
end
@inline (rv::Exponential)(ω::Ω) = apl(rv, ω)
rvtransform(::Exponential) = exponential
exponential(ω::Ω, λ) = -log(1 - rand(ω)) / λ
exponential(λ::MaybeRV{T}) where T = Exponential{T}(λ)

"Kumaraswamy distribution, similar to beta but easier"
struct Kumaraswamy{T, A, B} <: PrimRandVar{T}
  a::A
  b::B
end
@inline (rv::Kumaraswamy)(ω::Ω) = apl(rv, ω)
rvtransform(::Kumaraswamy) = kumaraswamy
kumaraswamyinvcdf(p, a, b) = (1 - (1 - p)^(1/b))^(1/a)
kumaraswamy(ω::Ω, a, b) = kumaraswamyinvcdf(rand(ω), a, b)
kumaraswamy(a::MaybeRV{T}, b::MaybeRV{T}) where T = Kumaraswamy(a, b)

"Uniform between `a` and `b`"
struct Uniform{T, A <: MaybeRV{T}, B <: MaybeRV{T}} <: PrimRandVar{T}
  a::A
  b::B
  id::ID
  Uniform{T}(a::A, b::B, id = uid()) where {T, A, B} = new{T, A, B}(a, b, id)
end
@inline (rv::Uniform)(ω::Ω) = apl(rv, ω)
rvtransform(::Uniform) = uniform

"Uniform distribution with lower bound `a` and upper bound `b`"
uniform(ω::Ω, a::T, b::T) where T = rand(ω) * (b - a) + a
uniform(a::MaybeRV{T}, b::MaybeRV{T}) where T <: Real = Uniform{T}(a, b, uid())

struct UniformChoice{T, A} <: PrimRandVar{T}
  values::A
  id::ID
  UniformChoice(values::A, id = uid()) where A = new{elemtype(values), A}(values, id)
end

@inline (rv::UniformChoice)(ω::Ω) = apl(rv, ω)
rvtransform(::UniformChoice) = uniform

"Uniformly distributed over values of `a`"
uniform(ω::Ω, a) = rand(ω, a)

"Discrete uniform distribution over unit range `range`"
uniform(range::MaybeRV{UnitRange}) = UniformChoice(range)

"Discrete uniform distribution over array"
uniform(arr::MaybeRV{Array}) = UniformChoice(arr)