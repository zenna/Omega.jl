struct RID{T, Trest, RV1 <: RandVar{T, Trest}, RV2 <: RandVar, OM <: Ω} <: AbstractRandVar{T}
  x::RV1
  θ::RV2
  ω::OM
end

function params(x::RID)
end

function distribution(rid::RID)
  # Turn an RID into a distribution
  θs = params(rid.x) ## Issue is that this is wrong
  θs = isconstant.(θs)
  θsc = rand.(θs)
  distribution(func(x), θsc)
end

(rv::RID)(ω::Ω) = replace(rv.x, rv.θ => rv.θ(rv.ω))(ω)

"Random interentional distribution `x ∥ change(θ)`"
rid(x, θ) = ciid(ω -> RID(x, θ, ω))

# Problems
# 1. How do we know we can convert rather than resort to sample approximatio
# 2. whats the definition of params
# 3. wasted computation doing isconstant then sampling
# 4. 


# Do I need a way to associate a type with the random variable that is not the function
# Because (i) if we don't, then we have to make sure that fi s always e.g. normal
# Which means we can't do this pointwise thing

# If we do, we need to create  new type, e.g. Normal, Beta, etc,
# 

# function test()
#   θ = β(2.0, 2.0)
#   x = bernoulli(θ)
#   x_ = rid(x, θ)
#   xs = rand(x_)
#   prob(xs)
# end