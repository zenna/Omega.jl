# # Causal interventions
using ..Var, ..Basis
export |ᵈ, intervene, mergetags, Intervention
using ..Var: Lift, DontLift, traitlift

abstract type AbstractIntervention end

struct NoIntervention <: AbstractIntervention
end

abstract type SlightlyLessAbstractIntervention{X, V} <: AbstractIntervention end

"The imperative that `x(ω)` should be replaced with `v(ω)` "
struct ValueIntervention{X, V} <: SlightlyLessAbstractIntervention{X, V}
  x::X
  v::V
end

"The imperative that `x(ω)`` should be replaced to value `v`"
struct Intervention{X, V} <: SlightlyLessAbstractIntervention{X, V}
  x::X
  v::V
end

# Intervention(x::Pair{X, <:Number}) where X = Intervention(x.first, ω -> x.second)

# In `x => v`, if we believe `v` is variable then build `Interventon`, otherwise `ValueIntervention`
smibtervention(::DontLift, x) = ValueIntervention(x.first, x.second)
smibtervention(::Lift, x) = Intervention(x.first, x.second)
smibtervention(x::Pair{X, Y}) where {X, Y} = smibtervention(traitlift(Y), x)

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
struct Intervened{X, I}
  x::X
  i::I
end

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
intervene(x, p::Pair) = Intervened(x, smibtervention(p))
intervene(x, interventions::Tuple) =
  Intervened(x, MultiIntervention(map(smibtervention, interventions)))

@inline x |ᵈ i = intervene(x, i)

## Display
function Base.show(io::IO, x::SlightlyLessAbstractIntervention)
  print(io, x.x, " => ", x.v)
end

function Base.show(io::IO, xi::Intervened)
  print(io, xi.x, " ¦ ", xi.i)
end

