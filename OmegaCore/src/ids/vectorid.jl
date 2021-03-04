
# const ID = Int
const VectorID = Vector{Int64}

@inline base(::Type{Vector{T}}) where T = T[]

# @inline combine(a::Vector{T}, b::Vector{T}) where T = 
@inline append(a::Vector{T}, b::Vector{T}) where T = vcat(a, b)
@inline append(a::Vector{T}, b::T) where T = vcat(a, T[b])
@inline singletonid(::Type{Vector{T}}, i::Vararg{T, N}) where {T, N} = T[i...]

# @inline firstelem(::Vector{T}) where T = zero(T)
# function increment(a::Vector)
#   b = copy(a)
#   b[end] += 1
#   b
# end`