module OmegaDistributions

using Distributions: Normal, Bernoulli, UnivariateDistribution, Distribution, Uniform, quantile
import Distributions, OmegaCore
using OmegaCore.Var: liftapply, Member, StdUniform, StdNormal
import OmegaCore.Var

OmegaCore.Var.traitvartype(class::Type{<:Distribution}) = Var.TraitIsClass()

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

# Additional distributions 

export UniformDraw

"Element drawn uniformly from elements of set"
struct UniformDraw{T}
  elem::T
end

(u::UniformDraw)(i, ω) =
  u.elem[(i ~ Distributions.DiscreteUniform(1, length(u.elem)))(ω)]




end