"Minimal Probabilistic Programming Langauge"
__precompile__()
module Mu

using Distributions

include("algorithm.jl") # Algorithm
include("omega.jl")     # Sample Space
include("randvar.jl")   # Random Variables
include("soft.jl")      # Soft logic
include("cond.jl")      # Conditional Random Variables
include("rand.jl")      # Sampling
include("distributions.jl")    # Sampling
include("lift.jl")      # Lifting functions to RandVar domain
include("array.jl")     # Lifting functions to RandVar domain

include("moments.jl")   # Mean, etc
include("interval.jl")  # Sampling
include("do.jl")        # Causal Reasoning

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
       beta,
       bernoulli,

       # Do
       intervene,

       # Algorithms
       MH,
       RejectionSample
end