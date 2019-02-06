"`base(::Type{T}, i)` singleton (`i`,) of collection type `T` "
function base end

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

# Linked List #
@inline base(::Type{LinkedList}, i...) = list(i...)
@inline append(a::LinkedList, b)  = cons(b, a)
@inline increment(a::LinkedList) =  cons(head(a) + 1, tail(a))
@inline combine(a::LinkedList, b::LinkedList) = cat(a, b)

# Pairing Indices #
const Paired = Int

"Cantor Pairing Function"
@inline pair(k1, k2) = div((k1 + k2)*(k1 + k2 + 1), 2) + k2
@inline pair(k1) = k1

@inline combine(a::Paired, b::Paired) = pair(a, b)
@inline base(::Type{Paired}, i::Int) = i