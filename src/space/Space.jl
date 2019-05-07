module Space

using ..Util
import ..Util: increment!, reset!
using Spec
import Flux     # FIXME: Can we excise this from this submodule?
import ForwardDiff
import Random
using Random: GLOBAL_RNG, AbstractRNG
using DocStringExtensions
using DataStructures: LinkedList, cons, nil, list, head, tail

export Ω, uid, @id, ID
export ΩBase, memrand, linearize, unlinearize
export append, base, combine, increment!, increment,
       Paired, pair
export ΩProj, parentω, memrand
export TaggedΩ, tag, Tags, hastags
export SimpleΩ, LinearΩ, update, nelem

include("idgen.jl")         # Id generation
include("index.jl")         # Pairing functions for omega ids
include("omega.jl")         # Sample Space
include("proj.jl")          # Sample Space Projection
include("tagged.jl")        # Space space Tagged with metadata
include("common.jl")
include("seed.jl")          # Setting the seed
include("simple.jl")        # Simple Ω
include("linear.jl")        # Linear Ω

include("rng.jl")        # Linear Ω


end