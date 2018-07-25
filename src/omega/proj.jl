"Projection of `ω` onto compoment `id`"
mutable struct ΩProj{O, I} <: Ω{I}
  ω::O
  id::I
end

increment!(ωπ::ΩProj) = ωπ.id = increment(ωπ.id)