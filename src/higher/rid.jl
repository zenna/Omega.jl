
# Random interventional distribution
# UTuple{}
# ConcreteRandVar = RandVar{T, Prim, F, TPL, I}

struct RID{RV1 <: RandVar, RV2 <: RandVar, OM <: Ω}
  x::RV1
  θ::RV2
  ω::OM
end

# function rid(x, θ)

# end

# function change(θ)
# end

# x ∥ change(θ)