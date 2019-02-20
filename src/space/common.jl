"Return type from `rand(ω, args...)`.  Used for type stability."
function randrtype end

randrtype(ω, ::Type{T}) where T = T
randrtype(ω, ::UnitRange{T}) where T = T
randrtype(ω, ::Array{T}) where T = T