"Minimal Probabilistic Programming Langauge"
__precompile__()
module Mu

using Distributions
using ProgressMeter

# Util
include("util/misc.jl")

# Core
include("omega.jl")     # Sample Space
include("randvar.jl")   # Random Variables
include("curry.jl")   # Random Variables
include("array.jl")     # Lifting functions to RandVar domain
include("lift.jl")      # Lifting functions to RandVar domain
include("lazyid.jl")      # Lifting functions to RandVar domain


# Inference
include("algorithm.jl") # Algorithm
include("soft.jl")      # Soft logic
include("cond.jl")      # Conditional Random Variables
include("rand.jl")      # Sampling

# Causal Inference
include("do.jl")        # Causal Reasoning

# Library
include("distributions.jl")    # Sampling
include("statistics.jl")   # Mean, etc

export mean,
       Interval,
       curry,
       softeq,
       ≊,
       ⪆,
       randarray,
       @lift,

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
       SSMH,
       RejectionSample
end
