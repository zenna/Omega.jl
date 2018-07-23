struct RID{T, Trest, RV1 <: RandVar{T, Trest}, RV2 <: RandVar, OM <: Ω} <: AbstractRandVar{T}
  x::RV1
  θ::RV2
  ω::OM
end

# function distribution(x::RID)
#   # TODO
# end

(rv::RID)(ω::Ω) = change(rv.θ, rv.θ(rv.ω), rv.x)(ω)

"Random interentional distribution `x ∥ change(θ)`"
rid(x, θ) = iid(ω -> RID(x, θ, ω))