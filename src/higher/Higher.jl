module Higher

using ..Omega: RandVar, ciid, randtuple, cond, ==ᵣ, ==ₛ
using DocStringExtensions

include("rcd.jl")          # Random Conditional Distribution
include("rid.jl")          # Random Interventional Distribution

export rid, rcd, ∥, ∥ₛ

end