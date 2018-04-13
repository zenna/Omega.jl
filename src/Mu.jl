__precompile__()
"Minimal Probabilistic Programming Langauge"
module Mu

using Distributions
using ProgressMeter
using Spec

# Util
include("util/misc.jl")

# Core
include("omega/omega.jl") # Sample Space
include("omega/dirtyomega.jl") # Sample Space
include("omega/pairomega.jl")  # Pairing functions for omega ids
include("omega/diffomega.jl")  # Differentiable Omega

include("randvar.jl")    # Random Variables
include("randcond.jl")  # Random Conditional Distributi
include("array.jl")     # Array primitives
include("lift.jl")      # Lifting functions to RandVar domain

# Inference
include("algorithm.jl") # Algorithm abstract type
include("soft.jl")      # Soft logic
include("cond.jl")      # Conditional Random Variables

# Inference Algorithms
include("inference/rand.jl")      # Sampling
include("inference/rs.jl")       # Metropolized Independent Sampling
include("inference/mi.jl")       # Metropolized Independent Sampling
include("inference/ssmh.jl")      # Single Site Metropolis Hastings
include("inference/cgan.jl")      # Conditional GAN inference
include("inference/spen.jl")      # Structured Predicton Energy Networks

# Causal Inference
include("do.jl")        # Causal Reasoning

# Gradient
include("gradient.jl")

# Library
include("distributions.jl")  # Sampling
include("statistics.jl")     # Mean, etc

export mean,
       randcond,
       softeq,
       ≊,
       ⪆,
       randarray,
       @lift,
       @id,
       iid,

       # Distributions
       gammarv,
       Γ,
       normal,
       uniform,
       inversegamma,
       dirichlet,
       betarv,
       bernoulli,

       # Do
       intervene,

       # Algorithms
       MI,
       SSMH,
       RejectionSample
end
