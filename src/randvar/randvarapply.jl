apl(x, ω::Ω) = x
apl(x::AbstractRandVar, ω::Ω) = x(ω)

## Random Variable Application
## ===========================

Zerox{I, T, ΩT} = Union{ΩWOW, TaggedΩ{I, T, ΩT}} where {ΩT <: ΩWOW}

function g(rv::RandVar{T, true}, ω::Zerox) where T
  @assert false
end

function (rv::RandVar{T, true})(ω::Zerox) where T
  # @assert false
  args = map(a->apl(a, ω), rv.args)
  (rv.f)(ω[rv.id][1], args...)
end

function (rv::RandVar{T, false})(ω::Ω) where T
  args = map(a->apl(a, ω), rv.args)
  (rv.f)(args...)
end

"Reproject back to parent random variable"
(rv::RandVar)(πω::ΩProj) = rv(parentω(πω))
(rv::RandVar{T, false})(πω::ΩProj) where T = rv(parentω(πω))
(rv::RandVar{T, true})(πω::ΩProj) where T = rv(parentω(πω))

## Tagged

(rv::RandVar)(tω::TaggedΩ{I, T, ΩT}) where {I, T, ΩT <: ΩProj}  =  rv(TaggedΩ(parentω(tω.taggedω), tω.tags))

(rv::RandVar{R, false})(tω::TaggedΩ{I, T, ΩT}) where {R, I, T, ΩT <: ΩProj}  =  rv(TaggedΩ(parentω(tω.taggedω), tω.tags))
(rv::RandVar{R, true})(tω::TaggedΩ{I, T, ΩT}) where {R, I, T, ΩT <: ΩProj}  =  rv(TaggedΩ(parentω(tω.taggedω), tω.tags))

"X((w1, w2,...,)"
(rv::NTuple{N, RandVar})(ω::Ω) where N = applymany(rv, ω)