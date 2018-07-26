# __precompile__()
"A Causal, Hihger-Order Probabilistic Programming Langauge"
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
import Cassette
using Cassette: @context

UTuple{T} = Tuple{Vararg{T, N}} where N

# Util
include("util/misc.jl")

# Core
include("omega/omega.jl")         # Sample Space
include("omega/proj.jl")          # Sample Space Projection
include("omega/tagged.jl")        # Space space tagged with metadata

## Different Types of Omega
# include("omega/nested.jl")        # Sample Space
include("omega/simple.jl")        # Sample Space
include("omega/countvec.jl")      # Sample Space
# include("omega/dirtyomega.jl")    # Sample Space
include("omega/id.jl")            # Pairing functions for omega ids
include("omega/diffomega.jl")     # Differentiable Omega

# RandVar
include("randvar/randvar.jl")             # Random Variables
include("randvar/randvarapply.jl")        # Random Variables

# Higher Order Inferene
include("higher/rcd.jl")          # Random Conditional Distribution
include("higher/rid.jl")          # Random Interventional Distribution

# Lifted random variable operatiosn
include("lift/array.jl")          # Array primitives
include("lift/lift.jl")           # Lifting functions to RandVar domain
include("lift/pointwise.jl")      # Lifting functions to RandVar domain (using Casette)

# Conditioning
include("cond.jl")                # Conditional Random Variables

# Soft Inference
include("soft/kernels.jl")        # Kernels
include("soft/soft.jl")           # Soft logic
include("soft/softapply.jl")      # Soft Interpretation
include("soft/trackerror.jl")     # Tracking error

# Inference Algorithms
include("inference/common.jl")    # Algorithm abstract type, Common Inference Functions
include("inference/callbacks.jl") # Common Inference Functions
include("inference/rand.jl")      # Sampling
include("inference/rs.jl")        # Rejection Sampling
include("inference/mi.jl")        # Metropolized Independent Sampling
include("inference/ssmh.jl")      # Single Site Metropolis Hastings
include("inference/hmc.jl")       # Hamiltonian Monte Carlo
include("inference/hmcfast.jl")   # Faster Hamiltonian Monte Carlo
include("inference/sghmc.jl")     # Stochastic Gradient Hamiltonian Monte Carlo

# Causal Inference
include("replace.jl")                  # Causal Reasoning

# Gradient
include("gradient.jl")

# Library
include("library/distributions.jl")  # Primitive distributions
include("library/statistics.jl")     # Mean, etc

# Neural Network Stuff
include("flux.jl")

export mean,
       prob,
       rcd,
       ∥,
       softeq,
       ≊,
       ⪆,
       ⪅,
       randarray,
       @lift,
       lift,
       @id,
       ciid,
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

       # Causal
       repl,
       ←,

       # Algorithms
       RejectionSample,
       MI,
       SSMH,
       HMC,
       SGHMC,
       HMCFAST,


       # Pointwise
       pw,

       # Omegas
       Ω,
       SimpleΩ,

       throttle,
       plotrv,
       default_cbs,

       withkernel,

       # Soft
       softapply,

       # Gradient
       gradient,

       # Misc
       ntranspose,

       Outside,

       MaybeRV,

       cond

end
