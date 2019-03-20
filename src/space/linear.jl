# zt: should Linear Omega be default?
"""
LinearΩ: Stores data in single `AbstractVector{V}`

`lω[i] = lω.ωvec[lω.ids[i]]`

- No overhead for linearization / delinearization
- Good for optimization / inference methods which require linear interface
- If heterogenous elements are used, must convert (which can be slow)
"""
struct LinearΩ{I, SEG, V <: AbstractArray} <: ΩBase{I}
  ids::Dict{I, SEG} # zt: too precise, any associable will do. Map from Ω index I to segment of omvec
  ωvec::V
end

"`emp(::Type{T})` Empty container of type T"
function emp end

emp(a::Type{<:Array}) = a()

"$(SIGNATURES) Empty `LinearΩ`"
LinearΩ{I, SEG, V}() where {I, SEG, V} = LinearΩ{I, SEG, V}(Dict{I, SEG}(), emp(V))

linearize(lω::LinearΩ) = lω.ωvec
unlinearize(ωvec, lω::LinearΩ) = LinearΩ(lω.ids, ωvec)

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

# randtype #

# Defualt behaviour: return type is T
randrtype(lω::LinearΩ{I, SEG, V}, ::Type{T}) where {T, I, SEG, V} = T

# Handle ForwardDiff: If `lω.ωvec` is a Vector of Duals then return type will be a DUal 
randrtype(lω::LinearΩ{I, SEG, DT}, ::Type{T}) where {Q<:ForwardDiff.Dual, T, I, SEG, DT <: AbstractArray{Q}} = Q

# If Dims specified, return array of this type
randrtype(ω, T, ::Dims{N}) where N = Array{randrtype(ω, T), N}

# Specialization for when T is Type
randrtype(ω, ::Type{T}, ::Dims{N}) where {T, N} = Array{randrtype(ω, T), N}

# WHAT ABOUT Static Array
# sol? If V is a static vector then return a StaticArray
#    prob: reshaping it will return a reshape vector
#    prob: what if we want an actual staticarray instead
#  How to distingusih between staticarray rt and reshapedarray
# 1. specify in the model code
# 2. one issue is that Dims values aren't included in type information\: so there's no enough information in the model to specify the shape
# 3. It's might be possible with constant propagation that you get static types
# 4.  
# WHAT ABOUT Float32
# I think that's handled fine from the type of T
# Is there ever a case when say we want values to be tracked (duals) and some not?
# Maybe if we have some discrete parameters and dont want them to continuized
# But what if we do want them to be.
# 


nelem(lω) = length(lω.ωvec)
Base.values(lω::LinearΩ) = [lω.ωvec]
Base.isempty(lω::LinearΩ) = isempty(lω.ωvec)

# memrand #

# Flux-specific #

emp(a::Type{Flux.TrackedArray{A, B, C}}) where {A, B, C} = C()

# zt: This is type piracy: use a different method name
Base.append!(ta::Flux.TrackedArray, a::Array) =
  (append!(ta.data, a); append!(ta.grad, zero(a)))

Base.append!(ta::Flux.TrackedArray, tb::Flux.TrackedArray) =
  (append!(ta.data, tb.data); append!(ta.grad, tb.grad))

# using ZenUtils

function randrtype(lω::LinearΩ{I, SEG, V}, ::Type{T}, dims::Dims{N}) where {I, SEG, T, V <: Flux.TrackedArray{T}, N}
  Flux.TrackedArray{T, N, Array{T, N}}
end

# function randrtype(lω::LinearΩ{I, SEG, V}, ::Type{T}) where {I, SEG, V<: Flux.TrackedArray, T <: AbstractFloat}
#   Flux.Tracker.TrackedReal{T}
# end

# coerce(::Type{T}, x) where T = convert(T, x)
# coerse(::Type{T}, x) where T 
  
function memrand(lω::LinearΩ, id, X, dims::Dims; rng)
  RT = randrtype(lω,  X,  dims)
  seg = get(lω.ids, id, 0)
  if seg == 0
    res = rand(rng, X, dims)
    startidx = length(lω.ωvec) + 1
    lω.ids[id] = startidx:startidx + prod(dims) - 1
    res_::RT = res  # zt: issue si that might need to convert into correct format
    typeof(res_)
    typeof(lω.ωvec)
    # @grab res_
    p = lω.ωvec
    # @grab p
    append!(lω.ωvec, res_)
    res_
  else
    seg = lω.ids[id]
    subωvec = lω.ωvec[seg]
    res::RT = reshape(subωvec, dims) # reshaping a thing might produce a vector
    res
  end
end

memrand(lω::LinearΩ{I, SEG, V}, id, X; rng) where {I, SEG, V<: Flux.TrackedArray} = 
  first(memrand(lω, id, X, (1,); rng = rng))

function memrand(lω::LinearΩ, id, X; rng)
  RT = randrtype(lω, X)
  # @show typeof(lω)
  # @show X
  # @show RT, X, lω
  # @grab lω
  seg = get(lω.ids, id, 0)
  if seg == 0
    res::RT = rand(rng, X)
    res_::RT = res
    push!(lω.ωvec, res_)
    startidx = length(lω.ωvec) 
    lω.ids[id] = startidx:startidx
    res_
  else
    seg = lω.ids[id]
    subωvec = lω.ωvec[first(seg)]::RT
  end
end

