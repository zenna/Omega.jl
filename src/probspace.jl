"Index of Probability Space"
Id = Int

"Lazy List of Ids"
struct LazyId
  d::Dict{Int, Id}
end
LazyId() = LazyId(Dict{Int, Int}())
Base.getindex(l::LazyId, i::Int) = get!(ωnew, l.d, i)

"Probability Space"
abstract type Omega <: AbstractRNG end

"Sample Space"
mutable struct DictOmega{T} <: Omega
  d::Dict{Int, T}
  counter::Int
end

DictOmega() = DictOmega(Dict{Int, Any}(), 1)
increment!(ω::DictOmega) = ω.counter += 1
resetcount(ω::DictOmega{T}) where T = DictOmega{T}(ω.d, 1)
parent(ω::DictOmega) = resetcount(ω)

"Projection of `Omega` onto indices `id`"
struct SubOmega{T<:Omega, I} <: Omega
  ω::T
  id::I
end
parent(sω::SubOmega) = resetcount(sω.ω)

function Base.getindex(ω::T, i::I) where {T <: Omega, I}
  SubOmega{T, I}(ω, i)
end

RV = Union{Integer, Base.Random.FloatInterval}

function Base.rand(sω::SubOmega{I, Int}, ::Type{T}) where {I, T <: RV}
  get!(()->rand(Base.Random.GLOBAL_RNG, T), sω.ω.d, sω.id)
end

function Base.rand(sω::SubOmega{I, LazyId}, ::Type{T}) where {I, T <: RV}
  id = sω.id[sω.ω.counter]
  increment!(sω.ω)
  get!(()->rand(Base.Random.GLOBAL_RNG, T), sω.ω.d, id)
end

ωids(ω::Omega) = Set(keys(ω.d))
global ωcounter = 1
"Unique dimension id"
function ωnew()
  global ωcounter = ωcounter + 1
  ωcounter - 1
end