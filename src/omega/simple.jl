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

linearize(sω::SimpleOmega{I, V}) where {I, V <: Real} = collect(values(sω.vals))

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

function Base.rand(ωπ::OmegaProj{O}, ::Type{CloseOpen}) where {I, O <: SimpleOmega{I, ValueTuple}}
  if ωπ.id ∈ keys(ωπ.ω.vals)
    return ωπ.ω.vals[ωπ.id]._Float64
  else
    val = rand(Base.GLOBAL_RNG, Float64)
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
