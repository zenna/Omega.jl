abstract type AbstractRandVar{T} end

struct RandVar{T, Prim, F, TPL} <: AbstractRandVar{T}
  f::F
  args::TPL
end

function RandVar{T, Prim}(f::F, args::TPL) where {T, Prim,  F, TPL}
  RandVar{T, Prim, F, TPL}(f, args)
end

apl(x, ω::Omega) = x
apl(x::AbstractRandVar, ω::Omega) = x(ω)

## FIXME: Type instability
function (rv::RandVar{T, true})(ω::Omega) where T
  args = map(a->apl(a, ω), rv.args)
  (rv.f)(args..., ω)
end

function (rv::RandVar{T, false})(ω::Omega) where T
  args = map(a->apl(a, ω), rv.args)
  (rv.f)(args...)
end

function Base.copy(x::RandVar{T}) where T
  RandVar{T}(x.f, x.ωids)
end

"All dimensions of `ω` that `x` draws from"
ωids(x::RandVar) = x.ωids
ωids(x) = Set{Int}() # Non RandVars defaut to emptyset (convenience)

"Constant randvar `ω -> x`"
constant(x::T) where T = RandVar{T}(identity, (x,))

name(x) = x
name(rv::RandVar) = string(rv.f)
Base.show(io::IO, rv::RandVar{T}) where T=
  print(io, "$(name(rv))($(join(map(name, rv.args), ", ")))::$T")