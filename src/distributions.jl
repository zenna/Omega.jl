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

"Beta"
beta(α, β, ωid::Id, ω::Omega) = quantile(Beta(α, β), ω[ωid])
beta(α::T, β::T, ωid::Id=ωnew()) where T = RandVar{T}(Mu.beta, (α, β, ωid))

"Bernoulli"
bernoulli(p, ωid::Id, ω::Omega) = quantile(Bernoulli(p), ω[ωid])
bernoulli(p::T, ωid::Id = ωnew()) where T <: Real = RandVar{T}(bernoulli, (p, ωid))
bernoulli(p::RandVar{T}, ωid::Id = ωnew()) where T = RandVar{T}(bernoulli, (p, ωid))

"`uniform(a, b)`"
uniform(a::T, b::T, ωid, ω::Omega) where T = ω[ωid] * (b - a) + a
uniform(a::T, b::T, ωid::Id=ωnew()) where T = RandVar{T}(uniform, (a, b, ωid))
uniform(a::RandVar{T}, b::T, ωid::Id=ωnew()) where T = RandVar{T}(uniform, (a, b, ωid))
uniform(a::T, b::RandVar{T}, ωid::Id=ωnew()) where T = RandVar{T}(uniform, (a, b, ωid))
uniform(a::RandVar{T}, b::RandVar{T}, ωid::Id=ωnew()) where T = RandVar{T}(uniform, (a, b, ωid))