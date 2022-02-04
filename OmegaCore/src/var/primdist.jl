using Random: AbstractRNG

export invert,
       primdist,
       distapply,
       StdNormal,
       StdUniform,
       UniformInt,
       PrimClass,
       PrimRandVar

"Primitive random variable class"
abstract type PrimClass end
Var.isclass(class::PrimClass) = true
Var.traitvartype(class::PrimClass) = Var.TraitIsClass()
Var.traitvartype(class::Type{<:PrimClass}) = Var.TraitIsClass()

"An primitive random variable"
const PrimRandVar{F <: PrimClass, ID} = Member{F, ID}

(primclass::PrimClass)(id, ω) = Member(id, primclass)(ω)

struct StdNormal{T} <: PrimClass end
Base.eltype(::Type{StdNormal{T}}) where T = T
Base.rand(rng::AbstractRNG, ::StdNormal{T}) where {T} = randn(rng, T)

"StdUniform Uniformly Distributed over [0,1]"
struct StdUniform{T} <: PrimClass end
Base.eltype(::Type{StdUniform{T}}) where T = T
Base.rand(rng::AbstractRNG, ::StdUniform{T}) where T = rand(rng, T)

"Uniformly Distributed ove Integers"
struct UniformInt{T} <: PrimClass end
Base.eltype(::Type{UniformInt{T}}) where T = T
Base.rand(rng::AbstractRNG, ::UniformInt{T}) where T = rand(rng, T)

"""`primdist(d::Distribution)``
Primitive (parameterless) distribution that `d` is defined in terms of"""
function primdist end

"""`invert(d::Distribution, val)`
If output of `val` is `val` what must its primitives have been?`"""
function invert end


  