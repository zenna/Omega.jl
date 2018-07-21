"Root Ω mapping random variable ids to components of omega"
struct NestedΩ{O <: Ω} <: Ω{Int} # Hack FIXME
  vals::Dict{RandVarId, O}
end

Base.getindex(ω::NestedΩ{O}, i::Int) where O = get!(ω.vals, i, O())
NestedΩ{O}() where O = NestedΩ(Dict{RandVarId, O}())

"Root Ω mapping random variable ids to components of omega"
struct NestedΩRandVar{O <: Ω} <: Ω{Int} # Hack FIXME
  vals::NestedΩ{O}
  id::RandVarId
end

Base.rand(T, nω::NestedΩRandVar) = rand(T, nω[0])
Base.rand(nω::NestedΩRandVar, T) = rand(nω[0], T)

resetcount!(nω::NestedΩRandVar) = resetcount!(nω.vals[nω.id])

"Convert a nested Ω into a vector"
function linearize(nω::NestedΩ)
  vecs = map(sort(collect(keys(nω.vals)))) do k
    linearize(nω.vals[k])
  end
  vcat(vecs...)
end

"Convert a vector into a nested Ω"
function unlinearize(xs::Vector, nω1::O) where {O <: NestedΩ}
  nω = O()
  sizes = map(sort(collect(keys(nω.vals)))) do k
    length(linearize(nω.vals[k]))
  end
  for (k, v) in nω.vals
    nω[k] = unlinearize()
  end
  nω
end

## Apply
## =====
Base.getindex(ω::NestedΩ, x::RandVar) = NestedΩRandVar(ω, x.id)

function (rv::RandVar{T, true})(ω::NestedΩ) where T
  args = map(a->apl(a, ω), rv.args)
  ωi = ω[rv]
  resetcount!(ωi)
  (rv.f)(ωi, args...)
end

(rv::RandVar)(nω::NestedΩRandVar) = rv(nω.vals)

function (rv::RandVar{T, false})(ω::NestedΩ) where T
  args = map(a->apl(a, ω), rv.args)
  (rv.f)(args...)
end

Base.getindex(ω::NestedOmegaRandVar{O}, i::Int) where {O} = OmegaProj{O, Paired}(ω, pair(0, i))