
struct Beta{A, B} <: PrimRandVar
  α::A
  β::B
  id::ID
  Beta(α::A, β::B, id = uid()) where {A, B} = new{A, B}(α, β, id)
end
@inline (rv::Beta)(ω::Ω) = apl(rv, ω)
rvtransform(rv::Beta) = betarv
betarv(p::Real, α::Real, β::Real) = quantile(Djl.Beta(α, β), p)
betarv(ω::Ω, α::Real, β::Real) = betarv(rand(ω), α, β)
betarv(ω::Ω, α, β) = (p = rand(ω, anysize(α, β)); betarv.(p, α, β))

betarv(α, β) = Beta(α, β)
betarv(α, β, sz::Dims) = Beta(lift(fill)(α, sz), lift(fill)(β, sz))
const β = betarv

"Bernoulli distribution"
struct Bernoulli{T, A} <: PrimRandVar
  p::A
  id::ID
  Bernoulli{T}(p::A, id = uid()) where {T, A} = new{T, A}(p, id)
end
@inline (rv::Bernoulli)(ω::Ω) = apl(rv, ω)
rvtransform(rv::Bernoulli) = bernoulli
bernoulli(p_::Real, p::Real, T::Type{RT} = Int) where RT =
  RT(quantile(Djl.Bernoulli(p), p_))
bernoulli(ω::Ω, p::Real, T = Int) = bernoulli(rand(ω), p, T)
bernoulli(ω::Ω, p, T = Int) = (p_ = rand(ω, size(p)); bernoulli.(p_, p, T))
ppapl(rv::Bernoulli{T}, ωπ) where T = bernoulli(ωπ, reify(ωπ, params(rv))..., T)

"$(SIGNATURES) Bernoulli distribution with weight `p` and return type `T`"
bernoulli(p, T::Type{RT} = Int) where RT = Bernoulli{RT}(p)
bernoulli(p, sz::Dims, T::Type{RT} = Int) where RT = Bernoulli{RT}(lift(fill)(p, sz))

"Categorical distribution with probability weight vector `p`"
struct Categorical{A} <: PrimRandVar
  p::A    # Probability Vector
  id::ID
  Categorical(p::A, id = uid()) where A = new{A}(p, id)
end
@inline (rv::Categorical)(ω::Ω) = apl(rv, ω)
rvtransform(rv::Categorical) = categorical
categorical(p_::Real, p::Vector) = quantile(Djl.Categorical(p), p_)
categorical(ω::Ω, p::Vector{<:Real}) = categorical(rand(ω), p)
categorical(ω::Ω, p) = categorical(rand(ω, size(p)), p)

categorical(p) = Categorical(p)
categorical(p, sz::Dims) = Categorical(lift(fill)(p, sz))

"Gamma distribution with parameters α, θ"
struct Gamma{A, B} <: PrimRandVar
  α::A
  θ::B
  id::ID
  Gamma(α::A, θ::B, id = uid()) where {A, B} = new{A, B}(α, θ, id)
end
@inline (rv::Gamma)(ω::Ω) = apl(rv, ω)
rvtransform(rv::Gamma) = gammarv
gammarv(p::Real, α::Real, θ::Real) = quantile(Djl.Gamma(α, θ), p)
gammarv(ω::Ω, α::Real, θ::Real) = gammarv(rand(ω), α, θ)
gammarv(ω::Ω, α, θ) = (p = rand(ω, anysize(α, θ)); gammarv.(p, α, θ))

gammarv(α, θ) = Gamma(α, θ)
gammarv(α, θ, sz::Dims) = Gamma(lift(fill)(α, sz), lift(fill)(θ, sz))
const Γ = gammarv

"Gamma distribution with parameters α, θ"
struct InverseGamma{A, B} <: PrimRandVar
  α::A
  θ::B
  id::ID
  InverseGamma(α::A, θ::B, id = uid()) where {A, B} = new{A, B}(α, θ, id)
end
@inline (rv::InverseGamma)(ω::Ω) = apl(rv, ω)
rvtransform(rv::InverseGamma) = invgammarv
invgammarv(p::Real, α::Real, θ::Real) = quantile(Djl.InverseGamma(α, θ), p)
invgammarv(ω::Ω, α::Real, θ::Real) = invgammarv(rand(ω), α, θ)
invgammarv(ω::Ω, α, θ) = (p = rand(ω, anysize(α, θ)); invgammarv.(p, α, θ))

invgammarv(α, θ) = InverseGamma(α, θ)
invgammarv(α, θ, sz::Dims) = InverseGamma(lift(fill)(α, sz), lift(fill)(θ, sz))
const invΓ = invgammarv

"Rademacher distribution"
struct Rademacher{T} <: PrimRandVar
  id::ID
  Rademacher{T}(id = uid()) where {T, A} = new{T}(id)
end
@inline (rv::Rademacher)(ω::Ω) = apl(rv, ω)
rvtransform(::Rademacher) = rademacher
rademacher(p::Real, T::Type{RT} = Int) where RT = bernoulli(p, 0.5, RT) * 2 - 1
rademacher(ω::Ω, T::Type{RT} = Int) where RT = rademacher(rand(ω), RT)

rademacher(p, T::Type{RT} = Int) where RT = Rademacher{RT}()
# FIXME: Nowhere to put size info, since rademacher has no params.  Flaw in design?!

"Poisson distribution with rate parameter `λ`"
struct Poisson{A} <: PrimRandVar
  λ::A
  id::ID
  Poisson(λ::A, id = uid()) where A = new{A}(λ, id)
end
@inline (rv::Poisson)(ω::Ω) = apl(rv, ω)
rvtransform(::Poisson) = poisson
poisson(p::Real, λ::Real) = quantile(Djl.Poisson(λ), p)
poisson(ω::Ω, λ::Real) = poisson(rand(ω), λ)
poisson(ω::Ω, λ) = (p = rand(ω, size(λ)); poisson.(p, λ))

poisson(λ) = Poisson(λ)
poisson(λ, sz::Dims) = Poisson(lift(fill(λ, sz)))

"Normal distribution with parameters μ, σ"
struct Normal{A, B} <: PrimRandVar
  μ::A
  σ::B
  id::ID
  Normal(μ::A, σ::B, id = uid()) where {A, B} = new{A, B}(μ, σ, id)
end
@inline (rv::Normal)(ω::Ω) = apl(rv, ω)
rvtransform(rv::Normal) = normal
normal(p::Real, μ::Real, σ::Real) = quantile(Djl.Normal(μ, σ), p)
normal(ω::Ω, μ::Real, σ::Real) = normal(rand(ω), μ, σ)
normal(ω::Ω, μ, σ) = (p = rand(ω, anysize(μ, σ)); normal.(p, μ, σ))

normal(μ, σ) = Normal(μ, σ)
normal(μ, σ, sz::Dims) = Normal(lift(fill)(μ, sz), lift(fill)(σ, sz))

"Logistic Distribution with mean μ and shape s"
struct Logistic{A, B} <: PrimRandVar
  μ::A
  s::B
  id::ID
  Logistic(μ::A, s::B, id = uid()) where {A, B} = new{A, B}(μ, s, id)
end
@inline (rv::Logistic)(ω::Ω) = apl(rv, ω)
rvtransform(::Logistic) = logistic
logistic(p::Real, μ::Real, s::Real) = μ + s * log(p / (1 - p))
logistic(ω::Ω, μ::Real, s::Real) = logistic(rand(ω), μ, s)
logistic(ω::Ω, μ::Real, s::Real, dims::Dims) = logistic.(rand(ω, dims), μ, s)
logistic(ω::Ω, μ, s) = (p = rand(ω, anysize(μ, s)); logistic.(p, μ, s))

logistic(μ, s) = Logistic(μ, s)
logistic(μ, s, sz::Dims) = Logistic(lift(fill)(μ, sz), lift(fill)(s, sz))

"Exponential Distribution with λ"
struct Exponential{A} <: PrimRandVar
  λ::A
  id::ID
  Exponential(λ::A, id = uid()) where A = new{A}(λ, id)
end
@inline (rv::Exponential)(ω::Ω) = apl(rv, ω)
rvtransform(::Exponential) = exponential
exponential(p::Real, λ::Real) = quantile(Djl.Exponential(λ), p)
exponential(ω::Ω, λ::Real) = exponential(rand(ω), λ)
exponential(ω::Ω, λ) = (p = rand(ω, size(λ)); exponential.(p, λ))

exponential(λ) = Exponential(λ)
exponential(λ, sz::Dims) = Exponential(lift(fill(λ, sz)))

"Kumaraswamy distribution, similar to beta but easier"
struct Kumaraswamy{A, B} <: PrimRandVar
  a::A
  b::B
  id::ID
  Kumaraswamy(a::A, b::B, id = uid()) where {A, B} = new{A, B}(a, b, id)
end
@inline (rv::Kumaraswamy)(ω::Ω) = apl(rv, ω)
rvtransform(::Kumaraswamy) = kumaraswamy
kumaraswamy(p::Real, a::Real, b::Real) = (1 - (1 - p)^(1/b))^(1/a)
kumaraswamy(ω::Ω, a::Real, b::Real) = kumaraswamy(rand(ω), a, b)
kumaraswamy(ω::Ω, a, b) = (p = rand(ω, anysize(a, b)); kumaraswamy.(p, a, b))

kumaraswamy(a, b) = Kumaraswamy(a, b)
kumaraswamy(a, b, sz::Dims) = Kumaraswamy(lift(fill)(a, sz), lift(fill)(b, sz))

"Uniform distribution with parameters a, b"
struct Uniform{A, B} <: PrimRandVar
  a::A
  b::B
  id::ID
  Uniform(a::A, b::B, id = uid()) where {A, B} = new{A, B}(a, b, id)
end
@inline (rv::Uniform)(ω::Ω) = apl(rv, ω)
rvtransform(rv::Uniform) = uniform
uniform(p::Real, a::Real, b::Real) = quantile(Djl.Uniform(a, b), p)
uniform(ω::Ω, a::Real, b::Real) = uniform(rand(ω), a, b)
uniform(ω::Ω, a, b) = (p = rand(ω, anysize(a, b)); uniform.(p, a, b))

uniform(a, b) = Uniform(a, b)
uniform(a, b, sz::Dims) = Uniform(lift(fill)(a, sz), lift(fill)(b, sz))

"Categorical distribution with probability weight vector `p`"
struct UniformChoice{A} <: PrimRandVar
  vals::A    # Probability Vector
  id::ID
  UniformChoice(vals::A, id = uid()) where A = new{A}(vals, id)
end
@inline (rv::UniformChoice)(ω::Ω) = apl(rv, ω)
rvtransform(rv::UniformChoice) = uniform
uniform(ω::Ω, vals::Union{Vector, UnitRange}) = rand(ω, vals)
uniform(ω::Ω, vals::Union{Vector, UnitRange}, dims::Dims) = rand(ω, vals, dims) 
uniform(ω::Ω, vals::Union{Vector, UnitRange}, n::Integer) = rand(ω, vals, n) 

uniform(vals) = UniformChoice(vals)
uniform(vals, sz::Dims) = UniformChoice(lift(fill)(vals, sz))

"Discrete uniform distribution over unit range `range`"
uniform(range::MaybeRV{UnitRange}) = UniformChoice(range) #FIXME

"Discrete uniform distribution over array"
uniform(arr::MaybeRV{Array}) = UniformChoice(arr)