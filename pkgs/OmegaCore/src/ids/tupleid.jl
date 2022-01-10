# # Tuple id type
const TupleID = NTuple{N, Int} where N

singletonid(::TupleID, i::Int) = (i,)
@inline append(a::Tuple, b::Tuple) = (a..., b...)
