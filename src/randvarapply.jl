
# TODO: Put this somewhere better
apl(x, ω::Omega) = x
apl(x::AbstractRandVar, ω::Omega) = x(ω)

(rv::RandVar)(πω::OmegaProj) = rv(πω.ω)

"X((w1, w2,...,)"
(rv::NTuple{N, RandVar})(ω::Omega) where N = applymany(rv, ω)
