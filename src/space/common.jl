"Return type from `rand(ω, args...)`.  Used for type stability."
function randrtype end

randrtype(ω, ::Type{T}) where T = T
randrtype(ω, ::UnitRange{T}) where T = T
randrtype(ω, ::Array{T}) where T = T

# memrand(ω::ΩBase, id, ::Type{X}, dims::Integer...; rng) where X =
#   memrand(ω, id, X, Dims(dims); rng = rng)

# e.g. rand(1,2,3) 
memrand(ω::ΩBase, id, ::Type{X}, d::Integer, dims::Integer...; rng) where X =
  memrand(ω, id, X, Dims((d, dims...)); rng = rng)

# rand(X), not sure the point of this?
# memrand(ω::ΩBase, id, ::Type{X}; rng) where X = memrand(ω, id, X; rng = rng)

# rand(), not sure the point of this?
memrand(ω::ΩBase, id, X; rng) = memrand(ω, id, X; rng = rng)

# e.g. rand() (forgot type)
memrand(ω::ΩBase, id; rng) = memrand(ω, id, Float64; rng = rng)

# e.g. rand((1,2,3)) (forget type)
memrand(ω::ΩBase, id, dims::Dims; rng) = memrand(ω, id, Float64, dims; rng = rng)


# Different forms of rand use 
# rand(1:10)
# rand(Bool)
# rand([1,2,3])
# rand(Float64)
# rand(Int, 10)
# rand(Int, (10, 20))
# rand(rng, Int, (10, 20))

# Linear Omega should need to implement
# memrand(ω, id, X; rng)
# memrand(ω, id, X, dims::Dims)
# memrand(ω, id, ::Type{X})
# memrand(ω, id, ::Type{X}, dims::Dims)
# memrand(ω, id, ::X)
# memrand(ω, id, ::X, dims::Dims)