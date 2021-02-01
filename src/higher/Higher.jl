module Higher

using ..Omega: RandVar, ciid, randtuple, cond, ==ᵣ, ==ₛ
using DocStringExtensions

using ..Space: transfertags

"A `RandVar` whose input inherits the tags the tags of ω"
inherittags(rv::RandVar, ω) = ciid(ω_ -> rv(transfertags(ω_, ω)))

include("rcd.jl")          # Random Conditional Distribution
include("rid.jl")          # Random Interventional Distribution

export rid, rcd, ∥, ∥ₛ

end