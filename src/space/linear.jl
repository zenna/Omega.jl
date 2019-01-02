"""
LinearΩ: Stores Data in Linear Vector

# Properties
- Fast tracking (50 ns overhead)
- No overhead for linearization / delinearization
- Hence easy to sample from
- Good for optimization / inference methods which require linear interface
- Unique index for each rand value and hence:
  (i) Memory intensive
- Element lookup requires dictionary lookup and vector RAM so slower than Simple
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

using ZenUtils
function pass(x)
  # @grab x
  # display((x->x.value).(x   ))
  x
end
flat(rv, ω::T) where T <: LinearΩ = floatvec -> rv(T(ω.ids, pass(floatvec)))

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

"ω where ω[id] has been resampled with `proposal`"
resample(lω::LinearΩ, id, proposal) = resample!(deepcopy(lω), id, proposal)

"Mutative `resample`"
function resample!(lω::LinearΩ, id, proposal)
  segrng = segrange(lω.ids[id])
  lω.ωvec[segrng] .= proposal(lω.ωvec[segrng])
  lω
end

# Resolve
function resolve(lω::LinearΩ{I, Int, V}, id::I, T) where {I, V}
  if id in keys(lω.ids)
    lω.ωvec[lω.ids[id]]::randrtype(T)
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
    reshape(ωvec, dims)::Array{randrtype(T), N}
  else
    n = prod(dims)
    ωvec = rand(GLOBAL_RNG, T, dims)#::Array{randrtype(T), N}
    startidx = length(lω.ωvec) + 1
    append!(lω.ωvec, ωvec)
    lω.ids[id] = Segment(startidx, dims)
    reshape(ωvec, dims)::Array{randrtype(T), N}
  end
end

function resolve(lω::LinearΩ{I, Segment, V}, id::I, T) where {I, V}
  if id in keys(lω.ids)
    seg = lω.ids[id]
    lω.ωvec[seg.startidx]::randrtype(T)
  else
    val = rand(GLOBAL_RNG, T)
    startidx = length(lω.ωvec) + 1
    push!(lω.ωvec, val)
    lω.ids[id] = Segment(startidx, ())
    val
  end
end

Base.isempty(lω::LinearΩ) = isempty(lω.ωvec)
