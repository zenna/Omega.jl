"Projection of `ω` onto compoment `id`"
struct ΩProj{O, I} <: Ω{I}
  ω::O
  id::I
end