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
include("util/Util.jl")
using .Util
export ntranspose

# Core
include("space/Space.jl")         # UIDs
using .Space
export Ω, uid, @id

# RandVar
include("randvar/randvar.jl" )            # Random variables
include("randvar/urandvar.jl")            # Random variables
include("randvar/randvarapply.jl")        # Random variable application to ω::Ω
include("randvar/ciid.jl")                # Conditionally i.i.d. RandVars

# Conditioning
include("cond.jl")                # Conditioning

# Higher-Order Inference
include("higher/Higher.jl")
using .Higher

# Lifted random variable operatiosn
include("lift/containers.jl")     # Array/Tuple primitives
include("lift/lift.jl")           # Lifting functions to RandVar domain

# Soft Inference
include("soft/kernels.jl")        # Kernels
include("soft/soft.jl")           # Soft logic
include("soft/trackerror.jl")     # Tracking error
export  softeq,
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

        # Kernels
        kse,
        kseα,
        kf1,
        kf1β

# Gradient
include("gradient.jl")

# Inference Algorithms
include("inference/Inference.jl")
using .Inference
export  RejectionSample,
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
        defΩProj

# Causal Inference
include("causal/Causal.jl")
using .Causal
export replace

# Library
include("primitive/Prim.jl")
using .Prim
export bernoulli,
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
       constant

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

       # Util
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
