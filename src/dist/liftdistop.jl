# Lifting

# # Specializations
# const unidistattrs = [:succprob, :failprob, :maximum, :minimum, :islowerbounded,
#                       :isupperbounded, :isbounded, :std, :median, :mode, :modes,
#                       :skewness, :kurtosis, :isplatykurtic, :ismesokurtic,
#                       :isleptokurtic, :entropy, :mean]

# for func in unidistattrs
#   expr = 
#   quote
#     $func(x::RandVar, israndvar::Type{Val{false}}) = Djl.$func(distribution(x))
#     $func(x::RandVar, israndvar::Type{Val{true}}) = $(:l *ₛ func)(x)
#     $(:l *ₛ func)(x::RandVar) = lift($func)(x, Val{false})
#     $func(x::RandVar) = $func(x, Val{elemtype(x) <: RandVar})
#   end
#   eval(expr)
# end

# Lift all dist ops
for dop in distops_names
  expr = :($(dop *ₛ :ᵣ)(x::RandVar) = lift($dop)(x))
  eval(expr)
end
