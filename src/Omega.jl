__precompile__()
"A Library for Causal and Higher-Order Probabilistic Programming"
module Omega

using Flux
using Distributions
using PDMats
using ProgressMeter
using Spec
import Base.Random
# import Statistics
import Base.Random: AbstractRNG
using ZenUtils
using UnicodePlots
using Compat

# Util
include("util/misc.jl")
using .Misc

# Core
include("omega/idgen.jl")            # UIDs
using .IdGen
include("omega/space.jl")         # Sample Space
using .Space
include("omega/simple.jl")        # Simple Ω
using .Simple

# include("omega/dirtyomega.jl")  # Sample Space
include("omega/index.jl")         # Pairing functions for omega ids
using .Index
include("omega/proj.jl")          # Sample Space Projection
using .Proj
include("omega/tagged.jl")        # Space space Tagged with metadata

# RandVar
include("randvar/randvar.jl")             # Random variables
include("randvar/randvarapply.jl")        # Random variable application to ω::Ω

# i.i.d.
# include("iid/iid.jl")           # i.i.d. RandVars
include("iid/ciid.jl")            # Conditionally i.i.d. RandVars

# Higher-Order Inference
include("higher/rcd.jl")          # Random Conditional Distribution
include("higher/rid.jl")          # Random Interventional Distribution

# Lifted random variable operatiosn
include("lift/array.jl")          # Array primitives
include("lift/lift.jl")           # Lifting functions to RandVar domain

# Conditioning
include("cond.jl")                # Conditional random variables

# Soft Inference
include("soft/kernels.jl")        # Kernels
include("soft/soft.jl")           # Soft logic
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
include("replace.jl")             # Causal Interventions

# Gradient
include("gradient.jl")

# Library
include("library/distributions.jl")  # Primitive distributions
include("library/statistics.jl")     # Distributional properties: mean, variance, etc

# Neural Network Stuff
include("flux.jl")

export mean,
       prob,
       rcd,
       ∥,
       softeq,
       softlt,
       softgt,
       ≊,
       ⪆,
       ⪅,
       >ₛ,
       >=ₛ,
       <=ₛ,
       <ₛ,
       ==ₛ,     
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
       constant,

       # Causal
       replace,

       # Algorithms
       RejectionSample,
       MI,
       SSMH,
       HMC,
       SGHMC,
       HMCFAST,

       SoftBool,

       # Omegas
       Ω,
       SimpleΩ,

       throttle,
       plotrv,
       default_cbs,

       withkernel,

       # Soft
       indomain,

       # Gradient
       gradient,

       # Misc
       ntranspose,

       Outside,

       MaybeRV,

       # Callbacks
       everyn,
       →,
       idcb,

       cond

end
