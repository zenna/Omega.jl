"""
Fast SimpleΩ

# Properties
- Fast tracking (50 ns overhead)
- Fast to get linear view
- Hence easy to sample from
- Unique index for each rand value and hence:
  (i) Memory intensive
  (ii) Will give wrong results if not indexed corretly
"""
struct SimpleΩ{I, V} <: ΩWOW{I}
  vals::Dict{I, V}
end

SimpleΩ() = SimpleΩ(Dict{Vector{Int}, Float64}())
SimpleΩ{I, V}() where {I, V} = SimpleΩ{I, V}(Dict{I, V}())

Base.values(sω::SimpleΩ) = values(sω.vals)
Base.keys(sω::SimpleΩ) = keys(sω.vals)

## Rand
## ====
function Base.rand(ωπ::ΩProj{O}, ::Type{T}) where {T, I, O <: SimpleΩ{I, <:Real}}
  res = get!(()->rand(Base.GLOBAL_RNG, T), ωπ.ω.vals, ωπ.id)
  increment!(ωπ)
  res
end

function Base.rand(ωπ::ΩProj{O}, ::Type{T},  dims::Dims) where {T, I, V, O <: SimpleΩ{I, V}}
  @assert false "Not implemented (blocking to prevent silent errors)"
end

function Base.rand(ωπ::ΩProj{O}, ::Type{T},  dims::Dims) where {T, I, A<:AbstractArray, O <: SimpleΩ{I, A}}
  res = get!(()->rand(Base.GLOBAL_RNG, T, dims), ωπ.ω.vals, ωπ.id)
  increment!(ωπ)
  res
end

function Base.rand(ωπ::ΩProj{O}, ::Type{T}) where {T, I, A<:AbstractArray, O <: SimpleΩ{I, A}}
  val = get!(()->[rand(Base.GLOBAL_RNG, T)], ωπ.ω.vals, ωπ.id)
  # val = get!(()->Float64[rand(Base.GLOBAL_RNG, T)], ωπ.ω.vals, ωπ.id)
  increment!(ωπ)
  first(val)
end

function Base.rand(ωπ::ΩProj{O}, ::Type{T},  dims::Dims) where {T, I, A<:Flux.TrackedArray, O <: SimpleΩ{I, A}}
  res = get!(()->param(rand(Base.GLOBAL_RNG, T, dims)), ωπ.ω.vals, ωπ.id)
  increment!(ωπ)
  res
end

function Base.rand(ωπ::ΩProj{O}, ::Type{T}) where {T, I, A<:Flux.TrackedArray, O <: SimpleΩ{I, A}}
  val = get!(()->param([rand(Base.GLOBAL_RNG, T)]), ωπ.ω.vals, ωπ.id)
  increment!(ωπ)
  first(val)
end

# rng_native_52(::Omega.ΩProj{Omega.SimpleΩ{Int64,Omega.ValueTuple},Int64})

# function Random.rng_native_52(ωπ::ΩProj)
#   res = get!(()->Random.rng_native_52(Random.GLOBAL_RNG), ωπ.ω.vals, ωπ.id)
#   increment!(ωπ)
#   res
# end

## Value Type
## ==========

struct ValueTuple
  _Float64::Float64
  _Float32::Float32
  _UInt32::UInt32
end

# If julia 0.7
# Random.rng_native_52(ω::Ω) = Random.rng_native_52(Random.GLOBAL_RNG)

# function Random.rng_native_52(ωπ::ΩProj{O}) where {I, O <: SimpleΩ{I, ValueTuple}}
#   res = if ωπ.id ∈ keys(ωπ.ω.vals)
#     ωπ.ω.vals[ωπ.id]._Float64::Float64
#   else
#     @show val = Random.rng_native_52(Random.GLOBAL_RNG)
#     ωπ.ω.vals[ωπ.id] = ValueTuple(val, Float32(0.0), UInt(0))
#     val
#   end
#   increment!(ωπ)
#   res
# end

function Base.rand(ωπ::ΩProj{O}, ::Type{UInt32}) where {I, O <: SimpleΩ{I, ValueTuple}}
  res = if ωπ.id ∈ keys(ωπ.ω.vals)
    ωπ.ω.vals[ωπ.id]._UInt32::UInt32
  else
    val = rand(Random.GLOBAL_RNG, UInt32)
    ωπ.ω.vals[ωπ.id] = ValueTuple(0.0, 0.0, val)
    val
  end
  increment!(ωπ)
  res
end

function Base.rand(ωπ::ΩProj{O}, ::Type{CO}) where {I, CO, O <: SimpleΩ{I, ValueTuple}}
  res = if ωπ.id ∈ keys(ωπ.ω.vals)
    ωπ.ω.vals[ωπ.id]._Float64
  else
    val = rand(Random.GLOBAL_RNG, CO)
    ωπ.ω.vals[ωπ.id] = ValueTuple(val, Float32(0.0), UInt(0))
    val
  end
  increment!(ωπ)
  res
end

# 0.7
# function Base.rand(ωπ::ΩProj{O}, fi::Random.FloatInterval{Float64}) where {I, O <: SimpleΩ{I, ValueTuple}}
#   res = if ωπ.id ∈ keys(ωπ.ω.vals)
#     ωπ.ω.vals[ωπ.id]._Float64
#   else
#     val = rand(Random.GLOBAL_RNG, fi)
#     ωπ.ω.vals[ωπ.id] = ValueTuple(val, zero(Float32), zero(UInt))
#     val
#   end
#   increment!(ωπ)
#   res
# end

## Merging
## =======

function Base.merge!(sω1::SimpleΩ, sω2::SimpleΩ)
  for (k, v) in sω2.vals
    sω1.vals[k] = v
  end
  sω1
end

function projintersect!(ω_p::SimpleΩ, ω_s::SimpleΩ)
  for k in keys(ω_p)
    if k in keys(ω_s)
      ω_p.vals[k] = ω_s.vals[k]
    end
  end
  ω_p
end

projintersect!(ωπ1::Ω, ωπ2::Ω) = projintersect!(ωπ1.ω, ωπ2.ω)

Base.merge!(ωπ1::Ω{O}, ωπ2::Ω{O}) where {O <: SimpleΩ} =
  merge!(ωπ1.ω, ωπ2.ω)

Base.isempty(sω::SimpleΩ) = isempty(sω.vals)
Base.length(sω::SimpleΩ) = length(sω.vals)

## Linearlization
## ==============

"Linearize ω into flat vector"
function linearize end

"Inverse of `linearize`, structure vector into ω"
function unlinearize end

linearize(sω::SimpleΩ{I, V}) where {I, V <: Real} = collect(values(sω.vals))

function linearize(sω::SimpleΩ{I, V}) where {I, V <: AbstractArray}
  # warn("Are keys in order?")
  # vcat((view(a, :) for a in values(sω.vals))...)
  vcat((a[:] for a in values(sω.vals))...)
end

function unlinearize(ωvec, sω::SimpleΩ{I, V}, f=identity) where {I, V <: AbstractArray}
  # warn("Are keys in order?")
  vcat((view(a, :) for a in values(sω.vals))...)
  lb = 1
  d = similar(sω.vals)
  pairs = []
  for (k, v) in sω.vals
    sz = size(v)
    ub = lb + prod(sz) - 1
    # subωvec = @view ωvec[lb:ub]
    subωvec = ωvec[lb:ub]
    lb = ub + 1
    v = reshape(subωvec, sz)
    push!(pairs, Pair(k, v))
    # d[k] = v
  end
  SimpleΩ{I, V}(Dict(pairs...))
end

function unlinearize(ωvec, sω::SimpleΩ{I, V}) where {I, V <: Real}
  # Keys not sorted, might be wrong
  SimpleΩ(Dict(k => ωvec[i] for (i, k) in enumerate(keys(sω.vals))))
end
