struct DirtyΩ <: Ω{Ints}
  _Float64::Dict{Ints, Vector{Float64}}
  _Float32::Dict{Ints, Vector{Float32}}
  _UInt32::Dict{Ints, Vector{UInt32}}
  counts::Dict{Ints, Int}
end

DirtyΩ() =
  DirtyΩ(Dict{Ints, Vector{Float64}}(),
             Dict{Ints, Vector{Float32}}(),
             Dict{Ints, Vector{UInt32}}(),
             Dict{Ints, Vector{Int}}())

append(is::Ints, i::Int) = tuple(is..., i)
Base.getindex(ω::DirtyΩ, i::Id) = ΩProj{DirtyΩ, Ints}(ω, (i,))
Base.getindex(ωπ::ΩProj{DirtyΩ}, i::Id) =
  ΩProj{DirtyΩ, Ints}(ωπ.ω, append(ωπ.id, i))

increment!(ω::DirtyΩ) = ω.counter += 1
resetcount(ω::DirtyΩ) = DirtyΩ(ω._Float64,
                                       ω._Float32,
                                       ω._UInt32,
                                       Dict{Ints, Int}())
parent(ω::DirtyΩ) = resetcount(ω)
parent(ωπ::ΩProj{DirtyΩ}) = resetcount(ωπ.ω)

@generated function closeopen(::Type{T}, ωπ::ΩProj{DirtyΩ}) where T
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