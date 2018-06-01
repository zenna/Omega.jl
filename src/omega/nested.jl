"Root Omega mapping random variable ids to components of omega"
struct NestedOmega{O <: Omega} <: Omega{Int} # Hack FIXME
  vals::Dict{RandVarId, O}
end

Base.getindex(ω::NestedOmega{O}, i::Int) where O = get!(ω.vals, i, O())
NestedOmega{O}() where O = NestedOmega(Dict{RandVarId, O}())

"Root Omega mapping random variable ids to components of omega"
struct NestedOmegaRandVar{O <: Omega} <: Omega{Int} # Hack FIXME
  vals::NestedOmega{O}
  id::RandVarId
end

Base.rand(T, nω::NestedOmegaRandVar) = rand(T, nω[0])
Base.rand(nω::NestedOmegaRandVar, T) = rand(nω[0], T)

resetcount!(nω::NestedOmegaRandVar) = resetcount!(nω.vals[nω.id])

"Convert a nested Omega into a vector"
function linearize(nω::NestedOmega)
  vecs = map(sort(collect(keys(nω.vals)))) do k
    linearize(nω.vals[k])
  end
  vcat(vecs...)
end

"Convert a vector into a nested Omega"
function unlinearize(xs::Vector, nω1::O) where {O <: NestedOmega}
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
Base.getindex(ω::NestedOmega, x::RandVar) = NestedOmegaRandVar(ω, x.id)

function (rv::RandVar{T, true})(ω::NestedOmega) where T
  args = map(a->apl(a, ω), rv.args)
  ωi = ω[rv]
  resetcount!(ωi)
  (rv.f)(ωi, args...)
end

(rv::RandVar)(nω::NestedOmegaRandVar) = rv(nω.vals)

function (rv::RandVar{T, false})(ω::NestedOmega) where T
  args = map(a->apl(a, ω), rv.args)
  (rv.f)(args...)
end

Base.getindex(ω::NestedOmegaRandVar{O}, i::Int) where {O} = OmegaProj{O, Paired}(ω, pair(0, i))