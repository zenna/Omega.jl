Random.seed!(ω::Ω, T) = Random.seed!(rng(ω), T)
Random.seed!(ω::Ω, ::Type{T}) where T = Random.seed!(rng(ω), T)