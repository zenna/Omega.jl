module Var

using Random: AbstractRNG
using ..Basis

"""
`recurse(f, ω)`
Recursively apply contextual execution to internals of `f`"""
function recurse end

include("variable.jl")          # Random / Parametric Variables
include("multivariate.jl")      # Multivariate Distributions
# include("typevar.jl")           # Type Variables
include("member.jl")            # Families
include("primparam.jl")         # Primitive Parameters
include("primdist.jl")          # Primitive Distributions
include("pointwise.jl")         # Point wise variable application
include("dispatch.jl")          # Contextual application

end
