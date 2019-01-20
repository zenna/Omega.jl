"""
LinearΩ: Stores Data in Linear Vector

# Properties
- No overhead for linearization / delinearization
- Good for optimization / inference methods which require linear interface
"""
struct LinearΩ{I, AB, V} <: ΩBase{I}
  ids::Dict{I, AB}
  ωvec::Vector{V}
end

# function Base.rand(rng::AbstractRNG, ::Type{LT}) where {LT <: LinearΩ}
# end

# Option 1, embed it  
# Base.rand(rng, ΩT::Type{OT}) where OT = LinearΩ

LinearΩ() = LinearΩ{Vector{Int}, Segment, Float64}(Dict{Vector{Int}, Segment}(), Float64[])
LinearΩ{I, AB, V}() where {I, AB, V} = LinearΩ{I, AB, V}(Dict{I, V}(), V[])

nelem(lω::LinearΩ) = length(lω.ωvec)

"Array of a linear array"
struct Segment
  startidx::Int
  shape::Dims
end

nelem(seg::Segment) = prod(seg.shape)

"lb:ub indices of ωvec subsumed by segment"
segrange(seg::Segment) = seg.startidx:seg.startidx+nelem(seg) - 1

linearize(lω::LinearΩ) = lω.ωvec
unlinearize(ωvec, lω::LinearΩ{I, AB, V}) where {I, AB, V}  = LinearΩ{I, AB, V}(lω.ids, ωvec)

flat(rv, ω::T) where T <: LinearΩ = floatvec -> rv(T(ω.ids, floatvec))

"Sample a key"
randunifkey(lω::LinearΩ) = rand(keys(lω.ids))

getdim(lω, i) = lω.ωvec[i]

"Apply `kernel` to ith component" 
function update(lω::LinearΩ, i::Int, kernel::Function)
  lω_ = deepcopy(lω)
  lω_.ωvec[i] = kernel(lω_.ωvec[i])
  lω_
end

function update(lω::LinearΩ, i::Int, val)
  lω_ = deepcopy(lω)
  lω_.ωvec[i] = val
  lω_
end

function randrtype(::Type{T}, lω::LinearΩ{I, AB, V}) where {T, I, AB, V}
  # @show V
  # @show T
  # @assert false
  T
end

function randrtype(::Type{T}, lω::LinearΩ{I, AB, <:ForwardDiff.Dual}) where {T, I, AB}
  # # That's teh nuts and bolts of it.
  # # @assert false
  # #   
  # # @assert false
  # @show lω
  ForwardDiff.Dual
end

Base.values(lω::LinearΩ) = [lω.ωvec]

# Resolve
function resolve(lω::LinearΩ{I, Int, V}, id::I, T) where {I, V}
  if id in keys(lω.ids)
    lω.ωvec[lω.ids[id]]::randrtype(T, lω)
  else
    val = rand(GLOBAL_RNG, T)
    push!(lω.ωvec, val)
    lω.ids[id] = length(lω.ωvec) # Store length explicitly?
    val
  end
end

function resolve(lω::LinearΩ{I, Segment, V}, id::I, T, dims::Dims{N}) where {N, I, V}
  if id in keys(lω.ids)
    seg = lω.ids[id]
    n = prod(seg.shape) # Fixme: Store this?
    ωvec = lω.ωvec[seg.startidx:seg.startidx+n-1]
    b::Array{randrtype(T, lω), N} = reshape(ωvec, dims)
    b
  else
    n = prod(dims)
    ωvec = rand(GLOBAL_RNG, T, dims)#::Array{randrtype(T, lω), N}
    @show typeof(ωvec)
    startidx = length(lω.ωvec) + 1
    append!(lω.ωvec, ωvec)
    lω.ids[id] = Segment(startidx, dims)
    reshape(ωvec, dims)::Array{randrtype(T, lω), N}
  end
end

function resolve(lω::LinearΩ{I, Segment, V}, id::I, T) where {I, V}
  if id in keys(lω.ids)
    seg = lω.ids[id]
    lω.ωvec[seg.startidx]::randrtype(T, lω)
  else
    val = rand(GLOBAL_RNG, T)
    startidx = length(lω.ωvec) + 1
    push!(lω.ωvec, val)
    lω.ids[id] = Segment(startidx, ())
    val
  end
end

Base.isempty(lω::LinearΩ) = isempty(lω.ωvec)
