# Stopgaps, should have proper treatment later
Random.randn(ω::Ω, ::Type{Float64} = Float64) = normal(ω, 0, 1)
Random.randexp(ω::Ω, ::Type{Float64} = Float64) = exponential(ω, 1)