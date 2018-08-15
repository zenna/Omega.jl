module Proj

using ..Index
using ..Simple
using ..Space

export ΩProj, parentω

mutable struct ΩProj{O, I} <: Ω{I}
  ω::O
  id::I
end

function increment!(ωπ::ΩProj)
  ωπ.id = increment(ωπ.id)
end

function parentω(ωπ::ΩProj)
  ωπ.ω
end

function Base.rand(ωπ::ΩProj, arr::Array)
  res = resolve(ωπ.ω, ωπ.id, arr)
  increment!(ωπ)
  res
end

function Base.rand(ωπ::ΩProj, dims::Dims)
  res = resolve(ωπ.ω, ωπ.id, Float64, dims)
  increment!(ωπ)
  res
end

function Base.rand(ωπ::ΩProj, T)
  res = resolve(ωπ.ω, ωπ.id, T)
  increment!(ωπ)
  res
end

function Base.rand(ωπ::ΩProj, ::Type{T}) where T
  res = resolve(ωπ.ω, ωπ.id, T)
  increment!(ωπ)
  res
end

Base.getindex(ωπ::ΩProj{O, I}, i::I) where {O, I} =
  ΩProj{O, I}(ωπ.ω, combine(ωπ.id, i))

Base.getindex(ωπ::ΩProj{O, I}, i::SI) where {O, I, SI} =
  ΩProj{O, I}(ωπ.ω, append(ωπ.id, i))

Base.getindex(ωπ::ΩProj{O, Paired}, i::Int) where O = ΩProj{O, Paired}(ωπ.ω, pair(ωπ.id, i))

## Projection
## ==========
function Base.getindex(sω::SO, i::Int) where {I, SO <: ΩWOW{I}}
  ΩProj{SO, I}(sω, Index.base(I, i))
end

end