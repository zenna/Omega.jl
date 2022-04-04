struct IntSeq{T}
  bits::T
end

singleton(::Type{IntSeq{T}}, i) where {T} = ..
@post singleton(ret, ::Type{T}, i) = length(ret) == 1 && first(ret) == i

# @inline combine(a::Vector{T}, b::Vector{T}) where T = 
@inline append(a::IntSeq{T}, b::IntSeq{T}) where T = vcat(a, b)
@inline append(a::Vector{T}, b::T) where T = vcat(a, T[b])
@inline singletonid(::Type{Vector{T}}, i::Vararg{T, N}) where {T, N} = T[i...]
