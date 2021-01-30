module Prim

using ..Omega
using ..IDS: ID, uid
using ..NonDet: RandVar, URandVar, MaybeRV, isconstant, ppapl, apl, reify, elemtype
import ..NonDet: name, ppapl, ciid

import ..Omega:Ω , params, lift

using ..Util
using Spec
import Statistics: quantile
import Distributions
const Djl = Distributions
import Random
using DocStringExtensions: SIGNATURES

export  bernoulli,
        betarv,
        β,
        categorical,
        # dirichlet,
        exponential,
        gammarv,
        Γ,
        invgamma,
        kumaraswamy,
        logistic,
        # mvnormal,
        normal,
        poisson,
        rademacher,
        uniform


"Primitive random variable of known distribution"
abstract type PrimRandVar <: RandVar end  

name(t::T) where {T <: PrimRandVar} = T.name.name

"Parameters of `rv`"
@generated function params(rv::PrimRandVar)
  fields = [Expr(:., :rv, QuoteNode(f)) for f in fieldnames(rv) if f !== :id]
  Expr(:tuple, fields...)
end

ppapl(rv::PrimRandVar, ωπ) = rvtransform(rv)(ωπ, reify(ωπ, params(rv))...)

# Helper for having primitives with multivariate parameters
@generated function anysize(args::Union{<:AbstractArray, Real}...)
  isarr = (arg -> arg <: AbstractArray).([args...])
  firstarr = findfirst(isarr)
  if isempty(isarr)
    :(())
  else
    :(size(args[$firstarr]))
  end
end
@spec same(size.(filter(a -> a isa AbstractArray, args)))

include("univariate.jl")      # Univariate Distributions
include("multivariate.jl")    # Multivariate Distributions
include("randx.jl")           # Interfacing with normal julia code 

end