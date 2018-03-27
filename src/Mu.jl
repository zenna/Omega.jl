"Minimal Probabilistic Programming Langauge"
module Mu

using Distributions

# TODO

include("algorithm.jl")  # Algorithm
include("omega.jl")   # Sample Space
include("randvar.jl") # Random Variables
include("soft.jl")    # Soft logic
include("cond.jl")    # Conditional Random Variables
include("rand.jl")    # Sampling
include("distributions.jl")    # Sampling
include("moments.jl") # Mean, etc
include("interval.jl")    # Sampling
include("do.jl")    # Sampling
# include("lift.jl")

export mean,
       Interval,
       curry,
       softeq,
       ≊,
       ⪆,

       # Distributions
       gammarv,
       Γ,
       normal,
       uniform,
       inversegamma,
       dirichlet,

       # Do
       intervene,

       # Algorithms
       MH,
       RejectionSample
end