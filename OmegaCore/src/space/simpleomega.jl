export defΩ, SimpleΩ, LazyΩ

using ..IDS, ..Util, ..Tagging
using Random: AbstractRNG
import ..Basis: replacetags

"Simplest, immutable Omega"
struct SimpleΩ{TAGS <: Tags, T} <: AbstractΩ
  data::T
  tags::TAGS
end

idtype(::SimpleΩ{TAGS, Dict{T, V}}) where {TAGS, T, V} = T

SimpleΩ(data) = SimpleΩ(data, Tags())
replacetags(ω::SimpleΩ, tags) = SimpleΩ(ω.data, tags)
# (T::Type{<:Distribution})(π::SimpleΩ, args...) = ω.data[scope(ω)]

# recurse(d::D, ω::SimpleΩ) where {D<:Distribution} = getindex(ω.data, scope(ω))::eltype(D)

traithastag(t::Type{SimpleΩ{TAGS, T}}, tag) where {TAGS, T} = traithastag(TAGS, tag)
traits(::Type{SimpleΩ{TAGS, T}}) where {TAGS, T} = traits(TAGS)

function resolve(dist, id, ω::SimpleΩ)
  # @assert false
  @show ω
  @show id
  @show ω.data[id]
  d, val = ω.data[id]
  val::eltype(dist)
end