module Prim

using ..Omega: Ω, RandVar, URandVar, MaybeRV, ID, lift, Djl, uid
import ..Omega: params, name, ppapl, apl, reify
import Statistics: mean, var, quantile
using Spec

"Primitive random variable of known distribution"
abstract type PrimRandVar <: RandVar end  

"Name of a distribution"
function name end

name(t::T) where {T <: PrimRandVar} = T.name.name

# name(::T) where {T <: PrimRandVar} = Symbol(T)

"Parameters of `rv`"
@generated function params(rv::PrimRandVar)
  fields = [Expr(:., :rv, QuoteNode(f)) for f in fieldnames(rv) if f !== :id]
  Expr(:tuple, fields...)
end

ppapl(rv::PrimRandVar, ωπ) = rvtransform(rv)(ωπ, reify(ωπ, params(rv))...)

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
include("statistics.jl")      # Distributional properties: mean, variance, etc
include("djl.jl")             # Distributions.jl interop

export bernoulli,
       betarv,
       β,
       categorical,
       dirichlet,
       exponential,
       gammarv,
       Γ,
       inversegamma,
       kumaraswamy,
       logistic,
       poisson,
       normal,
       mvnormal,
       uniform,
       rademacher,
       constant

end