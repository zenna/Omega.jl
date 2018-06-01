"Random Variable"
abstract type AbstractRandVar{T} end  # FIXME : Rename to RandVar

# Base.getindex(rng::AbstractRNG, ::Int64) = rng

struct RandVar{T, Prim, F, TPL, I} <: AbstractRandVar{T} # Rename to PrimRandVar or PrimRv
  f::F      # Function (generally Callable)
  args::TPL
  id::I
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

function Base.copy(x::RandVar{T}) where T
  RandVar{T}(x.f, x.ωids)
end

apply(f, xs...) = f(xs...)
# FIXME this looze type
(rv::RandVar)(xs...) = RandVar{Any, false}(apply, (rv, xs...))

## I.I.D
## =====
"Infer T from function `f: w -> T`"
function infer_elemtype(f, args...)
  argtypes = map(typeof, args)
  rt = Base.return_types(f, (Mu.DirtyOmega,argtypes...))
  @pre length(rt) == 1 "Could not infer unique return type"
  rt[1]
end

"Construct an i.i.d. of `X`"
iid(f; T=infer_elemtype(f)) = RandVar{T}(f)

# iid(f, args...; T=infer_elemtype(f, args...)) = RandVar{T}(ω -> f(ω, args...))

"iid with arguments"
iid(f, args...; T=infer_elemtype(f, args...)) = RandVar{T, true}(f, args)

## Printing
## ========
name(x) = x
name(rv::RandVar) = string(rv.f)
Base.show(io::IO, rv::RandVar{T}) where T=
  print(io, "$(name(rv))($(join(map(name, rv.args), ", ")))::$T")
