"Casstte Poweded AddOns to Omega"
module OmegaRemix

import Cassette
using Cassette: @context
import Omega: RandVar

include("pointwise.jl")
include("replace.jl")
include("soft.jl")
include("softapply.jl")

export softapply

end # module
