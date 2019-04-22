# When can we convert a RandVar to a Distributions.jl RandVar?
# What inference algorithm if any do we want to use when using mean in model
# Options: 1. user specifies
# 2. No inference algorithm: we do samples on the outside
# Need to take into account conditions on x

"Expectation of `x` from `n` samples"
function samplemean(x::RandVar, n; alg = RejectionSample)
  sum((rand(x, alg = alg) for i = 1:n)) / n
end

samplemeanᵣ(x, n; alg = RejectionSample) = ciid(ω -> samplemean(x(ω), n; alg = alg))


const sampleprob = samplemean

# zt: Default to RejectionSample is problematic 

"Probability x is true"
prob(x::RandVar, n, israndvar::Type{Val{false}}) =
  sum((rand(x, alg = RejectionSample) for i = 1:n)) / n
lprob(x::RandVar, n = 1000) = ciid(prob, x, n, Val{false})
prob(x::RandVar, n) = prob(x, n, Val{elemtype(x) <: RandVar})

# Specializations
const unidistattrs = [:succprob, :failprob, :maximum, :minimum, :islowerbounded,
                      :isupperbounded, :isbounded, :std, :median, :mode, :modes,
                      :skewness, :kurtosis, :isplatykurtic, :ismesokurtic,
                      :isleptokurtic, :entropy, :mean]

for func in unidistattrs
  expr = 
  quote
    $func(x::RandVar, israndvar::Type{Val{false}}) = Djl.$func(distribution(x))
    $func(x::RandVar, israndvar::Type{Val{true}}) = $(:l *ₛ func)(x)
    $(:l *ₛ func)(x::RandVar) = ciid($func, x, Val{false})
    $func(x::RandVar) = $func(x, Val{elemtype(x) <: RandVar})
  end
  eval(expr)
end


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

djldist(::T, params...) where {T <: RandVar} = djltype(T)(params...)

djltype(::Type{<:Normal}) = Djl.Normal
djltype(::Type{<:Beta}) = Djl.Beta
djltype(::Type{<:Bernoulli}) = Djl.Bernoulli
djltype(::Type{<:ReplaceRandVar{Prim}}) where Prim = djltype(Prim)

mayberand(x::RandVar) = rand(x)
mayberand(c) = c

"Convert `rv` into a Distributions.jl `Distribution``"
function distribution(rv::RandVar)
  θs = params(rv)
  θisconst = isconstant.(θs)
  @pre all(θisconst) "All params must be constant to convert to Distributions"
  θsc = mayberand.(θs)
  djldist(rv, θsc...)
end
