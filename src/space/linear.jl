# zt: should Linear Omega be default?
"""
LinearΩ: Stores data in single `Vector{V}`

`lω[i] = lω.ωvec[lω.ids[i]]`

- No overhead for linearization / delinearization
- Good for optimization / inference methods which require linear interface
- If heterogenous elements are used, must convert (which can be slow)
"""
struct LinearΩ{I, SEG, V} <: ΩBase{I}
  ids::Dict{I, SEG} # zt: too precise, any associable will do. Map from Ω index I to segment of omvec
  ωvec::Vector{V}   # zt: too precise, what about static vector?
end

"$(SIGNATURES) Empty `LinearΩ`"
LinearΩ{I, SEG, V}() where {I, SEG, V} = LinearΩ{I, SEG, V}(Dict{I, V}(), V[])

function addsegment!(lω, ωvec, id)
  startidx = length(lω.ωvec) + 1
  append!(lω.ωvec, ωvec)
  lω.ids[id] = Segment(startidx, dims)
end

linearize(lω::LinearΩ) = lω.ωvec
unlinearize(ωvec, lω::LinearΩ{I, SEG, V}) where {I, SEG, V}  = LinearΩ{I, SEG, V}(lω.ids, ωvec)

# zt: fixme, dont use T, determine it by the input
flat(rv, ω::T) where T <: LinearΩ = floatvec -> rv(T(ω.ids, floatvec))

# flat2(rv, ω::LinearΩ) = LinearΩ(floatvec)

# zt: renamed this? Wanted to distinguish getting ith Omega value from
# projection. Maybe projection shouldnt overload getindex?
getdim(lω, i) = lω.ωvec[i]

# Update #

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

function randrtype(::Type{T}, lω::LinearΩ{I, SEG, DT}) where {T, I, SEG, DT <: ForwardDiff.Dual}
  # # That's teh nuts and bolts of it.
  # # @assert false
  # #   
  # # @assert false
  # @show lω
  DT
end

randrtype(::Type{T}, ω, ::Dims{N}) where {T, N} = Array{randrtype(T, ω), N}
randrtype(::Type{T}, lω::LinearΩ{I, SEG, V <: TrackedArray} , ::Dims{N}) where {T, N} = Array{randrtype(T, ω), N}


nelem(lω) = length(lω.ωvec)
Base.values(lω::LinearΩ) = [lω.ωvec]
Base.isempty(lω::LinearΩ) = isempty(lω.ωvec)

# memrand #

# What do these terms mean?
# RT: Return type
# X: (not quite, right, because might be dual,etc )

# memrand(lω::LinearΩ, id, ::Type{X}, dims::Dims; rng) where X =
#   memrand(lω, id, X, dims; rng = rng)
memrand(lω::LinearΩ, id, ::Type{X}, dims::Integer...; rng) where X =
  memrand(lω, id, X, Dims(dims); rng = rng)
memrand(lω::LinearΩ, id, ::Type{X}, d::Integer, dims::Integer...; rng) where X =
  memrand(lω, id, X, Dims((d, dims...)); rng = rng)

memrand(lω::LinearΩ, id, args...; rng) where X =
  memrand(lω, id, Float64, args...; rng = rng)

# Hypothetical solution
function memrand(lω::LinearΩ, id, ::Type{X}, dims::Dims; rng) where X
  @show RT = randrtype(X, lω, dims)
  seg = get(lω.ids, id, 0)
  if seg == 0
    res = rand(rng, X, dims)
    startidx = length(lω.ωvec) + 1
    lω.ids[id] = startidx:startidx + prod(dims) - 1
    res_::RT = res
    @show res_
    append!(lω.ωvec, res_)
    res_
  else
    seg = lω.ids[id]
    subωvec = lω.ωvec[seg]
    res::RT = reshape(subωvec, dims)
    res
  end
end

function test()
  lω = defΩ()()
  Omega.Space.memrand(lω, [1], Float64, (100,))
  lω = LinearΩ{Vector{Int}, UnitRange{Int}, TrackedArray{Float64, 1, Array{Float64, 1}}}
  x = normal(0, 1, (100,))
end

function memrand(lω::LinearΩ, id, ::Type{X}; rng) where X
  @show RT = randrtype(X, lω)
  seg = get(lω.ids, id, 0)
  if seg == 0
    res::RT = rand(rng, X)
    append!(lω.ωvec, res)
    startidx = length(lω.ωvec) 
    lω.ids[id] = startidx:startidx
    res
  else
    seg = lω.ids[id]
    subωvec = lω.ωvec[first(seg)]::RT
  end
end
