using Spec
using ..Tagging, ..Traits, ..IDS
export appendscope, rmscope, scope

"append `id` to the scope"
appendscope(ω::Ω, id) where {Ω <: AbstractΩ} =
  appendscope(traits(Ω), ω, id)
appendscope(::trait(Scope), ω, id) =
  updatetag(ω, Val{:scope}, append(id, ω.tags.scope))
appendscope(traits, ω, id) =
  tag(ω, (scope = id,))

rmscope(ω::T) where T = rmscope(ω, traithastag(T, Val{:scope}))
rmscope(ω, ::HasTag{:scope}) = rmtag(ω, Val{:scope})
rmscope(ω, _) = ω

""""
`scope(ω)`

Current scope
"""
scope(ω) = ω.tags.scope
@pre scope(ω) = hastag(ω, :scope) "Tag should have socpe"
