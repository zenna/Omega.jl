import Base.Random: Close1Open2, CloseOpen

global ωcounter = 1
"Unique dimension id"
function ωnew()
  global ωcounter = ωcounter + 1
  ωcounter - 1
end

macro id()
  Mu.ωnew()
end

"Index of Probability Space"
Id = Int
AstId = Int
RandVarId = Int
InvocationId = Int

"Probability Space"
abstract type Omega <: AbstractRNG end

Ints = NTuple{N, Int} where N

struct DirtyOmega <: Omega
  _Float64::Dict{Ints, Vector{Float64}}
  _Float32::Dict{Ints, Vector{Float32}}
  _UInt32::Dict{Ints, Vector{UInt32}}
  counts::Dict{Ints, Int}
end

DirtyOmega() =
  DirtyOmega(Dict{Ints, Vector{Float64}}(),
             Dict{Ints, Vector{Float32}}(),
             Dict{Ints, Vector{UInt32}}(),
             Dict{Ints, Vector{Int}}())

"Projection of `ω` onto compoment `id`"
struct OmegaProj <: Omega
  ω::DirtyOmega
  id::Ints
end

append(is::Ints, i::Int) = tuple(is..., i)
Base.getindex(ω::DirtyOmega, i::RandVarId) = OmegaProj(ω, (1,))
Base.getindex(ωπ::OmegaProj, i::RandVarId) = OmegaProj(ωπ.ω, append(ωπ.id, i))

increment!(ω::DirtyOmega) = ω.counter += 1
resetcount(ω::DirtyOmega) = DirtyOmega(ω._Float64,
                                       ω._Float32,
                                       ω._UInt32,
                                       Dict{Ints, Int}())
parent(ω::DirtyOmega) = resetcount(ω)
parent(ωπ::OmegaProj) = resetcount(ωπ.ω)

## Rand
## ====
RV = Union{Integer, Base.Random.FloatInterval}
lookup(::Type{UInt32}) = UInt32, :_UInt32
lookup(::Type{Close1Open2}) = Float64, :_Float64
lookup(::Type{CloseOpen}) = Float64, :_Float64

@generated function closeopen(::Type{T}, ωπ::OmegaProj) where T
  T2, T2Sym = lookup(T)
  quote
  if ωπ.id in keys(ωπ.ω.$T2Sym)
    if ωπ.id ∉ keys(ωπ.ω.counts)
      ωπ.ω.counts[ωπ.id] = 1
    end
    count = ωπ.ω.counts[ωπ.id]
    length(ωπ.ω.$T2Sym[ωπ.id])
    if count <= length(ωπ.ω.$T2Sym[ωπ.id])
      ωπ.ω.counts[ωπ.id] += 1
      return ωπ.ω.$T2Sym[ωπ.id][count]
    else
      @assert count == length(ωπ.ω.$T2Sym[ωπ.id]) + 1
      val = rand($T2)
      push!(ωπ.ω.$T2Sym[ωπ.id], val)
      ωπ.ω.counts[ωπ.id] += 1
      return val
    end
  else
    val = rand($T2)
    ωπ.ω.$T2Sym[ωπ.id] = $T2[val]
    ωπ.ω.counts[ωπ.id] = 2
    return val
  end
  end
end

function Base.rand(ωπ::OmegaProj, ::Type{T}) where {T <: RV}
  closeopen(T, ωπ)
end