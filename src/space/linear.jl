# zt: should Linear Omega be default?
"""
LinearΩ: Stores data in single `Vector{V}`

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
randrtype(lω::LinearΩ{I, SEG, V}, ::Type{T}) where {T, I, SEG, V} = T
randrtype(lω::LinearΩ{I, SEG, DT}, ::Type{T}) where {Q<:ForwardDiff.Dual, T, I, SEG, DT <: AbstractArray{Q}} = Q
randrtype(ω, ::Type{T}, ::Dims{N}) where {T, N} = Array{randrtype(ω, T), N}
randrtype(ω, T, ::Dims{N}) where N = Array{randrtype(ω, T), N}


nelem(lω) = length(lω.ωvec)
Base.values(lω::LinearΩ) = [lω.ωvec]
Base.isempty(lω::LinearΩ) = isempty(lω.ωvec)

# memrand #

# Flux-specific #

emp(a::Type{Flux.TrackedArray{A, B, C}}) where {A, B, C} = C()

Base.append!(ta::Flux.TrackedArray, a::Array) =
  (append!(ta.data, a); append!(ta.grad, zero(a)))

function randrtype(lω::LinearΩ{I, SEG, V}, ::Type{T}, ::Dims{N}) where {I, SEG, V<: Flux.TrackedArray, T, N}
  @show V
  @assert false
  Flux.TrackedArray{T, N,  }
   Array{randrtype(T, ω), N}
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
    res_
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

