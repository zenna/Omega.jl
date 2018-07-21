# __precompile__()
"A Hihger-Order Probabilistic Programming Langauge"
module Omega

using Flux
using Distributions
using PDMats
using ProgressMeter
using Spec
import Random
import Statistics
using Random: AbstractRNG
using ZenUtils
using UnicodePlots
using Cassette
using Cassette: @overdub, @primitive, @context

UTuple{T} = Tuple{Vararg{T, N}} where N

# Util
include("util/misc.jl")

# Core
include("omega/omega.jl")         # Sample Space
include("omega/proj.jl")          # Sample Space
include("randvar.jl")             # Random Variables

## Different Types of Omega
# include("omega/nested.jl")        # Sample Space
include("omega/simple.jl")        # Sample Space
include("omega/countvec.jl")      # Sample Space
# include("omega/dirtyomega.jl")    # Sample Space
include("omega/id.jl")            # Pairing functions for omega ids
include("omega/diffomega.jl")     # Differentiable Omega

include("randvarapply.jl")    # Random Variables

# Higher Order Inferene
include("higher/rcd.jl")       # Random Conditional Distribution
include("higher/rid.jl")       # Random Interventional Distribution

# Lifted random variable operatiosn
include("lift/array.jl")     # Array primitives
include("lift/lift.jl")      # Lifting functions to RandVar domain
include("lift/pointwise.jl") # Lifting functions to RandVar domain (using Casette)

# Inference
include("soft.jl")      # Soft logic
include("cond.jl")      # Conditional Random Variables

# Inference Algorithms
include("inference/common.jl")  # Algorithm abstract type, Common Inference Functions
include("inference/callbacks.jl")  # Common Inference Functions
include("inference/rand.jl")    # Sampling
include("inference/rs.jl")      # Rejection Sampling
include("inference/mi.jl")      # Metropolized Independent Sampling
include("inference/ssmh.jl")    # Single Site Metropolis Hastings
include("inference/hmc.jl")     # Hamiltonian Monte Carlo
include("inference/hmcfast.jl") # Faster Hamiltonian Monte Carlo
include("inference/sghmc.jl")   # Stochastic Gradient Hamiltonian Monte Carlo

# Causal Inference
include("do.jl")        # Causal Reasoning

# Gradient
include("gradient.jl")

# Library
include("library/distributions.jl")  # Primitive distributions
include("library/statistics.jl")     # Mean, etc

# Neural Network Stuff
include("flux.jl")

include("wow.jl")

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
       bernoulli,
       boolbernoulli,
       betarv,
       β,
       categorical,
       dirichlet,
       exponential,
       gammarv,
       Γ,
       inversegamma,
       kumaraswamy,
       logistic,
       poisson,
       normal,
       mvnormal,
       uniform,
       rademacher,

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

       withkernel,

       # Gradient
       gradient,

       # Misc
       ntranspose,

       Outside,

       # Divergences
    #    KLdivergence,

       MaybeRV,

       Ω
end
