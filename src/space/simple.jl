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

function Base.setindex!(sω::SimpleΩ{I,V}, v::V, i::I) where {I, V}
  sω.vals[i] = v
end

function Base.:(==)(sω1::SimpleΩ{I,V}, sω2::SimpleΩ{I,V}) where {I, V}
  sω1.vals == sω2.vals
end

# memrand #

@inline function memrand(ω::SimpleΩ{I, Any}, id::I, T) where {I}
  get!(()->rand(GLOBAL_RNG, T), ω.vals, id)::randrtype(T)
end

@inline function memrand(ω::SimpleΩ{I, Any}, id::I, ::Type{T}, dims::NTuple{N, Int}) where {I, T, N}
  get!(()->rand(GLOBAL_RNG, T, dims), ω.vals, id)::Array{randrtype(T), N}
end

@inline function memrand(ω::SimpleΩ{I}, id::I, T) where {I}
  get!(()->rand(GLOBAL_RNG, T), ω.vals, id)
end

@inline function memrand(ω::SimpleΩ{I}, id::I, ::Type{T}, dims::NTuple{N, Int}) where {I, T, N}
  get!(()->rand(GLOBAL_RNG, T, dims), ω.vals, id)
end

@inline function memrand(ωπ::SimpleΩ{I, A}, ::Type{T}) where {T, I, A<:AbstractArray}
  val = get!(()->[rand(GLOBAL_RNG, T)], ωπ.ω.vals, ωπ.id)
  first(val)
end

@inline function memrand(ω::SimpleΩ{I, A}, id::I, ::Type{T},  dims::Dims) where {T, I, A<:Flux.TrackedArray}
  get!(()->Flux.param(rand(GLOBAL_RNG, T, dims)), ω.vals, id)
end

@inline function memrand(ω::SimpleΩ{I, A}, id::I, ::Type{T}) where {T, I, A<:Flux.TrackedArray}
  val = get!(()->Flux.param([rand(GLOBAL_RNG, T)]), ω.vals, id)
  first(val)
end

Base.isempty(sω::SimpleΩ) = isempty(sω.vals)
Base.length(sω::SimpleΩ) = length(sω.vals)

# Linearlization #

linearize(sω::SimpleΩ{I, V}) where {I, V <: Real} = collect(values(sω.vals))

function linearize(sω::SimpleΩ{I, V}) where {I, V <: AbstractArray}
  # warn("Are keys in order?")
  # vcat((view(a, :) for a in values(sω.vals))...)
  vcat((vec(a) for a in values(sω.vals))...)
end

"Inverse of `linearize`, structure vector into ω.
Precondition: ωvec and sω are the same length."
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
