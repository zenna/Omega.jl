"Casstte Poweded AddOns to Omega"
module OmegaRemix

import Cassette
using Cassette: @context

include("pointwise.jl")
include("replace.jl")
include("soft.jl")
include("softapply.jl")

end # module
