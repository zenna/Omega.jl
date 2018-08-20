module Higher

using ..Omega: RandVar, ciid

include("rcd.jl")          # Random Conditional Distribution
include("rid.jl")          # Random Interventional Distribution

export rid, rcd, ∥

end