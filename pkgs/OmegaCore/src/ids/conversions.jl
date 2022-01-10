export convertid

"convid(::Type{T}, id) convert `id` into type `T`"
function convertid end

convertid(::Type{T}, id::T) where {T} = id
convertid(::Type{VectorID}, (i1,)::TupleID{1}) = Int[i1]
convertid(::Type{VectorID}, (i1, i2)::TupleID{2}) = Int[i1, i2]
convertid(::Type{VectorID}, (i1, i2, i3)::TupleID{3}) = Int[i1, i2, i3]
convertid(::Type{VectorID}, (i1, i2, i3, i4)::TupleID{4}) = Int[i1, i2, i3, i4]
convertid(::Type{VectorID}, (i1, i2, i3, i4, i5)::TupleID{5}) = Int[i1, i2, i3, i4, i5]
convertid(::Type{VectorID}, id::TupleID) = Int[id...]
convertid(::Type{VectorID}, ci::CartesianIndex{1}) = Int[ci.I[1]]
convertid(::Type{VectorID}, ci::CartesianIndex{2}) = Int[ci.I[1], ci.I[2]]
convertid(::Type{VectorID}, ci::CartesianIndex{3}) = Int[ci.I[1], ci.I[2], ci.I[3]]



append(x::X, y) where X = append(x, convertid(X, y))