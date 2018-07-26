## Distributional Functions
## ========================
"Expectation of `x`"
Base.mean(x::AbstractRandVar{<:Real}, n=10000) = sum((rand(x) for i = 1:n)) / n
Base.mean(x::AbstractRandVar{T}, n=10000) where {T <: RandVar{<:Real}} =
  RandVar{Float64, false}(mean, (x, n), 0)

"Sample variance (using `n` samples)"
function Base.var(x::AbstractRandVar{<:Real}, n=10000)
  var([rand(x) for i = 1:n])
end

"Sample variance (using `n` samples)"
function Base.var(x::AbstractRandVar{T}, n=10000) where {T <: RandVar{<:Real}}
  RandVar{Float64, false}(var, (x, n))
end

Base.mean(xs::AbstractRandVar{<:Array}) = RandVar{Float64, false}(mean, (xs,))

prob(x::RandVar{T}, n) where {T <: Bool} = mean(x, n)
prob(x::RandVar{T}, n = 10000) where { T<: RandVar{Bool}} = RandVar{Float64, false}(prob, (x, n), 0)
lift(:prob, 1)

## Specializations
## ===============

"""
Prob 
```
julia> Mu.prob(bernoulli(0.3))
0.3
```
"""
function prob(x::RandVar{T, Prim, typeof(bernoulli), Tuple{R}}) where {T, Prim, R <: Real}
  x.args[1]
end

"Convert `x` into  `T <: Distributions.Distribution``"
function distribution(x::RandVar{T1, T2, typeof(normal), Tuple{Float64, Float64}, T3}) where {T1, T2, T3}
  Normal(x.args...)
end

Distributions.succprob(x::RandVar) = entropy(distribution(x))
Distributions.failprob(x::RandVar) = failprob(distribution(x))

## Support Functions (default to convet to Distribution and use their implementation)
Distributions.maximum(x::RandVar) = maximum(distribution(x))
Distributions.minimum(x::RandVar) = minimum(distribution(x))
Distributions.islowerbounded(x::RandVar) = islowerbounded(distribution(x))
Distributions.isupperbounded(x::RandVar) = isupperbounded(distribution(x))
Distributions.isbounded(x::RandVar) = isbounded(distribution(x))

# Moments
Distributions.std(x::RandVar) = std(distribution(x))
Distributions.median(x::RandVar) = median(distribution(x))
Distributions.mode(x::RandVar) = mode(distribution(x))
Distributions.modes(x::RandVar) = modes(distribution(x))
Distributions.skewness(x::RandVar) = skewness(distribution(x))
Distributions.kurtosis(x::RandVar) = kurtosis(distribution(x))
Distributions.isplatykurtic(x::RandVar) = isplatykurtic(distribution(x))
Distributions.ismesokurtic(x::RandVar) = ismesokurtic(distribution(x))
Distributions.isleptokurtic(x::RandVar) = isleptokurtic(distribution(x))

Distributions.entropy(x::RandVar) = entropy(distribution(x))
Distributions.entropy(x::RandVar, base) = entropy(distribution(x), base)

Distributions.mgf(x::RandVar, t) = mgf(distribution(x), t)
Distributions.cf(x::RandVar, t) = cf(distribution(x), t)

Distributions.pdf(x::RandVar, t) = pdf(distribution(x), t)
Distributions.logpdf(x::RandVar, t) = logpdf(distribution(x), t)
Distributions.loglikelihood(x::RandVar, t) = loglikelihood(distribution(x), t)

Distributions.cdf(x::RandVar, t) = cdf(distribution(x), t)
Distributions.logcdf(x::RandVar, t) = logcdf(distribution(x), t)

Distributions.ccdf(x::RandVar, t) = ccdf(distribution(x), t)
Distributions.logccdf(x::RandVar, t) = logccdf(distribution(x), t)

Distributions.quantile(x::RandVar, t) = quantile(distribution(x), t)
Distributions.cquantile(x::RandVar, t) = cquantile(distribution(x), t)

Distributions.invlogcdf(x::RandVar, t) = invlogcdf(distribution(x), t)
Distributions.invlogccdf(x::RandVar, t) = invlogccdf(distribution(x), t)

