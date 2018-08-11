"""
Fast SimpleΩ

# Properties
- Fast tracking (50 ns overhead)
- Fast to get linear view
- Hence easy to sample from
- Unique index for each rand value and hence:
  (i) Memory intensive
"""
struct SimpleΩ{I, V} <: ΩBase{I}
  vals::Dict{I, V}
end

SimpleΩ() = SimpleΩ(Dict{Vector{Int}, Float64}())
SimpleΩ{I, V}() where {I, V} = SimpleΩ{I, V}(Dict{I, V}())

Base.values(sω::SimpleΩ) = values(sω.vals)
Base.keys(sω::SimpleΩ) = keys(sω.vals)

## Resolve
## =======
@inline function resolve(ω::SimpleΩ{I}, id::I, T) where {I}
  get!(()->rand(GLOBAL_RNG, T), ω.vals, id)
end

@inline function resolve(ω::SimpleΩ{I}, id::I, ::Type{T}, dims::Dims) where {I, T}
  get!(()->rand(GLOBAL_RNG, T, dims), ω.vals, id)
end

@inline function resolve(ωπ::SimpleΩ{I, A}, ::Type{T}) where {T, I, A<:AbstractArray}
  val = get!(()->[rand(GLOBAL_RNG, T)], ωπ.ω.vals, ωπ.id)
  first(val)
end

@inline function resolve(ω::SimpleΩ{I, A}, id::I, ::Type{T},  dims::Dims) where {T, I, A<:Flux.TrackedArray}
  get!(()->Flux.param(rand(GLOBAL_RNG, T, dims)), ω.vals, id)
end

@inline function resolve(ω::SimpleΩ{I, A}, id::I, ::Type{T}) where {T, I, A<:Flux.TrackedArray}
  val = get!(()->Flux.param([rand(GLOBAL_RNG, T)]), ω.vals, id)
  first(val)
end

## Version Specfici
## ================

if v"0.6" <= VERSION < v"0.7-"
  rettype(::Type{Base.Random.CloseOpen}) = Float64
end

if VERSION > v"0.7-"
  Random.rng_native_52(ω::Ω) = Random.rng_native_52(Random.GLOBAL_RNG)
end

#   function Random.rng_native_52(ωπ::ΩProj{O}) where {I, O <: SimpleΩ{I, ValueTuple}}
#     res = if ωπ.id ∈ keys(ωπ.ω.vals)
#       ωπ.ω.vals[ωπ.id]._Float64::Float64
#     else
#       @show val = Random.rng_native_52(Random.GLOBAL_RNG)
#       ωπ.ω.vals[ωπ.id] = ValueTuple(val, Float32(0.0), UInt(0))
#       val
#     end
#     increment!(ωπ)
#     res
#   end
# end


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
