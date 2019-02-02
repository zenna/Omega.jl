# zt: should Liner Omega be default?
"""
LinearΩ: Stores data in single `Vector{V}`

`lω[i] = lω.ωvec[lω.ids[i]]`

- No overhead for linearization / delinearization
- Good for optimization / inference methods which require linear interface
- If heterogenous elements are used, must convert (which can be slow)
"""
struct LinearΩ{I, SEG, V} <: ΩBase{I}
  ids::Dict{I, SEG} # Map from Ω index I to segment of omvec
  ωvec::Vector{V}
end

"$(SIGNATURES) Empty `LinearΩ`"
LinearΩ{I, SEG, V}() where {I, SEG, V} = LinearΩ{I, SEG, V}(Dict{I, V}(), V[])

"$(SIGNATURES) Number of components of `lω`"
nelem(lω::LinearΩ) = length(lω.ωvec)

# zt: clarify docstring
"""Represents a segment (i.e. SubVector) of a `lω.ωvec` where `lω::LinearΩ`
`lω.ωvec[seg.startidx:seg.startidx + prod(seg.shape) - 1]`"""
struct Segment{D <: Dims}
  startidx::Int # 
  shape::D
end

length(seg::Segment) = prod(seg.shape) # Fixme: Store this ?

"Number of elements of "
nelem(seg::Segment) = prod(seg.shape)

function segment(lω, seg::Int, RT)

end

"Segment of `lω.ωvec` indicated by `seg`"
segment(lω, seg::Segment) = lω.ωvec[seg.startidx:seg.startidx+ nelem(seg)-1]

function addsegment!(lω, ωvec, id)
  startidx = length(lω.ωvec) + 1
  append!(lω.ωvec, ωvec)
  lω.ids[id] = Segment(startidx, dims)
end

"lb:ub indices of ωvec subsumed by segment"
segrange(seg::Segment) = seg.startidx:seg.startidx+nelem(seg) - 1

linearize(lω::LinearΩ) = lω.ωvec
unlinearize(ωvec, lω::LinearΩ{I, SEG, V}) where {I, SEG, V}  = LinearΩ{I, SEG, V}(lω.ids, ωvec)

flat(rv, ω::T) where T <: LinearΩ = floatvec -> rv(T(ω.ids, floatvec))

# zt: renamed this? Wanted to distinguish getting ith Omega value from
# projection. Maybe projection shouldnt overload getindex?
getdim(lω, i) = lω.ωvec[i]

"Apply `kernel` to ith component" 
function update(lω::LinearΩ, i::Int, kernel::Function) # zt: use name other than kernel
  # zt: `kernel` Might be a callable
  # zt: isn't there a more efficient version which just copies ωvec?
  lω_ = deepcopy(lω)
  lω_.ωvec[i] = kernel(lω_.ωvec[i])
  lω_
end

function update(lω::LinearΩ, i::Int, val)
  # This update != previous update, dont pun!
  lω_ = deepcopy(lω)
  lω_.ωvec[i] = val
  lω_
end

# zt: docstring!
function randrtype(::Type{T}, lω::LinearΩ{I, SEG, V}) where {T, I, SEG, V}
  # @show V
  # @show T
  # @assert false
  T
end

function randrtype(::Type{T}, lω::LinearΩ{I, SEG, <:ForwardDiff.Dual}) where {T, I, SEG}
  # # That's teh nuts and bolts of it.
  # # @assert false
  # #   
  # # @assert false
  # @show lω
  ForwardDiff.Dual
end

# zt: is this a puN? Maybe not?
Base.values(lω::LinearΩ) = [lω.ωvec]

Random.gentype(typeof(1:10))

# There's a design decision.
# If I intercept rand, then I'll need to intercept all combinations
# Including randn, etc, etc

# OTOH we can then the omega pass all the way through
# But if we do that then (i) we need to leave the tags on
# And it's lower then that what we probably want in most cases.

# So I shoudl do both!

memrand(lωπ::ΩProj{I, <:LinearΩ}, dims::Integer...) where I = memrand(lωπ, Float64, Dims(dims))
memrand(lωπ::ΩProj{I, <:LinearΩ}, X, dims::Dims) where I  = rand!(lωπ, Array{Random.gentype(X)}(undef, dims), X)
memrand(lωπ::ΩProj{I, <:LinearΩ}, X, d::Integer, dims::Integer...) where I = memrand(lωπ, X, Dims((d, dims...)))  

# Hypothetical solution
function memrand(lωπ::ΩProj{I, <:LinearΩ}, T, dims::Integer; rng) where {I, V}
  # @pre do we expect the id to be in 
  lω, id  = lωπ.ω, lωπ.id
  seg = get(lω.ids, id, 0)
  if seg == 0
    res = rand(rng, T)
    push!(lω.ωvec, val)
    lω.ids[id] = length(lω.ωvec) # Store length explicitly?
    res
  else
    val::randrtype(T, lω)
  end
end




function memrand(lω::LinearΩ{I, Segment, V}, id::I, T, dims::Dims{N}; rng) where {N, I, V}
  if id in keys(lω.ids)
    seg = lω.ids[id]
    n = prod(seg.shape) # Fixme: Store this?
    ωvec = lω.ωvec[seg.startidx:seg.startidx+n-1]
    b::Array{randrtype(T, lω), N} = reshape(ωvec, dims)
    b
  else
    n = prod(dims)
    ωvec = rand(rng, T, dims)#::Array{randrtype(T, lω), N}
    addsegment!()
    # @show typeof(ωvec)
    # @show V
    startidx = length(lω.ωvec) + 1
    append!(lω.ωvec, ωvec)
    lω.ids[id] = Segment(startidx, dims)
    a::Array{randrtype(T, lω), N} = reshape(ωvec, dims)
    a
  end
end

function memrand(lω::LinearΩ{I, Segment, V}, id::I, T) where {I, V}
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
