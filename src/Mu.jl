"Minimal Probabilistic Programming Langauge"
module Mu

using Distributions

include("algorithm.jl")  # Algorithm
include("soft.jl")    # Soft logic
include("omega.jl")   # Sample Space
include("randvar.jl") # Random Variables
include("cond.jl")    # Conditional Random Variables
include("rand.jl")    # Sampling

include("moments.jl") # Mean, etc

# include("lift.jl")

export mean,
       normal,
       uniform,
       Interval,
       curry,
       softeq
end