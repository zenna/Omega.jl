using Distributions
import Distributions
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
Base.rand(rng::AbstractRNG, ::StdNormal{T}) where {T} = rand(rng, Normal(zero(T), one(T)))

# This is called from dispatch
@inline (d::Normal{T})(id, ω) where T =
  Member(id, StdNormal{T}())(ω) * d.σ + d.μ


struct StdUniform{T} <: PrimDist end
Base.eltype(::Type{StdUniform{T}}) where T = T
Base.rand(rng::AbstractRNG, ::StdUniform{T}) where T = 
  rand(rng, Uniform(zero(T), one(T)))
# @inline Space.recurse(d::Distribution, id, ω) =
#   quantile(d, resolve(StdUniform(), id, ω))

@inline (d::Bernoulli)(id, ω) = 
  Member(id, StdUniform{Float64}())(ω) < d.p

@inline (d::Distribution)(id, ω) =
  quantile(d, Member(id, StdUniform{Float64}())(ω))

"""`primdist(d::Distribution)``
Primitive (parameterless) distribution that `d` is defined in terms of"""
function primdist end

primdist(d::Distribution) = StdUniform()
primdist(d::Normal) = StdNormal()

"""`invert(d::Distribution, val)`
If output of `val` is `val` what must its primitives have been?`"""
function invert end

invert(o::Normal, val) = (val / o.σ) - o.μ
invert(d::Distribution, val) = cdf(d, val)


  
  