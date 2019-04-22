"`base(::Type{T}, i)` singleton (`i`,) of collection type `T` "
function base end

# Fast construction, append a new element, hash
# dont need random access, delete arbitrary element

"Id of Random Variable"
function randvarid end

# Vector Indices #
# zt: rename combine -> cat or concat, append -> push, base -> singleton
@inline combine(a::Vector{T}, b::Vector{T}) where T = vcat(a, b)
@inline append(a::Vector{T}, b::T) where T = vcat(a, T[b])
@inline base(::Type{Vector{T}}, i::Vararg{T, N}) where {T, N} = Int[i...]
function increment(a::Vector{Int})
  b = copy(a)
  b[end] += 1
  b
end
randvarid(a::Vector) = first(a)


# Linked List #
@inline combine(a::LinkedList, b::LinkedList) = cat(a, b)
@inline append(a::LinkedList, b)  = cons(b, a)
@inline base(::Type{<:LinkedList}, i::Vararg{T, N}) where {T, N} = list(i...)
@inline increment(a::LinkedList) =  cons(head(a) + 1, tail(a))

# Tuple #
# @inline combine(x) = x
# @inline tuplejoin(x, y) = (x..., y...)
# @inline tuplejoin(x, y, z...) = (x..., tuplejoin(y, z...)...)
# @inline append(a::Tuple, b) = (a..., b)
# @inlne base(::Type{<:Tuple}, i::Vararg{T, N}) where {T, N} = i
# # @inline increment(a::Tuple) = (rest(a)..., first(a) + 1)
# @generated function rest(x::NTuple{N, Int}) where N
#   # :($([x[i] for i = 1:N-1])...)
#   Expr(:tuple, [Expr(:ref, :x, i) for i = 1:N-1]...)
# end


# Pairing Indices #
const Paired = Int

"Cantor Pairing Function"
@inline pair(k1, k2) = div((k1 + k2)*(k1 + k2 + 1), 2) + k2
@inline pair(k1) = k1

@inline combine(a::Paired, b::Paired) = pair(a, b)
@inline base(::Type{Paired}, i::Int) = i