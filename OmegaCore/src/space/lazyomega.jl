export LazyΩ
using Random
using ..IDS, ..Util, ..Tagging, ..RNG, ..Space
import ..Basis: replacetags
import ..Var

"Lazily constructs randp, values as they are needed"
struct LazyΩ{TAGS <: Tags, T} <: AbstractΩ
  data::T
  tags::TAGS
end

# AbstractDict interface 
Base.keys(ω::LazyΩ) = Base.keys(ω.data)
Base.values(ω::LazyΩ) = Base.values(ω.data)
Base.pairs(ω::LazyΩ) = Base.pairs(ω.data)
Base.getindex(ω::LazyΩ, id) = ω.data[id]

# Move to specific omega types
Base.merge!(ω::LazyΩ, ω_) = error("Unimplemented")
Basis.like(ω::LazyΩ{Tags, T}, kv::Pair) where {Tags, T} = 
  LazyΩ{Tags, T}(T(kv), ω.tags, ω.subspace)

## Constructors
const EmptyTags = Tags{(),Tuple{}}
LazyΩ{EmptyTags, T}() where {T} = LazyΩ(T(), Tags())
LazyΩ{EmptyTags, T}(data) where T = LazyΩ(T(data), Tags())

"Construct `LazyΩ` from `rng` -- `ω.data` will be generated from `rng`"
LazyΩ{T}(rng::AbstractRNG) where T = tagrng(LazyΩ{T}(), rng)

## Ids
Basis.idtype(::Type{Dict{T, V}}) where {T, V} = T
Basis.idtype(::Dict{T, V}) where {T, V} = T
Basis.idtype(ω::LazyΩ{TAGS, Dict{T, V}}) where {TAGS, T, V} = T
ids(ω::LazyΩ) = keys(ω.data)

# ## Subspace
# Basis.proj(ω::LazyΩ{TAGS, T}, ss) where {TAGS, T} = 
#   LazyΩ{TAGS, T}(ω.data, ω.tags, append(ω.subspace, ss))

#   # Basis.appendproj(ω::LazyΩ{TAGS, T}, ss::S) where {TAGS, T} = 
# #   LazyΩ{TAGS, T}(ω.data, ω.tags, append(ss, ω.subspace))

# Basis.updatesubspace(ω::LazyΩ{TAGS, T}, ss) where {TAGS, T} = 
#   LazyΩ{TAGS, T}(ω.data, ω.tags, ss)

# split(ω::LazyΩ) = ((sₗ, sᵣ) = split(subspace(ω)); (updatesubspace(ω, sₗ), updatesubspace(ω, sᵣ)))

## Tags
replacetags(ω::LazyΩ, tags) = LazyΩ(ω.data, tags, ω.subspace)
traits(::Type{LazyΩ{TAGS, T}}) where {TAGS, T} = traits(TAGS)

Tagging.mergetag(ω::LazyΩ, tag) = LazyΩ(ω.data, merge(ω.tags, tag), ω.subspace)

Tagging.tags(ω::LazyΩ) = ω.tags

Base.setindex!(ω::LazyΩ, value, id) = 
  ω.data[id] = value

function Var.recurse(primrv::Var.PrimRandVar, ω::LazyΩ)
  result = get(ω.data, primrv, 0)
  if result === 0
    ω.data[newexo] = rand(rng(ω), newexo.class)
  else
    result
  end::eltype(newexo.class)
end

# function (exo::Var.PrimRandVar)(ω::LazyΩ)
#   # idwhat = 2
#   # @show exo.id
#   # @show ω.subspace
#   # @show 
#   # Mix subspace with index
#   newid = append(ω.subspace, exo.id)
#   newexo = Var.Member(newid, exo.class)
#   # @assert false
#   # exo = exo
#   result = get(ω.data, newexo, 0)
#   if result === 0
#     ω.data[newexo] = rand(rng(ω), newexo.class)
#   else
#     result
#   end::eltype(newexo.class)
# end




## Updating interface
import ..Util:update
export update, update!
# export .Util:update
update!(ω::LazyΩ, k, v) = (ω[k] = v; ω)
Util.update(ω::LazyΩ, k, v) = (ω_ = deepcopy(ω); ω_[k] = v; ω_)

## Display
function Base.show(io::IO, m::MIME"text/plain", ω::LazyΩ)
  println(io, typeof(ω))
  println("tags:")
  show(io, m, ω.tags)

  println("\ndata:")
  show(io, m, ω.data)
end

# function resolve(dist, id, ω::LazyΩ)
#   id_ = convertid(idtype(ω), id)
#   # id_ = id
#   if haskey(ω.data,  id_)
#     d, val = ω.data[id_]
#   else
#     ω.data[id_] = (dist, rand(rng(ω), dist))
#     d, val = ω.data[id_]
#   end
#   val::eltype(dist)   
# end