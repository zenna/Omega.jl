# Random Variable Application
apl(x, ω::Ω) = x
apl(x::RandVar, ω::Ω) = x(ω)

Zerox{I, T, ΩT} = Union{ΩWOW, TaggedΩ{I, T, ΩT}} where {ΩT <: ΩWOW}

function (rv::RandVar)(ω::Zerox)
  (rv.f)(ω[rv.id][1], rv.args...)
end

apl(rv::RandVar, ω::Zerox) =  apl(rv, proj(ω, rv))

"Reproject back to parent random variable"
(rv::URandVar)(πω::ΩProj) = rv(parentω(πω))
(rv::Beta)(πω::ΩProj) = rv(parentω(πω))

## Tagged
(rv::RandVar)(tω::TaggedΩ{I, T, ΩT}) where {I, T, ΩT <: ΩProj}  =
  rv(TaggedΩ(parentω(tω.taggedω), tω.tags))