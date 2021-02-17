module Tagging

export tag, mergetag, hastag, HasTag, NotHasTag, traithastag, Tags

# # Tags
# Many functionalities of Omega are achieved through contextual-execution
# That means we evaluate a function `f(ω)` under some context.
# See Cassette.jl for more information on contextual execution
# Omega uses a poor-mans Cassette, which is more constrained but faster
# Tags are values which are attached to (tagged to) the execution context
# when we evaluate (random) variables.

include("tags.jl")
include("tagtraits.jl")
end