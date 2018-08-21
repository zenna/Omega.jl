# __precompile__(false)
"A Library for Causal and Higher-Order Probabilistic Programming"
module Omega

using Flux
using PDMats
using Spec
using ZenUtils
using UnicodePlots
using Compat

import Random
import Random: GLOBAL_RNG, AbstractRNG
import Statistics: mean, var, quantile

# Util
include("util/misc.jl")
using .Misc
include("specs.jl")
include("tags.jl")                # Tags

# Core
include("omega/idgen.jl")         # UIDs
using .IdGen
include("omega/space.jl")         # Sample Space
using .Space
include("omega/index.jl")         # Pairing functions for omega ids
using .Index
include("omega/proj.jl")          # Sample Space Projection
using .Proj
include("omega/tagged.jl")        # Space space Tagged with metadata
include("omega/simple.jl")        # Simple Ω

# RandVar
include("randvar/randvar.jl" )            # Random variables
include("randvar/urandvar.jl")            # Random variables
include("randvar/randvarapply.jl")        # Random variable application to ω::Ω

# i.i.d.
# include("iid/iid.jl")           # i.i.d. RandVars
include("iid/ciid.jl")            # Conditionally i.i.d. RandVars

# Higher-Order Inference
include("higher/Higher.jl")
using .Higher

# Lifted random variable operatiosn
include("lift/containers.jl")     # Array/Tuple primitives
include("lift/lift.jl")           # Lifting functions to RandVar domain

# Conditioning
include("cond.jl")                # Conditional random variables

# Soft Inference
include("soft/kernels.jl")        # Kernels
include("soft/soft.jl")           # Soft logic
include("soft/trackerror.jl")     # Tracking error

# Gradient
include("gradient.jl")

# Inference Algorithms
include("inference/Inference.jl")    # Algorithm abstract type, Common Inference Functions
using .Inference

# Causal Inference
include("causal/Causal.jl")          # Causal Interventions
using .Causal

# Library
include("primitive/Prim.jl")
using .Prim

# Neural Network Stuff
include("flux.jl")

export mean,
       prob,
       rcd,
       rid,
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

       # Kernels
       kse,
       kseα,
       kf1,
       kf1β,

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

       RejectionSampleAlg,
       MIAlg,
       SSMHAlg,
       HMCAlg,
       SGHMCAlg,
       HMCFASTAlg,

       defalg,
       defcb,
       defΩ,
       defΩProj,

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

       isconstant,
       # Callbacks
       everyn,
       →,
       idcb,

       cond,

       isapproximate

end
