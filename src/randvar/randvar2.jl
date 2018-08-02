"Random Variable: a function `Ω -> T`"
abstract type AbstractRandVar{T} end  # FIXME : Rename to RandVar

"Distribution Family"
abstract type Dist end

"Unknown distribution"
abstract type Unknown <: Dist end

"Random Variable ω -> f(ω, args...)"
struct RandVar{T, D <: Dist, F, TPL <: Tuple} <: AbstractRandVar{T}
  f::F
  args::TPL # Arguments
  id::Int
end

"Parameters of the Random Variable"
params(x::RandVar) = (x.args)

"Function of the Random Variable"
func(x::RandVar) = x.f

function RandVar{T, D}(f::F, args::TPL = (), id = uid()) where {T, D, F, TPL <: Tuple}
  # @assert false
  RandVar{T, D, typeof(pointwise), TPL}(pointwise(f), (f, args...), id)
end

function RandVar{T}(f::F, args::TPL = (), id = uid()) where {T, F, TPL <: Tuple}
  RandVar{T, Unknown, typeof(pointwise), TPL}(pointwise, (f, args...), id)
end

@inline pointwise(f) = (ω, args...) -> pointwise(ω, f, args...)
@inline pointwise(ω::ΩWOW, f, args...) = f(map(a->apl(a, ω), args)...)
@inline pointwise(ω::ΩWOW, f) = f(ω)

function pointwisenoresolve(f, ω::ΩWOW, args...)
  f(applymany(args))
end

"Construct `RandVar{TNEW}` from `RandVar{TOLD}`, useful when `TNEW` is poorly inferred."
function newtype(x::RandVar{TOLD}, ::Type{TNEW}) where {TOLD, TNEW}
  RandVar{TNEW}()
end
