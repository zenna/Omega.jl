export defΩ, SimpleΩ, SimpleΩ

using ..IDS, ..Util, ..Tagging
using Random: AbstractRNG
import ..Basis: replacetags
import ..Var

"Simplest, immutable Omega"
struct SimpleΩ{TAGS <: Tags, T, S} <: AbstractΩ
  data::T
  tags::TAGS
  subspace::S
end

Basis.subspace(ω::SimpleΩ) = ω.subspace

# AbstractDict interface
Base.keys(ω::SimpleΩ) = Base.keys(ω.data)
Base.values(ω::SimpleΩ) = Base.values(ω.data)
Base.pairs(ω::SimpleΩ) = Base.pairs(ω.data)
Base.getindex(ω::SimpleΩ, id) = ω.data[id]

idtype(::SimpleΩ{TAGS, Dict{T, V}}) where {TAGS, T, V} = T

SimpleΩ(data) = SimpleΩ(data, Tags())
replacetags(ω::SimpleΩ, tags) = SimpleΩ(ω.data, tags)
# (T::Type{<:Distribution})(π::SimpleΩ, args...) = ω.data[scope(ω)]

function Var.recurse(exo::Var.PrimRandVar, ω::SimpleΩ)
  newid = append(ω.subspace, exo.id)
  newexo = Var.Member(newid, exo.class)
  ω.data[newexo]::eltype(newexo.class)
end

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