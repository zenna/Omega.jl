module OmegaMH

using InferenceBase
# using TransformVariables

include("mhcore.jl")
# include("proposals.jl")
include("ssproposal.jl")
include("interface.jl")

end