struct CountVec{T}
  Vector{T}
  count::Int
end

struct PairOmega <: Omega
  _Float64::Dict{Int, CountVec{Float64}}
  _Float32::Dict{Int, CountVec{Float32}}
  _UInt32::Dict{Int, CountVec{UInt32}}
end

PairOmega() =
  PairOmega(Dict{Int, CountVec{Float64}}(),
            Dict{Int, CountVec{Float32}}(),
            Dict{Int, CountVec{UInt32}}())


"Cantour Pairing Function"
pair(k1, k2) = div((k2 + k2)*(k1 + k2 + 1), 2) + k2

"Projection of `ω` onto compoment `id`"
struct PairOmegaProj <: Omega
  ω::PairOmega
  id::Int
end

Base.getindex(ω::PairOmegaProj, i::Int) = PairOmegaProj(ω, 1)
Base.getindex(ωπ::PairOmegaProj, i::Id) = PairOmegaProj(ωπ.ω, pair(ωπ.id, i))

@generated function closeopen(::Type{T}, ωπ::PairOmegaProj) where T
  T2, T2Sym = lookup(T)
  quote
  cvec = get!(countvec, ωπ.ω, ωπ.id)
  
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

function Base.rand(ωπ::PairOmegaProj, ::Type{T}) where {T <: RV}
  closeopen(T, ωπ)
end