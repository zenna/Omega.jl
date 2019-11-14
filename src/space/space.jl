module Space

using ..Util
using ..IDS
using Spec
import Flux     # FIXME: Can we excise this from this submodule?
import ForwardDiff
import Random
using Random: GLOBAL_RNG, AbstractRNG
using DocStringExtensions

export Ω 
export ΩBase, memrand, linearize, unlinearize
export ΩProj, parentω, memrand, proj
export TaggedΩ, tag, Tags, hastags, transfertags
export SimpleΩ, LinearΩ, update, nelem
export defΩ, defΩProj

include("omega.jl")         # Sample Space
include("proj.jl")          # Sample Space Projection
include("tagged.jl")        # Space space Tagged with metadata
include("common.jl")
include("seed.jl")          # Setting the seed

# Omega Types
include("simple.jl")        # Simple Ω
include("linear.jl")        # Linear Ω
include("rng.jl")           # Linear Ω
include("defaults.jl")


end