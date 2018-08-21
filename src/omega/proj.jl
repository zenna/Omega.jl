<<<<<<< HEAD
"""Projection of Ω to subspace

Conceptually if ω::Ω represents the unit hypercube id -> [0, 1], an ωπ::ΩProj
represets the element `ω(id)`.  However:
- The application is lazy to actually get element in `[0, 1]`, we use `resolve`
- The application is lazy and can be 'undone', ω can be recovered with parentω(ωπ)
- ΩProj supports rand which (i) resolves ωπ at its index, (ii) increments the id
"""
=======
module Proj

using ..Index
using ..Simple
using ..Space

export ΩProj, parentω

>>>>>>> jk-basic-unit-tests
mutable struct ΩProj{O, I} <: Ω{I}
  ω::O
  id::I
end

increment!(ωπ::ΩProj) = ωπ.id = increment(ωπ.id)
parentω(ωπ::ΩProj) = ωπ.ω

## Projection

function Base.getindex(ω::O, i::Int) where {I, O <: ΩBase{I}}
  ΩProj{O, I}(ω, base(I, i))
end

<<<<<<< HEAD
## Rand
@spec rand(ωπ::ΩProj, args...) _res == resolve(_pre(ωπ), args...) "result is resolution of ωπ"
@spec rand(ωπ::ΩProj, args...) _res == ωπ.id == increment(_pre(ωπ.id)) "ωπ id is incremented"

resolve(ωπ::ΩProj, args...) = resolve(ωπ.ω, ωπ.id, args...)

function Base.rand(ωπ::ΩProj, dims::Dims)
  res = resolve(ωπ.ω, ωπ.id, Float64, dims) 
=======
function Base.rand(ωπ::ΩProj, arr::Array)
  res = resolve(ωπ.ω, ωπ.id, arr)
>>>>>>> jk-basic-unit-tests
  increment!(ωπ)
  res
end

<<<<<<< HEAD
function Base.rand(ωπ::ΩProj, arr::Array)
  res = resolve(ωπ.ω, ωπ.id, arr) 
=======
function Base.rand(ωπ::ΩProj, dims::Dims)
  res = resolve(ωπ.ω, ωπ.id, Float64, dims)
>>>>>>> jk-basic-unit-tests
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
<<<<<<< HEAD
=======
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

>>>>>>> jk-basic-unit-tests
end