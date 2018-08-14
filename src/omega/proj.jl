"Projection of Ω to subspace"
mutable struct ΩProj{O, I} <: Ω{I}
  ω::O
  id::I
end

increment!(ωπ::ΩProj) = ωπ.id = increment(ωπ.id)
parentω(ωπ::ΩProj) = ωπ.ω

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

## Projection
## ==========
function Base.getindex(sω::SO, i::Int) where {I, SO <: ΩBase{I}}
  ΩProj{SO, I}(sω, base(I, i))
end

