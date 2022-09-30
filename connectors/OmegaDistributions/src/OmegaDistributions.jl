module OmegaDistributions

using Distributions: Normal, Bernoulli, UnivariateDistribution, Distribution, Uniform, quantile
import Distributions, OmegaCore
using OmegaCore.Var: liftapply, Member, StdUniform, StdNormal
import OmegaCore.Var
import OmegaCore.propagate

OmegaCore.Var.traitvartype(class::Type{<:Distribution}) = Var.TraitIsClass

@inline (d::Normal{T})(id, ω) where T =
  Member(id, StdNormal{T}())(ω) * d.σ + d.μ

# @inline Space.recurse(d::Distribution, id, ω) =
#   quantile(d, resolve(StdUniform(), id, ω))

@inline (d::Bernoulli)(id, ω) = 
  Member(id, StdUniform{Float64}())(ω) < d.p

@inline (d::UnivariateDistribution)(id, ω) =
  quantile(d, Member(id, StdUniform{Float64}())(ω))

invert(o::Normal, val) = (val / o.σ) - o.μ
invert(d::UnivariateDistribution, val) = cdf(d, val)

# Pointwise
function Base.broadcast(::Type{T}, arg1::Var.AbstractVariable, arg2) where {T <:Distribution}
  pw(T, arg1, arg2)
end

# Additional distributions 

export UniformDraw

"Element drawn uniformly from elements of set"
struct UniformDraw{T}
  elem::T
end

(u::UniformDraw)(i, ω) =
  u.elem[(i ~ Distributions.DiscreteUniform(1, length(u.elem)))(ω)]


# FIXME, this is specialisation for Normal, but should be generalised
GOGA = Member{OmegaCore.Var.Pw{T, Type{D}}, ID} where {T<:Tuple, D <: Normal, ID}

export GOGA

function OmegaCore.propagate(rng, x::GOGA, x_)
  # FIXME: give this a better name
  ddist = wowresolve(x, rng)
  propagate(rng, x.id ~ ddist, x_)
end

"Produces a Distributions.jl distribution where random variable parameters (e.g. mean and variacne) are solved wrt to ω"
function wowresolve(x::GOGA, ω)
  x.class.f(map(a -> liftapply(a, ω), x.class.args)...)
end

export wowresolve

function OmegaCore.propagate(rng, class::Member{<:Normal, I}, y) where {I}
  # @warn "fixme"
	x = class.class
  # FIXME: This is specialized for Float64
	(class.id ~ StdNormal{Float64}()) => (y - x.μ) / x.σ
end

end