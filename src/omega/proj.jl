mutable struct ΩProj{O, I} <: Ω{I}
  ω::O
  id::I
end

function increment!(ωπ::ΩProj)
  ωπ.id = increment(ωπ.id)
end

function parentω(ωπ::ΩProj)
  ωπ.ω
end