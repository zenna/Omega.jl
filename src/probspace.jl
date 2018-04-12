global ωcounter = 1
"Unique dimension id"
function ωnew()
  global ωcounter = ωcounter + 1
  ωcounter - 1
end

"Index of Probability Space"
Id = Int
AstId = Int
RandVarId = Int
InvocationId = Int

"Probability Space"
abstract type Omega <: AbstractRNG end

mutable struct DirtyOmega <: Omega
  _Float64::Dict{Tuple{RandVarId, AstId}, Vector{Float64}}
  _Float32::Dict{Tuple{RandVarId, AstId}, Vector{Float32}}
  _UInt32::Dict{Tuple{RandVarId, AstId}, Vector{UInt32}}
  counts::Dict{Tuple{RandVarId, AstId}, Vector{InvocationId}}
  counter::Int
end

DirtyOmega() =
  DirtyOmega(Dict{Tuple{RandVarId, AstId}, Vector{Float64}}(),
             Dict{Tuple{RandVarId, AstId}, Vector{Float32}}(),
             Dict{Tuple{RandVarId, AstId}, Vector{UInt32}}(),
             Dict{Tuple{RandVarId, AstId}, Vector{Int}}(),
             1)

"Projection of `ω` onto compoment `id`"
struct OmegaProj <: Omega
  ω::DirtyOmega
  id::RandVarId
end

Base.getindex(ω::DirtyOmega, i::RandVarId) = OmegaProj(ω, i)

struct OmegaAst <: Omega
  ωπ::OmegaProj
  id::AstId
end

Base.getindex(ω::OmegaProj, i::RandVarId) = OmegaAst(ω, i)

increment!(ω::DirtyOmega) = ω.counter += 1
resetcount(ω::DirtyOmega) = DirtyOmega(ω._Float64,
                                       ω._Float32,
                                       ω._UInt32,
                                       Dict{Tuple{RandVarId, AstId}, Int}(), # TODO RESSET COUNTS HERE
                                       1)
function next!(ω::DirtyOmega, id::Tuple{Int, Int})
  if id in keys(ω.counts)
    val = ω.counts[id]
    ω.counts[id] += 1
    return val
  else
    ω.counts[id] = 1
    return 1
  end
end
parent(ω::DirtyOmega) = resetcount(ω)
parent(ωπ::OmegaProj) = resetcount(ωπ.ω)
parent(ωast::OmegaAst) = resetcount(ωast.ωπ.ω)

## Rand
## ====
RV = Union{Integer, Base.Random.FloatInterval}
function closeopen(::Type{UInt32}, ωπ::OmegaProj, id::Int)
  get!(()->rand(Base.Random.GLOBAL_RNG, UInt32), ωπ.ω._UInt32, id)
end
                          
# function closeopen(::Type{Base.Random.CloseOpen}, ωπ::OmegaProj, id::Int)
#   get!(()->rand(Base.Random.GLOBAL_RNG, Base.Random.CloseOpen), ωπ.ω._Float64, id)
# end

# Avoid this Lookup!

function closeopen(::Type{Base.Random.Close1Open2}, ωast::OmegaAst, id::Tuple{Int, Int})
  # Logic 
  # If the ids are not in omega
  # It means we've never sampled from it bere 
  # and the counter must be zero, so initialzie
  if id in keys(ωast.ωπ.ω._Float64)
    val = rand(Base.Random.GLOBAL_RNG, Base.Random.Close1Open2)
    ωast.ωπ.ω._Float64[id] = Float64[val]
    ωast.ωπ.ω.counts[id] = 1
    return val
  else
    # The val is in there
    # count could be anything
  
  # If the value is in there, take the value at its counter position
  # When do we restart counter position?
  # Wjem we gp omtp tje ramdvar
  if id in keys(ωast.ωπ.ω._Float64)
    @show "hello"
    ωast.ωπ.ω._Float64
  else
    val = rand(Base.Random.GLOBAL_RNG, Base.Random.Close1Open2)
    push!(ωast.ωπ.ω._Float64, val)
  end
  val
end

function Base.rand(ωπ::OmegaProj, ::Type{T}) where {T <: RV}
  ωastid = ωπ.ω.counter
  ωast = ωπ[ωastid]
  increment!(ωπ.ω)
  rand(ωast, T)
end

function Base.rand(ωast::OmegaAst, ::Type{T}) where {T <: RV}
  id = (ωast.ωπ.id, ωast.id)
  closeopen(T, ωast, id)
end