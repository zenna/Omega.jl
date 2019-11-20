"A Expressive Library for Probabilistic Programming"
module Omega

import ForwardDiff
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

include("ctx/ctx.jl")
@reexport using .Ctx

# Ids 
include("ids/ids.jl")
@reexport using .IDS

# Probability Spaces
include("space/space.jl")         # UIDs
using .Space
export Ω, SimpleΩ, LinearΩ, defΩ, defΩProj

# RandVar
include("nondet/nondet.jl" )            # Random variables
using .NonDet
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
include("prim/Prim.jl")
@reexport using .Prim

# Library
include("dist/dist.jl")
@reexport using .Dist


# Neural Network Stuff
include("flux.jl")
@reexport using .OmegaFlux

# Scaling errors
include("scaling.jl")

# The Omega Lanaguage (Not Library) 
include("lang/lang.jl")

# Experimental

include("symbolic/symbolic.jl")
@reexport using .Symbolic

end
