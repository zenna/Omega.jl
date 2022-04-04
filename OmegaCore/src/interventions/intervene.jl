# # Causal interventions
using ..Var, ..Basis
import AndTraits
export |ᵈ, intervene, Intervention, ValueIntervention, autointervention
using ..Var: traitvartype, TraitIsVariable, AbstractVariable

abstract type AbstractIntervention end

struct NoIntervention <: AbstractIntervention
end

abstract type SlightlyLessAbstractIntervention{X, V} <: AbstractIntervention end

"The imperative that `x(ω)`` should be replaced to value `v`"
struct ValueIntervention{X, V} <: SlightlyLessAbstractIntervention{X, V}
  x::X
  v::V
end

"The imperative that `x(ω)` should be replaced with `v(ω)` "
struct Intervention{X, V} <: SlightlyLessAbstractIntervention{X, V}
  x::X
  v::V
end

# In `x => v`, if we believe `v` is variable then build `Interventon`, otherwise `ValueIntervention`
autointervention(_, x) = ValueIntervention(x.first, x.second)
autointervention(::AndTraits.traitmatch(TraitIsVariableOrClass), x) = Intervention(x.first, x.second)
autointervention(::AndTraits.traitmatch(TraitIsVariable), x) = Intervention(x.first, x.second)
autointervention(x::Pair{X, Y}) where {X, Y} = autointervention(traitvartype(Y), x)

"Multiple variables intervened"
struct MultiIntervention{XS} <: AbstractIntervention
  is::XS
end

"Merge Interventions"
mergeinterventions(i1::AbstractIntervention, i2::AbstractIntervention) = MultiIntervention((i1, i2))
mergeinterventions(i1::AbstractIntervention, i2::MultiIntervention) = MultiIntervention((i1, i2.is...))
mergeinterventions(i1::MultiIntervention, i2::AbstractIntervention) = MultiIntervention((i1.is..., i2))
mergeinterventions(i1::MultiIntervention, i2::MultiIntervention) = MultiIntervention((i1.is..., i2.is...))

"Intervened Variable: `x` had intervention `i` been the case"
struct Intervened{X, I} <: AbstractVariable
  x::X
  i::I
end

"intervened"
intervene(x, intervention::AbstractIntervention) = Intervened(x, intervention)
intervene(x, p::Pair) = Intervened(x, autointervention(p))
intervene(x, interventions::Tuple) =
  Intervened(x, MultiIntervention(map(autointervention, interventions)))
intervene(x, a::Tuple, b::Tuple) =
  Intervened(x, MultiIntervention(map((a_, b_) -> autointervention(a_ => b_), a, b)))
@inline x |ᵈ i = intervene(x, i)

## Display
function Base.show(io::IO, x::SlightlyLessAbstractIntervention)
  print(io, x.x, " => ", x.v)
end

function Base.show(io::IO, xi::Intervened)
  print(io, xi.x, " ¦ ", xi.i)
end

