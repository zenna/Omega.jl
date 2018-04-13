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

"Probability Space"
abstract type Omega <: AbstractRNG end

const Ints = NTuple{N, Int} where N

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
Base.getindex(ω::DirtyOmega, i::Id) = OmegaProj(ω, (1,))
Base.getindex(ωπ::OmegaProj, i::Id) = OmegaProj(ωπ.ω, append(ωπ.id, i))

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
    id = ωπ.id
    counts = ωπ.ω.counts
    actualω = get!(ωπ.ω.$T2Sym, id, $T2[])
    count = get!(counts, id, 1)
    if count > length(actualω)
      @assert count == length(actualω) + 1
      val = rand($T2)
      push!(actualω, val)
    end
    counts[id] += 1
    return actualω[count]
  end
end

function Base.rand(ωπ::OmegaProj, ::Type{T}) where {T <: RV}
  closeopen(T, ωπ)
end