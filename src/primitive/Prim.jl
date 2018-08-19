module Prim

using ..Omega: Ω, RandVar, MaybeRV, ID, lift, Djl, uid
import ..Omega: params, name, ppapl, apl, reify
import Statistics: mean, var, quantile

"Primitive random variable of known distribution"
abstract type PrimRandVar{T} <: RandVar{T} end  

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