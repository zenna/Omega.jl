# Analytic
struct AnalyticAlg <: DistAlgorithm end
const Analytic = AnalyticAlg()

analytic(distop, x::RandVar) = distop(distributionsjl(x))
  
for dop in distops_names
  expr = :($dop(x::RandVar, ::AnalyticAlg) = analytic($dop, x))
  eval(expr)
end

# Sample mean
struct SampleMeanAlg <: DistAlgorithm end
const SampleMean = SampleMeanAlg()
mean(x, ::SampleMeanAlg; kwargs...) = samplemean(x; kwargs...)

"Expectation of `x` from `n` samples"
function samplemean(x::RandVar; n = 10_000, alg = FailUnsat, kwargs...)
    # @show kwargs
  mean(rand(x, n; alg = alg, kwargs...))
end

# Sample mean std
meanstd(x) = (m = mean(x); (mean = m, std = stdm(x, m)))

# Sample prob
sampleprob(x::RandVar, n; alg = FailUnsat, kwargs...) = samplemean(x, n; alg = alg, kwargs...)

# samplemeanᵣ(x, n; alg = RejectionSample) = ciid(ω -> samplemean(x(ω), n; alg = alg))
# samplemeanstd(x, n; alg, kwargs...) = meanstd(rand(x, n; alg = alg, kwargs...))
# samplemeanstdᵣ(x, n; alg = RejectionSample) = ciid(ω -> samplemeanstd(x(ω), n; alg = alg))
# const sampleprob = samplemean
# const sampleprobᵣ = samplemeanᵣ
# meanᵣ(x; alg, kwargs...) = samplemeanᵣ(x, 1000; alg = alg, kwargs...)
# zt: Default to RejectionSample is problematic 

# # Sample probability 

# "Probability x is true"
# prob(x::RandVar, n, israndvar::Type{Val{false}}) =
#   sum((rand(x, alg = RejectionSample) for i = 1:n)) / n
# lprob(x::RandVar, n = 1000) = lift(prob)(x, n, Val{false})
# prob(x::RandVar, n) = prob(x, n, Val{elemtype(x) <: RandVar})



# const bindistattrs = [:entropy, :mgf, :cf, :pdf, :logpdf, :loglikelihood, :cdf,
#                       :logcdf, :ccdf, :logccdf, :quantile, :cquantile,
#                       :invlogcdf, :invlogccdf]

# for func in bindistattrs
#   expr = 
#   quote
#     $func(x::PrimRandVar, et::Type{<:Real}) = Djl.$func(distribution(x))
#     $func(x::RandVar, et::Type{<:RandVar}, t) = ciid(mean, x)
#     $func(x::RandVar, t) = $func(x, elemtype(x))
#   end
#   eval(expr)
# end
# Djl.entropy(x::RandVar) = entropy(distribution(x))
# Djl.entropy(x::RandVar, base) = entropy(distribution(x), base)

# Djl.mgf(x::RandVar, t) = mgf(distribution(x), t)
# Djl.cf(x::RandVar, t) = cf(distribution(x), t)

# Djl.pdf(x::RandVar, t) = pdf(distribution(x), t)
# Djl.logpdf(x::RandVar, t) = logpdf(distribution(x), t)
# Djl.loglikelihood(x::RandVar, t) = loglikelihood(distribution(x), t)

# Djl.cdf(x::RandVar, t) = cdf(distribution(x), t)
# Djl.logcdf(x::RandVar, t) = logcdf(distribution(x), t)

# Djl.ccdf(x::RandVar, t) = ccdf(distribution(x), t)
# Djl.logccdf(x::RandVar, t) = logccdf(distribution(x), t)

# Djl.quantile(x::RandVar, t) = quantile(distribution(x), t)
# Djl.cquantile(x::RandVar, t) = cquantile(distribution(x), t)

# Djl.invlogcdf(x::RandVar, t) = invlogcdf(distribution(x), t)
# Djl.invlogccdf(x::RandVar, t) = invlogccdf(distribution(x), t)

# Converions between Distributions and Omega

