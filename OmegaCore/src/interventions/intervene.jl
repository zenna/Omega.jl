# # Causal interventions
using ..Var, ..Basis
export |ᵈ, intervene, mergetags, Intervention


abstract type AbstractIntervention end

"The imperative that `x` should be replaced to value `v`"
struct Intervention{X, V} <: AbstractIntervention
  x::X
  v::V
end

Intervention(x::Pair{X, <:Number}) where X = Intervention(x.first, ω -> x.second)
Intervention(x::Pair) = Intervention(x.first, x.second)

"Multiple variables intervened"
struct MultiIntervention{XS} <: AbstractIntervention
  is::XS
end

"Intervened Variable: `x` had intervention `i` been the case"
struct Intervened{X, I}
  x::X
  i::I
end

"Merge Interventions"
mergeinterventions(i1::Intervention, i2::Intervention) = MultiIntervention((i1, i2))
mergeinterventions(i1::Intervention, i2::MultiIntervention) = MultiIntervention((i1, i2.is...))
mergeinterventions(i1::MultiIntervention, i2::Intervention) = MultiIntervention((i1.is..., i2))

"Merge Intervention Tags"
function mergetags(nt1::NamedTuple{K1, V1}, nt2::NamedTuple{K2, V2}) where {K1, K2, V1, V2}
  if K1 ∩ K2 == [:intervene]    
    merge(merge(nt1, nt2), (intervene = mergeinterventions(nt2[:intervene], nt1[:intervene]),))
  else
    @assert false "Unimplemented"
  end
end

"intervened"
intervene(x, intervention::AbstractIntervention) = Intervened(x, intervention)
intervene(x, intervention::Pair) = Intervened(x, Intervention(intervention))
intervene(x, interventions::Tuple) =
  Intervened(x, MultiIntervention(map(Intervention, interventions)))

@inline x |ᵈ i = intervene(x, i)