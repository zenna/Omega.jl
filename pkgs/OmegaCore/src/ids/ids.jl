module IDS

export append, tupleid, base, combine, append, increment, defID, singletonid

# # IDs
# IDs are used primarily in Omega to give identities to random variables
# Conceptually, an ID is a tuple of integers, but other data structures may be used

# # Generic Interface
"`base(::Type{T}, i)` singleton (`i`,) of collection type `T` "
function base end

# "`combine(a, b)` Combine (e.g. concatenate) `a` and `b`"
# function combine end

"`append(a, b)` append `b` to the end of `a`, like `append!` but functional"
function append end

"`Increment(id::ID)` the id"
function increment end

include("tupleid.jl")
include("vectorid.jl")
include("conversions.jl")

"default ID type"
defID(args...) = VectorID

end