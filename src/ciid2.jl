"Random Variable"
abstract type AbstractRandVar{T} end  # FIXME : Rename to RandVar

# Base.getindex(rng::AbstractRNG, ::Int64) = rng 

"Random Variable `ω ↦ T`"
struct RandVar{T, Prim, F, TPL, I} <: AbstractRandVar{T} # Rename to PrimRandVar or PrimRv
  f::F      # Function (generally Callable)
  args::TPL
  id::I
end

# "Pure transformation of a RandVar"
# struct FRandVar{T, }

function RandVar{T, Prim}(f::F, args::TPL, id::I) where {T, Prim, F, TPL, I}
  RandVar{T, Prim, F, TPL, I}(f, args, id)
end

function RandVar{T, Prim}(f::F, args::TPL) where {T, Prim, F, TPL}
  RandVar{T, Prim, F, TPL, Int}(f, args, 0) # FIXME: HACK
end

function RandVar{T}(f::F) where {T, F}
  RandVar{T, true, F, Tuple{}, Int}(f, (), uid()) # FIXME: HACK
end

function Base.copy(x::RandVar{T}) where T
  RandVar{T}(x.f, x.ωids)
end

## C.I.I.D
## =====

"Mapping from ids to ids"
const IdMap = Dict{Int, Int}

# "Replacement RandVar"
# struct ReplRandVar{T, RV <: AbstractRandVar, I} <: AbstractRandVar{T}
#   rv::RV
#   idmap::IdMap
#   id::I
# end

# function (rv::ReplRandVar{T})(ω::Ω) where T  
#   RandVar{T, true, F, Tuple{}, Int}(f, (), uid()) # FIXME: HACK
# end

# M"`RandVar` identically distributed to `x`, conditionally independent given `y`"
# function ciid(x::RandVar, y::RandVar)
#   ReplRandVar(x, IdMap(y.id => x.id))
# end

# ReplRandVar(rv::RV, idmap) where {T, RV <: AbstractRandVar{<:T}} = 
#   ReplRandVar{T, RV}(rv, idmap)

## I.I.D
## =====
# "Random Variable `ω ↦ T`"
# struct IIDRandVar{T, Prim, F, TPL, I} <: AbstractRandVar{T} # Rename to PrimRandVar or PrimRv
#   f::F      # Function (generally Callable)
#   args::TPL
#   id::I
# end

# realiid(x::RandVar) = 3

function (rv::RandVar{T, true})(ω::SimpleΩ) where T
  args = map(a->apl(a, ω), rv.args)
  (rv.f)(ω[rv.id], args...)
end

"Infer T from function `f: w -> T`"
function infer_elemtype(f)
  rt = Base.return_types(f, (Omega.DirtyΩ,))
  @pre length(rt) == 1 "Could not infer unique return type"
  rt[1]
end

"Construct an i.i.d. of `X`"
ciid(f, T=infer_elemtype(f)) = RandVar{T}(f)

## Printing
## ========
name(x) = x
name(rv::RandVar) = string(rv.f)
Base.show(io::IO, rv::RandVar{T}) where T=
  print(io, "$(name(rv))($(join(map(name, rv.args), ", ")))::$T")

