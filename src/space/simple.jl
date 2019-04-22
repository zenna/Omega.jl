"""
SimpleΩ: Stores map from indices to values

# Properties
- Fast tracking (~50 ns overhead)
- Linear view is expensive
- Unique index for each rand value and hence can be memory intensive
"""
struct SimpleΩ{I, V} <: ΩBase{I}
  vals::Dict{I, V}
end

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
randrtype(ω::SimpleΩ, ::Type{T}, ::Dims{N}) where {T, N} = Array{T, N}

# If V <: A dual number, return V
randrtype(ω::SimpleΩ{I, V}, ::Type{T}) where {I, T,  V <: ForwardDiff.Dual} = V

# @inline function memrand(ω::SimpleΩ{I, Any}, id::I, T; rng) where {I}
#   get!(()->rand(rng, T), ω.vals, id)::randrtype(ω, T)
# end

@inline function memrand(ω::SimpleΩ, id, ::Type{T}, dims::Dims; rng) where {T}
  get!(()->rand(rng, T, dims), ω.vals, id)::randrtype(ω, T, dims)
end

@inline function memrand(ω::SimpleΩ, id, ::Type{T}; rng) where {T}
  get!(()->rand(rng, T), ω.vals, id)::randrtype(ω, T)
end

# @inline function memrand(ω::SimpleΩ, id, ::Type{T}, dims::Dims{N}) where {T, N}
#   get!(()->rand(rng, T, dims), ω.vals, id)
# end

@inline function memrand(ω::SimpleΩ{I, A}, id, ::Type{T}; rng) where {V, T, I, A <: AbstractArray{V}}
  val = get!(()->V[rand(rng, T)], ω.vals, id)
  first(val)::randrtype(ω, T)
end

# Flux-specific #

randrtype(ω::SimpleΩ{I, A}, ::Type{T}) where {T <: AbstractFloat, I, A<:Flux.TrackedArray} = Flux.Tracker.TrackedReal{T}
randrtype(ω::SimpleΩ{I, A}, ::Type{T}, ::Dims{N}) where {N, T <: AbstractFloat, I, A <: Flux.TrackedArray{T}} =
  Flux.TrackedArray{T, N, Array{T, N}}
# zt: Issue here is how do you specify that it should be say a static vector
# Am using abstract TrackedArray

# using ZenUtils

@inline function memrand(ω::SimpleΩ{I, A}, id::I, ::Type{T}, dims::Dims; rng) where {T, I, A<:Flux.TrackedArray}
  # @show randrtype(ω, T, dims)
  # @show id ∈ keys(ω.vals)
  # @show a = typeof(Flux.param(rand(rng, T, dims)))
  # @grab ω
  # @grab id
  # @grab a 
  ω.vals[id] = a
  @assert false
  res = get!(()->Flux.param(rand(rng, T, dims)), ω.vals, id)
  @show typeof(res)
  res::randrtype(ω, T, dims)
end

@inline function memrand(ω::SimpleΩ{I, A}, id::I, ::Type{T}; rng) where {T, I, A<:Flux.TrackedArray}
  val = get!(()->Flux.param([rand(rng, T)]), ω.vals, id)
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
