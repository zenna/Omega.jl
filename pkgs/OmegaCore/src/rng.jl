module RNG

import ..Tagging: hastag, tag
using Random: AbstractRNG

export tagrng, rng

rng(t) = t.tags.rng
hasrng(ω) = hastag(ω, Val{:rng})
tagrng(ω, rng::AbstractRNG) = tag(ω, (rng = rng,))

end