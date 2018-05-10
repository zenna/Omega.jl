__precompile__()
"Minimal Probabilistic Programming Langauge"
module Mu

using Flux
using Distributions
using PDMats
using ProgressMeter
using Spec
# using Lens

UTuple{T} = Tuple{Vararg{T, N}} where N

# Util
include("util/misc.jl")

# Core
include("omega/omega.jl")         # Sample Space
include("omega/proj.jl")          # Sample Space
include("randvar.jl")             # Random Variables

## Different Types of Omega
include("omega/nested.jl")        # Sample Space
include("omega/simple.jl")        # Sample Space
include("omega/countvec.jl")      # Sample Space
include("omega/dirtyomega.jl")    # Sample Space
include("omega/id.jl")            # Pairing functions for omega ids
include("omega/diffomega.jl")     # Differentiable Omega

include("randvarapply.jl")    # Random Variables

# Var
include("var.jl")

include("rcd.jl")       # Random Conditional Distribution
include("array.jl")     # Array primitives
include("lift.jl")      # Lifting functions to RandVar domain

# Inference
include("algorithm.jl") # Algorithm abstract type
include("soft.jl")      # Soft logic
include("cond.jl")      # Conditional Random Variables

# Inference Algorithms
include("inference/common.jl")  # Common Inference Functions
include("inference/callbacks.jl")  # Common Inference Functions
include("inference/rand.jl")    # Sampling
include("inference/rs.jl")      # Rejection Sampling
include("inference/mi.jl")      # Metropolized Independent Sampling
include("inference/ssmh.jl")    # Single Site Metropolis Hastings
include("inference/hmc.jl")     # Hamiltonian Monte Carlo
include("inference/hmcfast.jl") # Faster Hamiltonian Monte Carlo
include("inference/sghmc.jl")   # Stochastic Gradient Hamiltonian Monte Carlo

include("inference/cgan.jl")    # Conditional GAN inference
include("inference/spen.jl")    # Structured Predicton Energy Networks

# Causal Inference
include("do.jl")        # Causal Reasoning

# Gradient
include("gradient.jl")

# Library
include("distributions.jl")  # Primitive distributions
include("statistics.jl")     # Mean, etc

# Neural Network Stuff
include("flux.jl")

export mean,
       prob,
       rcd,
       ∥,
       softeq,
       ≊,
       ⪆,
       randarray,
       @lift,
       lift,
       @id,
       iid,
       kse,

       # Distributions
       gammarv,
       Γ,
       normal,
       mvnormal,
       uniform,
       inversegamma,
       dirichlet,
       betarv,
       bernoulli,
       rademacher,
       poisson,
       logistic,
       exponential,
       kumaraswamy,
       boolbernoulli,

       # Do
       intervene,

       # Algorithms
       RejectionSample,
       MI,
       SSMH,
       HMC,
       SGHMC,
       HMCFAST,

       # Omegas
       Omega,
       SimpleOmega,

       throttle,
       plotrv,
       default_cbs,

       # Gradient
       gradient
end
