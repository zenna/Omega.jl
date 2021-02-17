module Var

using Random: AbstractRNG
using ..Basis

"""
`recurse(f, ω)`
Recursively apply contextual execution to internals of `f`"""
function recurse end

include("variable.jl")          # Random / Parametric Variables
include("member.jl")            # Families
include("primparam.jl")         # Primitive Parameters
include("distributions.jl")     # Primitive Distributions
include("multivariate.jl")      # Multivariate Distributions
include("constant.jl")          # Constant distribution 
include("pointwise.jl")         # Point wise variable application
include("dispatch.jl")          # Contextual application


end
