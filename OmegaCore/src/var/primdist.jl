using Random: AbstractRNG

export invert,
       primdist,
       distapply,
       StdNormal,
       StdUniform,
       PrimDist,
       ExoRandVar

## Lifted Operations

"Primitive Distribution"
abstract type PrimDist end

"An exogenous random variable"
ExoRandVar{F <: PrimDist, ID} = Member{F, ID}

struct StdNormal{T<:Real} <: PrimDist end
Base.eltype(::Type{StdNormal{T}}) where T = T
Distributions.logpdf(::StdNormal{T}, x) where T =
  Distributions.logpdf(Normal(zero(T), one(T)), x)
Base.rand(rng::AbstractRNG, ::StdNormal{T}) where {T} = rand(rng, @show(Normal(zero(T), one(T))))
(stdn::StdNormal{T})(id, ω) where T = Member(id, std)(ω)

# # StdUniform

struct StdUniform{T} <: PrimDist end
Base.eltype(::Type{StdUniform{T}}) where T = T
Base.rand(rng::AbstractRNG, ::StdUniform{T}) where T = 
  rand(rng, Uniform(zero(T), one(T)))
(stdu::StdUniform{T})(id, ω) where T = Member(id, stdu)(ω)

"""`primdist(d::Distribution)``
Primitive (parameterless) distribution that `d` is defined in terms of"""
function primdist end

"""`invert(d::Distribution, val)`
If output of `val` is `val` what must its primitives have been?`"""
function invert end


  