"Minimal Probabilistic Programming Langauge"
module Mu

using Distributions

include("soft.jl")    # Soft logic
include("omega.jl")   # Sample Space
include("randvar.jl") # Random Variables
include("cond.jl")    # Conditional Random Variables
include("rand.jl")    # Sampling

# include("lift.jl")

export expectation,
       normal,
       uniform,
       Interval,
       curry,
       softeq
end