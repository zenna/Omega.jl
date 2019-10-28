"A Expressive Library for Probabilistic Programming"
module Omega

import ForwardDiff, Flux
using Spec
using UnicodePlots
using DocStringExtensions: FIELDS, SIGNATURES, TYPEDEF
using Cassette
using Lens
using Reexport

import Random
import Random: GLOBAL_RNG, AbstractRNG
import Statistics: mean, var, quantile

# Util
include("util/Util.jl")
@reexport using .Util

# Ids 
include("id/id.jl")
@reexport using .IDS

# Omega Spaces
include("space/Space.jl")         # UIDs
using .Space
export Ω, SimpleΩ, LinearΩ, defΩ, defΩProj

# RandVar
include("randvar/randvar.jl" )            # Random variables
using .RandVars
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
export @lift, lift, lift!

# Soft Inference
include("soft/soft.jl")           # Soft Booleans / logic
@reexport using .Soft

# Soft.logerr(x::RandVar) = 3
import .Soft: logerr, softeq, softgt, softlt, err, kf1β, kseα

Omega.lift!(:softeq, 2)
Omega.lift!(:softeq, 3)
Omega.lift!(:softgt, 2)
Omega.lift!(:softlt, 2)
Omega.lift!(:logerr, 1)
Omega.lift!(:err, 1)
Omega.lift!(:kf1β, 1)
Omega.lift!(:kseα, 1)

# Higher-Order Inference
include("higher/Higher.jl")
@reexport using .Higher

# Gradient
include("gradient/Gradient.jl")
@reexport using .Gradient

# Inference Algorithms
include("inference/Inference.jl")
@reexport using .Inference

# Causal Inference
include("causal/Causal.jl")
@reexport using .Causal

# Library
include("primitive/Prim.jl")
@reexport using .Prim

# Neural Network Stuff
include("flux.jl")
using .OmegaFlux
export OmegaDense

# Scaling errors
include("scaling.jl")

include("lang/lang.jl")


end
