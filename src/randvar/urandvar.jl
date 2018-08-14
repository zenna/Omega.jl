"Random Variable of Unknown distribution `ω -> f(ω[id], args...)`"
struct URandVar{T, F, TPL <: Tuple} <: RandVar{T}
  f::F
  args::TPL
  id::ID
  URandVar{T}(f::F, args::TPL = (), id = uid()) where {T, F, TPL} =
    new{T, F, TPL}(f, args, id)
end

"Parameters of the Random Variable"
params(x::URandVar) = x.args

"Function of the Random Variable"
func(x::URandVar) = x.f

"Name of a random variable"
name(rv::URandVar) = string(rv.f)

@inline fapl(rv::URandVar, ωπ) =  rv.f(ωπ, rv.args...)

@inline (rv::URandVar)(ω::Ω) = apl(rv, ω)