"Random Variable of Unknown distribution `ω -> f(ω[id], args...)`"
struct URandVar{F, TPL <: Tuple} <: RandVar
  f::F
  args::TPL
  id::ID
  URandVar(f::F, args::TPL = (), id = uid()) where {F, TPL} =
    new{F, TPL}(f, args, id)
end

id(rv::URandVar) = rv.id

"Parameters of the Random Variable"
params(x::URandVar) = x.args

"Function of the Random Variable"
func(x::URandVar) = x.f

"Name of a random variable"
name(rv::URandVar) = string(rv.f)

"`constant(c)` Constant random variable which always outputs `c`"
constant(c) = URandVar(ω -> c)

@inline ppapl(rv::URandVar, ωπ) =  rv.f(ωπ, rv.args...)

@inline (rv::URandVar)(ω::Ω) = apl(rv, ω)