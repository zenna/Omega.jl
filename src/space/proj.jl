"""Projection of Ω to subspace

Conceptually if ω::Ω represents the unit hypercube id -> [0, 1], an ωπ::ΩProj
represets the element `ω(id)`.  However:
- The application is lazy to actually get element in `[0, 1]`, we use `memrand`
- The application is lazy and can be 'undone', ω can be recovered with parentω(ωπ)
- ΩProj supports rand which (i) resolves ωπ at its index, (ii) increments the id
"""
mutable struct ΩProj{O, I} <: Ω{I}
  ω::O
  id::I
end

increment!(ωπ::ΩProj) = ωπ.id = increment(ωπ.id)
parentω(ωπ::ΩProj) = ωπ.ω

# "memrand ωπ::ΩProj to a concrete value"
# function memrand end

@spec rand(ωπ::ΩProj, args...) _res == memrand(_pre(ωπ), args...) "result is resolution of ωπ"
@spec rand(ωπ::ΩProj, args...) _res == ωπ.id == increment(_pre(ωπ.id)) "ωπ id is incremented"

memrand(ωπ::ΩProj, args...) = memrand(ωπ.ω, ωπ.id, args...)

# Ideally
Base.rand(ωπ::ΩProj, args...; rng = Random.GLOBAL_RNG) =
  (res = memrand(ωπ.ω, ωπ.id, args...; rng = rng); increment!(ωπ); res)

Base.rand(ωπ::ΩProj, dims::Dims; rng = Random.GLOBAL_RNG) =
  (@show res = memrand(ωπ.ω, ωπ.id, dims; rng = rng); increment!(ωπ); res)

Base.rand(ωπ::ΩProj, dims::Integer...; rng = Random.GLOBAL_RNG) =
  (res = memrand(ωπ.ω, ωπ.id, dims...; rng = rng); increment!(ωπ); res)

# Base.rand(ωπ::ΩProj; rng = rng) =
#   (res = memrand(ωπ.ω, dims...); increment!(ωπ); res)

Base.rand(ωπ::ΩProj, ::Type{X} = Float64; rng = Random.GLOBAL_RNG) where {X} =
  (res = memrand(ωπ.ω, ωπ.id, X; rng = rng); increment!(ωπ); res)



# function Base.rand(ωπ::ΩProj, dims::Dims; rng = Random.GLOBAL_RNG)
#   res = memrand(ωπ.ω, ωπ.id, Float64, dims; rng = rng)
#   increment!(ωπ)
#   res
# end

# function Base.rand(ωπ::ΩProj, arr::Array; rng = Random.GLOBAL_RNG)
#   res = memrand(ωπ.ω, ωπ.id, arr; rng = rng)
#   increment!(ωπ)
#   res
# end

# function Base.rand(ωπ::ΩProj, T; rng = Random.GLOBAL_RNG)
#   res = memrand(ωπ.ω, ωπ.id, T; rng = rng)
#   increment!(ωπ)
#   res
# end

# function Base.rand(ωπ::ΩProj, ::Type{T}; rng = Random.GLOBAL_RNG) where T
#   @show "hi", rng, T
#   res = memrand(ωπ.ω, ωπ.id, T; rng = rng)
#   increment!(ωπ)
#   res
# end

# function Base.rand(ωπ::ΩProj, ::Type{T}; rng = Random.GLOBAL_RNG) where T
#   @show "hi", rng, T
#   res = memrand(ωπ.ω, ωπ.id, T; rng = rng)
#   increment!(ωπ)
#   res
# end

# function Base.rand(ωπ::ΩProj; rng = Random.GLOBAL_RNG)
#   @show "hi", rng
#   res = memrand(ωπ.ω, ωπ.id, Float64; rng = rng)
#   increment!(ωπ)
#   res
# end


## Projection

Base.getindex(ωπ::ΩProj{O, I}, i::I) where {O, I} =
  ΩProj{O, I}(ωπ.ω, combine(ωπ.id, i))

Base.getindex(ωπ::ΩProj{O, I}, i::SI) where {O, I, SI} =
  ΩProj{O, I}(ωπ.ω, append(ωπ.id, i))

Base.getindex(ωπ::ΩProj{O, Paired}, i::Int) where O = ΩProj{O, Paired}(ωπ.ω, pair(ωπ.id, i))

function Base.getindex(sω::SO, i::Int) where {I, SO <: ΩBase{I}}
  ΩProj{SO, I}(sω, base(I, i))
end