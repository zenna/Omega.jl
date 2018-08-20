struct RID{T, Trest, RV1 <: RandVar, RV2 <: RandVar, OM <: Ω} <: RandVar
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

rid(x, θ) = ciid(ω -> replace(x, rv.θ => rv.θ(rv.ω))(ω))