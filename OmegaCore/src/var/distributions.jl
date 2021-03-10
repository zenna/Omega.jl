using Distributions: Normal, Bernoulli, Distribution, Uniform, quantile

@inline (d::Normal{T})(id, ω) where T =
  Member(id, StdNormal{T}())(ω) * d.σ + d.μ

# @inline Space.recurse(d::Distribution, id, ω) =
#   quantile(d, resolve(StdUniform(), id, ω))

@inline (d::Bernoulli)(id, ω) = 
Member(id, StdUniform{Float64}())(ω) < d.p

@inline (d::Distribution)(id, ω) =
quantile(d, Member(id, StdUniform{Float64}())(ω))

primdist(d::Distribution) = StdUniform()
primdist(d::Normal) = StdNormal()

invert(o::Normal, val) = (val / o.σ) - o.μ
invert(d::Distribution, val) = cdf(d, val)