"Index of Probability Space"
Id = Int

LazyId() = LazyId(Int[])
function Base.getindex(l::LazyId, i::Int)
  if i > size(l.ids)
    next!(l.ids)
  else
    l.ids[i]
  end
end
next!(l::LazyId) = push!(l.ids, ωnew())

"Probability Space"
abstract type Omega <: AbstractRNG end

"Sample Space"
mutable struct DictOmega{T} <: Omega
  d::Dict{Int, T}
  counter::Int
end

DictOmega{T}() where T = DictOmega{T}(Dict{Int, T}(), 1)
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

# function Base.getindex(ω::T, i::I) where {T <: SubOmega, I}
#   @show resetcount(parent(ω))[i]
# end
RV = Union{Integer, Base.Random.FloatInterval}

function Base.rand(sω::SubOmega{I, Int}, ::Type{T}) where {I, T <: RV}
  get!(()->rand(Base.Random.GLOBAL_RNG, T), sω.ω.d, sω.id)
end

function Base.rand(sω::SubOmega{I, LazyId}, ::Type{T}) where {I, T <: RV}
  id = sω.id[sω.ω.counter]
  increment!(sω.ω)
  # next!(sω.id)
  get!(()->rand(Base.Random.GLOBAL_RNG, T), sω.ω.d, id)
end

global ωcounter = 1
"Unique dimension id"
function ωnew()
  global ωcounter = ωcounter + 1
  ωcounter - 1
end

mutable struct DirtyOmega <: Omega
  _Float64::Dict{Int, Float64}
  _Float32::Dict{Int, Float32}
  _UInt32::Dict{Int, UInt32}
  counter::Int
end

DirtyOmega() = DirtyOmega(Dict{Int, Float64}(),
                          Dict{Int, Float32}(),
                          Dict{Int, UInt32}(), 1)

function closeopen(::Type{UInt32}, sω::SubOmega, id::Int)
  get!(()->rand(Base.Random.GLOBAL_RNG, UInt32), sω.ω._UInt32, id)
end
                          
function closeopen(::Type{Base.Random.CloseOpen}, sω::SubOmega, id::Int)
  get!(()->rand(Base.Random.GLOBAL_RNG, Base.Random.CloseOpen), sω.ω._Float64, id)
end

function closeopen(::Type{Base.Random.Close1Open2}, sω::SubOmega, id::Int)
  get!(()->rand(Base.Random.GLOBAL_RNG, Base.Random.Close1Open2), sω.ω._Float64, id)
end

function Base.rand(sω::SubOmega{I, Int}, ::Type{T}) where {I, T <: RV}
  id = sω.id
  closeopen(T, sω, id)
end

function Base.rand(sω::SubOmega{I, LazyId}, ::Type{T}) where {I, T <: RV}
  id = sω.id[sω.ω.counter]
  increment!(sω.ω)
  closeopen(T, sω, id)
end

increment!(ω::DirtyOmega) = ω.counter += 1
resetcount(ω::DirtyOmega) = DirtyOmega(ω._Float64,
                                       ω._Float32,
                                       ω._UInt32,
                                       1)
parent(ω::DirtyOmega) = resetcount(ω)