"A Expressive Library for Probabilistic Programming"
module Omega

import ForwardDiff, Flux
# Zygote,
using Spec
using UnicodePlots
using DocStringExtensions: FIELDS, SIGNATURES, TYPEDEF
using Cassette
using Lens

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
export Ω, uid, @id, SimpleΩ, LinearΩ

# RandVar
include("randvar/randvar.jl" )            # Random variables
include("randvar/urandvar.jl")            # Random variables
include("randvar/randvarapply.jl")        # Random variable application to ω::Ω
include("randvar/ciid.jl")                # Conditionally i.i.d. RandVars
include("randvar/elemtype.jl")            # Infer Element Type
export RandVar, MaybeRV, ciid, isconstant, elemtype, params, constant

# Conditioning
include("cond.jl")                # Conditioning
export cond

# Lifted random variable operatiosn

include("lift/r.jl")
export ᵣ
include("lift/containers.jl")     # Array/Tuple primitives
export randarray, randtuple, ==ᵣ, tupleᵣ, arrayᵣ

# Lifting functions to RandVar domain
include("lift/lift.jl")           
export @lift, lift


# Soft Inference
include("soft/soft.jl")           # Soft Booleans / logic
using .Soft

export  d,
        SoftBool,
        softeq,
        softlt,
        softgt,
        >ₛ,
        >=ₛ,
        <=ₛ,
        <ₛ,
        ==ₛ,
        err,
        logerr,
        anyₛ,
        allₛ,

        # Kernels
        kse,
        kseα,
        kf1,
        kf1β,
        withkernel,
        atα,
        @atα,

        indomainₛ,
        applynotrackerr,
        applytrackerr

# Soft.logerr(x::RandVar) = 3
import .Soft: logerr, softeq, softgt, softlt, err, kf1β, kseα

Omega.lift(:softeq, 2)
Omega.lift(:softeq, 3)
Omega.lift(:softgt, 2)
Omega.lift(:softlt, 2)
Omega.lift(:logerr, 1)
Omega.lift(:err, 1)
Omega.lift(:kf1β, 1)
Omega.lift(:kseα, 1)

# Higher-Order Inference
include("higher/Higher.jl")
using .Higher
export rcd, rid, ∥, ∥ₛ

# Gradient
include("gradient.jl")
export gradient

# Inference Algorithms
include("inference/Inference.jl")
using .Inference
export  isapproximate,

        RejectionSample,
        SSMH,
        # SGHMC,
        HMCFAST,
        Relandscape,
        Replica,

        RejectionSampleAlg,
        SSMHAlg,
        HMCAlg,
        # SGHMCAlg,
        HMCFASTAlg,
        RelandscapeAlg,
        ReplicaAlg,
        NUTS,
        NUTSAlg,

        defalg,
        defcb,
        defΩ,
        defΩProj,

        plotrv,
        plotscalar,
        default_cbs,
        HMCStep,
        default_cbs_tpl,
        default_cbs,

        Loop

# Causal Inference
include("causal/Causal.jl")
using .Causal
export replace,
       iscausebf,
       cf

# Library
include("primitive/Prim.jl")
using .Prim
export  bernoulli,
        betarv,
        β,
        categorical,
        # dirichlet,
        exponential,
        gammarv,
        Γ,
        invgamma,
        kumaraswamy,
        logistic,
        # mvnormal,
        normal,
        poisson,
        rademacher,
        uniform

export  succprob,
        failprob,
        maximum,
        minimum,
        islowerbounded,                    
        isupperbounded,
        isbounded,
        std,
        median,
        mode,
        modes,

        skewness,
        kurtosis,
        isplatykurtic,
        ismesokurtic,

        isleptokurtic,
        entropy,
        mean,
        prob,
        lprob

# Lifted distributional functions
export  lsuccprob,
        lfailprob,
        lmaximum,
        lminimum,
        lislowerbounded,                    
        lisupperbounded,
        lisbounded,
        lstd,
        lmedian,
        lmode,
        lmodes,

        lskewness,
        lkurtosis,
        lisplatykurtic,
        lismesokurtic,

        lisleptokurtic,
        lentropy,
        lmean

# Neural Network Stuff
include("flux.jl")
export Dense

# Memoize
include("memoize.jl")

# Memoize
include("scaling.jl")


end
