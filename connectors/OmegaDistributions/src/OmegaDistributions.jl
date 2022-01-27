module OmegaDistributions

using Distributions: Normal, Bernoulli, UnivariateDistribution, Distribution, Uniform, quantile
import Distributions, OmegaCore
using OmegaCore.Var: liftapply, Member, StdUniform, StdNormal

@inline (d::Normal{T})(id, ω) where T =
  Member(id, StdNormal{T}())(ω) * d.σ + d.μ

# @inline Space.recurse(d::Distribution, id, ω) =
#   quantile(d, resolve(StdUniform(), id, ω))

@inline (d::Bernoulli)(id, ω) = 
  Member(id, StdUniform{Float64}())(ω) < d.p

@inline (d::UnivariateDistribution)(id, ω) =
  quantile(d, Member(id, StdUniform{Float64}())(ω))

primdist(d::UnivariateDistribution) = StdUniform()
primdist(d::Normal) = StdNormal()

invert(o::Normal, val) = (val / o.σ) - o.μ
invert(d::UnivariateDistribution, val) = cdf(d, val)

# FIXME / justify this
# Distributions.Normal(μ, σ) = pw(Normal, μ, σ)
Distributions.Normal(μ, σ) =
  (id, ω) -> Normal(liftapply(μ, ω), liftapply(σ, ω))(id, ω)

Distributions.Bernoulli(p) =
  (id, ω) -> Bernoulli(liftapply(p, ω))(id, ω)
#FIXme generalize this
# Normalₚ(args...) = pw(Distributions.Normal, args...)
# Uniformₚ(args...) = pw(Distributions.Uniform, args...)
# Gammaₚ(args...) = pw(Distributions.Gamma, args...)
# DiscreteUniformₚ(args...) = pw(Distributions.DiscreteUniform, args...)
# Poissonₚ(args...) = pw(Distributions.Poisson, args...)
# NegativeBinomialₚ(args...) = pw(Distributions.NegativeBinomial, args...)

# export Normalₚ,
#        Uniformₚ,
#        Gammaₚ,
#        DiscreteUniformₚ,
#        Poissonₚ,
#        NegativeBinomialₚ

# Additional distributions 

export UniformDraw, p
p = 3
"Element drawn uniformly from elements of set"
struct UniformDraw{T}
  elem::T
end
(u::UniformDraw)(i, ω) =
  u.elem[(i ~ Distributions.DiscreteUniform(1, length(u.elem)))(ω)]




end