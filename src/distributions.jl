using Distributions

Id = Int

apl(x, ω::Omega) = x
apl(x::AbstractRandVar, ω::Omega) = x(ω)

normal(μ, σ, ωi) = quantile(Normal(μ, σ), ωi)
function normal(μ, σ, ωid::Int=ωnew())
  RandVar{Real}(ω -> normal(apl(μ, ω), apl(σ, ω), ω[ωid]),
                Set(ωid) ∪ ωids(μ) ∪ ωids(σ))
end

"Gamma distribution"
gammarv(α, θ, ωi) = quantile(Gamma(α, θ), ωi)
gammarv(α, θ, ωid::Id = ωnew()) =
  RandVar{Real}(ω -> gammarv(apl(α, ω), apl(θ, ω), ω[ωid]), ωid)
Γ = gammarv

"Dirichlet distribution"
function dirichlet(α)
  gammas = [gammarv(αi, 1) for αi in α]
  Σ = sum(gammas)
  [gamma/Σ for gamma in gammas]
end

"Inverse Gamma"
inversegamma(α, θ, ωi) = quantile(InverseGamma(α, θ), ωi)
inversegamma(α, θ, ωid::Id = ωnew()) =
  RandVar{Real}(ω -> inversegamma(apl(α, ω), apl(θ, ω), ω[ωid]), ωid)

"`uniform(a, b)`"
uniform(a::T, b::T, ωi) where T = ωi * (b - a) + a
uniform(a::T, b::T, ωid::Id=ωnew()) where T =
  RandVar{T}(ω -> uniform(apl(a, ω), apl(b, ω), ω[ωid]), ωid)

## Lifting
## =======
# First issue.
# Should `T` denote an Array, Real, Float
# Or be agnostic
# We can define parametric functions, why cant we define parametric random variables

# uniform(Float64, )

Base.:+(x::RandVar{T}, y::RandVar{T}) where T <: Real =
  RandVar{T}(ω -> apl(x, ω) + apl(y, ω), ωids(x) ∪ ωids(y))

Base.:/(x, y::RandVar{T}) where T <: Real =
  RandVar{T}(ω -> apl(x, ω) / apl(y, ω), ωids(x) ∪ ωids(y))

Base.:/(x::RandVar{T}, y) where T <: Real =
  RandVar{T}(ω -> apl(x, ω) / apl(y, ω), ωids(x) ∪ ωids(y))

Base.:/(x::RandVar{T}, y::RandVar{T}) where T <: Real =
  RandVar{T}(ω -> apl(x, ω) / apl(y, ω), ωids(x) ∪ ωids(y))

Base.:*(x::RandVar{T}, y::RandVar{T}) where T <: Real =
  RandVar{T}(ω -> apl(x, ω) * apl(y, ω), ωids(x) ∪ ωids(y))

## Equality
## ========

function Base.:(==)(x::AbstractRandVar, y)
  RandVar{Bool}(ω -> x(ω) ≊ apl(y, ω), 3)
end

function Base.rand(x::Vector{<:RandVar})
  rand()
end

function randvec(x::Vector{<:RandVar{T}}) where T
  RandVar{Vector{T}}(ω -> [xi(ω) for xi in x], 3)
end