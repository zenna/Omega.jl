function ok2(ω1, ω2, x::RandVar)
end

function ok(ω::Omega, x::RandVar{T}, y::RandVar) where T
  x(ω)
  RandVar{T}(ok2, (ω, x))
end

function curry(x::RandVar{T}, y::RandVar) where T
  RandVar{RandVar{T}}(ok, (ok))
end

# ## Functions
# ## =========
# "
# Project `y` onto the randomness of `x`*

# ```jldoctest
# p = uniform(0.1, 0.9)
# X = Bernoulli(p)
# y = normal(x, 1)
# [rand(expectation(curry(y, x))) for _ = 1:10]
# [rand(expectation(curry(y, p))) for _ = 1:10]
# ```
# "
# function curry(x::RandVar{T}, y::RandVar) where T
#   RandVar{RandVar{T}}(ω1 -> let ω_ = project(ω1, ωids(y))
#                               RandVar{T}(ω2 -> x(merge(ω2, ω_)), ωids(x))
#                             end,
#                       ωids(x))
# end