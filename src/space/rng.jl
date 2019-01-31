tagrng(ω, rng::AbstractRNG) = tag(ω, (rng = rng,))
rng(ω::Ω) = Random.GLOBAL_RNG
rng(ω::TaggedΩ) = hastags(ω, :rng) ? ω.tags.rng : Random.GLOBAL_RNG