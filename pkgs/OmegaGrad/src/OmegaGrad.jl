module OmegaGrad

using Reexport

include("gradinterface.jl")

include("reversediff.jl")
@reexport using .OmegaReverseDiff

include("zygote.jl")
@reexport using .OmegaZygote

end
