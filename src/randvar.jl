"Random Variable"
abstract type AbstractRandVar{T} end  # FIXME : Rename to RandVar

struct RandVar{T, Prim, F, TPL, I} <: AbstractRandVar{T} # Rename to PrimRandVar or PrimRv
  f::F      # Function (generally Callable)
  args::TPL
  id::I
end

"`RandVar` transformed by pure function `f::F`"
struct FRandVar{T, F, ARGS} <: AbstractRandVar{T}
  f::F
  args::ARGS
end

function RandVar{T, Prim}(f::F, args::TPL, id::I) where {T, Prim, F, TPL, I}
  RandVar{T, Prim, F, TPL, I}(f, args, id)
end

function RandVar{T, Prim}(f::F, args::TPL) where {T, Prim, F, TPL}
  RandVar{T, Prim, F, TPL, Int}(f, args, 0) # FIXME: HACK
end

function RandVar{T}(f::F) where {T, F}
  RandVar{T, true, F, Tuple{}, Int}(f, (), ωnew()) # FIXME: HACK
end

apl(x, ω::Omega) = x
apl(x::AbstractRandVar, ω::Omega) = x(ω)

## FIXME: Type instability
function (rv::RandVar{T, true})(ω::DirtyOmega) where T
  # ω = parent(ω)
  args = map(a->apl(a, ω), rv.args)
  (rv.f)(resetcount(ω)[rv.id], args...)
end

# (rv::RandVar)(ω::SubOmega) = rv(parent(ω))

function (rv::RandVar{T, false})(ω::DirtyOmega) where T
  # ω = parent(ω)
  args = map(a->apl(a, ω), rv.args)
  (rv.f)(args...)
end

function (rv::NTuple{N, RandVar})(ω::Omega) where N
  applymany(rv, ω)
end

function Base.copy(x::RandVar{T}) where T
  RandVar{T}(x.f, x.ωids)
end

name(x) = x
name(rv::RandVar) = string(rv.f)
Base.show(io::IO, rv::RandVar{T}) where T=
  print(io, "$(name(rv))($(join(map(name, rv.args), ", ")))::$T")