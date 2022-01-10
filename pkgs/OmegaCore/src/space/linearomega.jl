import ..Var

struct LinearΩ{TAGS, T, S, K}  <: AbstractΩ
  data::T
  tags::TAGS
  keymap::K
  subspace::S
end

function Var.recurse(exo::Var.ExoRandVar, ω::LinearΩ)
  newid = append(ω.subspace, exo.id)
  newexo = Var.Member(newid, exo.class)
  index = ω.keymap[newexo]
  ω.data[index]
end

## Tags 
traits(::Type{LinearΩ{TAGS, T, S, K}}) where {TAGS, T, S, K} = traits(TAuGS)
