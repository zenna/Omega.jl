"Split a subspace into two"
split(ss::UInt64) = hash((ss, 0)), hash((ss, 1))