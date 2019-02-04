"Return type from `rand(ω, args...)`.  Used for type stability."
function randrtype end

randrtype(ω, ::Type{T}) where T = T
randrtype(ω, ::UnitRange{T}) where T = T
randrtype(ω, ::Array{T}) where T = T

# memrand(ω::ΩBase, id, ::Type{X}, dims::Integer...; rng) where X =
#   memrand(ω, id, X, Dims(dims); rng = rng)
memrand(ω::ΩBase, id, ::Type{X}, d::Integer, dims::Integer...; rng) where X =
  memrand(ω, id, X, Dims((d, dims...)); rng = rng)

memrand(ω::ΩBase, id; rng) = memrand(ω, id, Float64; rng = rng)
memrand(ω::ΩBase, id, dims::Dims; rng) = memrand(ω, id, Float64, dims; rng = rng)
