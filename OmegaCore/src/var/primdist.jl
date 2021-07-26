using Random: AbstractRNG

export invert,
       primdist,
       distapply,
       StdNormal,
       StdUniform,
       UniformInt,
       PrimDist,
       ExoRandVar

"Primitive Distribution"
abstract type PrimDist end

"An exogenous random variable"
const ExoRandVar{F <: PrimDist, ID} = Member{F, ID}

struct StdNormal{T<:Real} <: PrimDist end
Base.eltype(::Type{StdNormal{T}}) where T = T
(stdn::StdNormal{T})(id, ω) where T = Member(id, stdn)(ω)
Base.rand(rng::AbstractRNG, ::StdNormal{T}) where {T} = randn(rng, T)

"StdUniform Uniformly Distributed over [0,1]"
struct StdUniform{T} <: PrimDist end
Base.eltype(::Type{StdUniform{T}}) where T = T
Base.rand(rng::AbstractRNG, ::StdUniform{T}) where T = rand(rng, T)
(stdu::StdUniform{T})(id, ω) where T = Member(id, stdu)(ω)

"Uniformly Distributed ove Integers"
struct UniformInt{T<:Integer} <: PrimDist end
Base.eltype(::Type{UniformInt{T}}) where T = T
Base.rand(rng::AbstractRNG, ::UniformInt{T}) where T = rand(rng, T)
(unifint::UniformInt{T})(id, ω) where T = Member(id, unifint)(ω)

"""`primdist(d::Distribution)``
Primitive (parameterless) distribution that `d` is defined in terms of"""
function primdist end

"""`invert(d::Distribution, val)`
If output of `val` is `val` what must its primitives have been?`"""
function invert end


  