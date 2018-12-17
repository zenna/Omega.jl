"Inference Algorithms"
module Inference

using Spec
using ..Omega: RandVar, applytrackerr, indomain, Wrapper, logerr,
               UTuple, Ω, applynotrackerr, SimpleΩ, LinearΩ, Segment, randunifkey, resample, resample!, cond, randtuple,
               fluxgradient, gradient, linearize, unlinearize, err
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

# Sampling
include("rand.jl")      # Sampling
include("rs.jl")        # Rejection Sampling
include("mi.jl")        # Metropolized Independent Sampling
include("ssmh.jl")      # Single Site Metropolis Hastings
include("hmc.jl")       # Hamiltonian Monte Carlo
include("hmcfast.jl")   # Faster Hamiltonian Monte Carlo
include("replica.jl")   # Replica Exchange
# include("sghmc.jl")     # Stochastic Gradient Hamiltonian Monte Carlo
# include("relandscape.jl")  # Variantional Sampling through relandscape

# Optimization
include("argmax.jl")     # NLopt based optimization
include("nlopt.jl")     # NLopt based optimization

export  isapproximate,

        RejectionSample,
        MI,
        SSMH,
        SSMHDrift,
        HMC,
        # SGHMC,
        HMCFAST,

        RejectionSampleAlg,
        MIAlg,
        SSMHAlg,
        SSMHDriftAlg,
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
