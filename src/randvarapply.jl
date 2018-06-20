
# TODO: Put this somewhere better
apl(x, ω::Ω) = x
apl(x::AbstractRandVar, ω::Ω) = x(ω)

(rv::RandVar)(πω::ΩProj) = rv(πω.ω)

"X((w1, w2,...,)"
(rv::NTuple{N, RandVar})(ω::Ω) where N = applymany(rv, ω)
