"Inference Algorithms"
module Inference

using Spec
using ..Omega: RandVar, trackerrorapply, indomain, Wrapper, logepsilon,
               UTuple, logepsilon, Ω, applywoerror, SimpleΩ, cond, randtuple,
               fluxgradient, gradient, linearize, unlinearize, epsilon
using ProgressMeter
using Flux
using Callbacks
import UnicodePlots

"Inference Algorithm"
abstract type Algorithm end

"Is the inference algorithm approximate?"
function isapproximate end

"Default probability space type to use"
function defΩ end

include("transforms.jl")# Transformations from [0, 1] to R, etc
include("callbacks.jl") # Common Inference Functions
include("rand.jl")      # Sampling
include("rs.jl")        # Rejection Sampling
include("mi.jl")        # Metropolized Independent Sampling
include("ssmh.jl")      # Single Site Metropolis Hastings
include("hmc.jl")       # Hamiltonian Monte Carlo
include("hmcfast.jl")   # Faster Hamiltonian Monte Carlo
# include("sghmc.jl")     # Stochastic Gradient Hamiltonian Monte Carlo
include("relandscape.jl")  # Variantional Sampling through relandscape

export  isapproximate,

        RejectionSample,
        MI,
        SSMH,
        HMC,
        # SGHMC,
        HMCFAST,

        RejectionSampleAlg,
        MIAlg,
        SSMHAlg,
        HMCAlg,
        # SGHMCAlg,
        HMCFASTAlg,
        RelandscapeAlg,
        Relandscape,

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
