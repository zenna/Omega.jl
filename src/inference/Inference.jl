"Inference Algorithms"
module Inference

using Spec
using Random
using ..Omega: RandVar, applytrackerr, indomainₛ, Wrapper, logerr,
               UTuple, Ω, applynotrackerr, SimpleΩ, LinearΩ, Segment, randunifkey,
               update, cond, randtuple, nelem,
               fluxgradient, gradient, linearize, unlinearize, err

import ..Omega
using ProgressMeter
using Flux
using Callbacks
import UnicodePlots
using DocStringExtensions: SIGNATURES

"Optimization Algorithm"
abstract type OptimAlgorithm end

"Sampling Algorithm"
abstract type SamplingAlgorithm end

"Is the inference algorithm approximate?"
function isapproximate end

"Default probability space type to use"
function defΩ end

include("transforms.jl")# Transformations from [0, 1] to R, etc
include("callbacks.jl") # Common Inference Functions

# Sampling
include("rand.jl")      # Sampling
include("rs.jl")        # Rejection Sampling
include("ssmh.jl")      # Single Site Metropolis Hastings
# include("hmc.jl")       # Hamiltonian Monte Carlo
include("hmcfast.jl")   # Faster Hamiltonian Monte Carlo
include("replica.jl")   # Replica Exchange
include("dynamichmc.jl")# Dynamic Hamiltonion Monte Carlo
# include("sghmc.jl")     # Stochastic Gradient Hamiltonian Monte Carlo
# include("relandscape.jl")  # Variantional Sampling through relandscape

# Optimization
include("argmax.jl")     # NLopt based optimization
include("nlopt.jl")     # NLopt based optimization

export  isapproximate,

        RejectionSample,
        SSMH,
        HMC,
        # SGHMC,
        HMCFAST,
        Replica,

        RejectionSampleAlg,
        SSMHAlg,
        HMCAlg,
        # SGHMCAlg,
        HMCFASTAlg,
        RelandscapeAlg,
        Relandscape,
        NUTS,
        NUTSAlg,

        defalg,
        defcb,
        defΩ,
        defΩProj,

        plotrv,
        plotscalar,
        default_cbs,
        default_cbs_tpl,
        default_cbs


end
