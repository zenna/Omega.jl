module Var

using Random: AbstractRNG
using ..Basis

"""
`recurse(f, ω)`
Recursively apply contextual execution to internals of `f`"""
function recurse end

include("variable.jl")          # Random / Parametric Variables
include("multivariate.jl")      # Multivariate Distributions
include("member.jl")            # Families
include("iid.jl")               # Independence
include("primparam.jl")         # Primitive Parameters
include("primdist.jl")          # Primitive Distributions
include("constant.jl")          # Constant distribution 
include("pointwise.jl")         # Point wise variable application
include("dispatch.jl")          # Contextual application

end
