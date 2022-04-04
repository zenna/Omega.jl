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
  LazyΩ{Tags, T}(T(kv), ω.tags)

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

## Tags
replacetags(ω::LazyΩ, tags) = LazyΩ(ω.data, tags)
traits(::Type{LazyΩ{TAGS, T}}) where {TAGS, T} = traits(TAGS)

Tagging.mergetag(ω::LazyΩ, tag) = LazyΩ(ω.data, merge(ω.tags, tag))

Tagging.tags(ω::LazyΩ) = ω.tags

Base.setindex!(ω::LazyΩ, value, id) = 
  ω.data[id] = value

function Var.recurse(primrv::Var.PrimRandVar, ω::LazyΩ)
  result = get(ω.data, primrv, 0)
  if result === 0
    ω.data[primrv] = rand(rng(ω), primrv.class)
  else
    result
  end::eltype(primrv.class)
end

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