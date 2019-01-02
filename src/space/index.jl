## Vector Indices
## ==============

@inline combine(a::Vector{Int}, b::Vector{Int}) = vcat(a, b)
@inline append(a::Vector{Int}, b::Int) = vcat(a, Int[b])
@inline base(::Type{Vector{Int}}, i::Int) = Int[i]

increment!(a::Vector{Int}) = a[end] += 1
function increment(a::Vector{Int})
  b = copy(a)
  b[end] += 1
  b
end

## Linked List
## ===========



# struct LinkedList{T, TT <: L}
#   head::T
#   tail::

# end

# import DataStructures: nil, cons, LinkedList
# @inline append(a::LinkedList, b::Int) = cons(b, a)
# @inline base(::Type{LinkedList}, i) = cons(i, nil())


## Pairing Indices
## ===============
const Paired = Int

"Cantor Pairing Function"
@inline pair(k1, k2) = div((k1 + k2)*(k1 + k2 + 1), 2) + k2
@inline pair(k1) = k1

@inline combine(a::Paired, b::Paired) = pair(a, b)
@inline base(::Type{Paired}, i::Int) = i