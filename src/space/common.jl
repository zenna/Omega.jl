# For Type Inference when V is Any
randrtype(::Type{T}) where T = T
randrtype(::Type{Float64}) = Float64
randrtype(::UnitRange{T}) where T = T
randrtype(::Array{T}) where T = T
randrtype(::Array{T}, ::Ω) where T = T