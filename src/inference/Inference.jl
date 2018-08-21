"Inference Algorithms"
module Inference

using Spec
using ..Omega: RandVar, trackerrorapply, indomain, Wrapper, logepsilon,
               UTuple, logepsilon, Ω, applywoerror, SimpleΩ, cond, randtuple,
               fluxgradient
using ProgressMeter
using Flux

"Inference Algorithm"
abstract type Algorithm end

include("transforms.jl")# Transformations from [0, 1] to R, etc
include("callbacks.jl") # Common Inference Functions
include("rand.jl")      # Sampling
include("rs.jl")        # Rejection Sampling
include("mi.jl")        # Metropolized Independent Sampling
include("ssmh.jl")      # Single Site Metropolis Hastings
include("hmc.jl")       # Hamiltonian Monte Carlo
include("hmcfast.jl")   # Faster Hamiltonian Monte Carlo
include("sghmc.jl")     # Stochastic Gradient Hamiltonian Monte Carlo

export RejectionSample,
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

       idcb,
       everyn,
       →

       defalg,
       defcb,
       defΩ,
       defΩProj

end
