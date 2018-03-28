abstract type AbstractRandVar{T} end

struct RandVar{T, Prim} <: AbstractRandVar{T}
  f::Function
  args::Tuple
end

apl(x, ω::Omega) = x
apl(x::AbstractRandVar, ω::Omega) = x(ω)

## FIXME: Type instability
function (rv::RandVar{T, true})(ω::Omega) where T
  args = (apl(a, ω) for a in rv.args)
  (rv.f)(args..., ω)
end

function (rv::RandVar{T, false})(ω::Omega) where T
  args = (apl(a, ω) for a in rv.args)
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