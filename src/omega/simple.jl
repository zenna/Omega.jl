"""
Fast SimpleOmega

# Properties
- Fast tracking (50 ns overhead)
- Fast to get linear view
- Hence easy to sample from
- Unique index for each rand value and hence:
  (i) Memory intensive
  (ii) Will give wrong results if not indexed corretly
"""
struct SimpleOmega{I, V} <: Omega{I}
  vals::Dict{I, V}
end

SimpleOmega() = SimpleOmega(Dict{Vector{Int}, Float64}())
SimpleOmega{I, V}() where {I, V} = SimpleOmega{I, V}(Dict{I, V}())

Base.values(sω::SimpleOmega) = values(sω.vals)
Base.keys(sω::SimpleOmega) = keys(sω.vals)

"Linearize ω into flat vector"
function linearaize end

"Inverse of `linearize`, structure vector into ω"
function unlinearize end

linearize(sω::SimpleOmega{I, V}) where {I, V <: Real} = collect(values(sω.vals))

function linearize(sω::SimpleOmega{I, V}) where {I, V <: AbstractArray}
  # warn("Are keys in order?")
  # vcat((view(a, :) for a in values(sω.vals))...)
  vcat((a[:] for a in values(sω.vals))...)
end

function unlinearize(ωvec, sω::SimpleOmega{I, V}, f=identity) where {I, V <: AbstractArray}
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
  SimpleOmega{I, V}(Dict(pairs...))
end

function unlinearize(ωvec, sω::SimpleOmega{I, V}) where {I, V <: Real}
  # Keys not sorted, might be wrong
  SimpleOmega(Dict(k => ωvec[i] for (i, k) in enumerate(keys(sω.vals))))
end

function Base.getindex(sω::SO, i::Int) where {I, SO <: SimpleOmega{<:I}}
  OmegaProj{SO, I}(sω, base(I, i))
end

## Rand
## ====
function Base.rand(ωπ::OmegaProj{O}, ::Type{T}) where {T, I, O <: SimpleOmega{I, <:Real}}
  get!(()->rand(Base.GLOBAL_RNG, T), ωπ.ω.vals, ωπ.id)
end

function Base.rand(ωπ::OmegaProj{O}, ::Type{T},  dims::Dims) where {T, I, V, O <: SimpleOmega{I, V}}
  @assert false "Not implemented (blocking to prevent silent errors)"
end

function Base.rand(ωπ::OmegaProj{O}, ::Type{T},  dims::Dims) where {T, I, A<:AbstractArray, O <: SimpleOmega{I, A}}
  get!(()->rand(Base.GLOBAL_RNG, T, dims), ωπ.ω.vals, ωπ.id)
end

function Base.rand(ωπ::OmegaProj{O}, ::Type{T}) where {T, I, A<:AbstractArray, O <: SimpleOmega{I, A}}
  val = get!(()->Float64[rand(Base.GLOBAL_RNG, T)], ωπ.ω.vals, ωπ.id)
  first(val)
end

function Base.rand(ωπ::OmegaProj{O}, ::Type{T},  dims::Dims) where {T, I, A<:Flux.TrackedArray, O <: SimpleOmega{I, A}}
  get!(()->param(rand(Base.GLOBAL_RNG, T, dims)), ωπ.ω.vals, ωπ.id)
end

## Value Type
## ==========

struct ValueTuple
  _Float64::Float64
  _Float32::Float32
  _UInt32::UInt32
end

function Base.rand(ωπ::OmegaProj{O}, ::Type{UInt32}) where {I, O <: SimpleOmega{I, ValueTuple}}
  if ωπ.id ∈ keys(ωπ.ω.vals)
    ωπ.ω.vals[ωπ.id]._UInt32::UInt32
  else
    val = rand(Base.GLOBAL_RNG, UInt32)
    ωπ.ω.vals[ωπ.id] = ValueTuple(0.0, 0.0, val)
    val
  end
end

function Base.rand(ωπ::OmegaProj{O}, ::Type{CO}) where {I, CO, O <: SimpleOmega{I, ValueTuple}}
  if ωπ.id ∈ keys(ωπ.ω.vals)
    return ωπ.ω.vals[ωπ.id]._Float64
  else
    val = rand(Base.GLOBAL_RNG, CO)
    ωπ.ω.vals[ωπ.id] = ValueTuple(val, Float32(0.0), UInt(0))
    return val
  end
end

function (rv::RandVar{T, true})(ω::SimpleOmega) where T
  args = map(a->apl(a, ω), rv.args)
  (rv.f)(ω[rv.id], args...)
end

function (rv::RandVar{T, false})(ω::SimpleOmega) where T
  args = map(a->apl(a, ω), rv.args)
  (rv.f)(args...)
end

function Base.merge!(sω1::SimpleOmega, sω2::SimpleOmega)
  for (k, v) in sω2.vals
    sω1.vals[k] = v
  end
  sω1
end

Base.merge!(ωπ1::OmegaProj{O}, ωπ2::OmegaProj{O}) where {O <: SimpleOmega} =
  merge!(ωπ1.ω, ωπ2.ω)


Base.isempty(sω::SimpleOmega) = isempty(sω.vals)
Base.length(sω::SimpleOmega) = length(sω.vals)
