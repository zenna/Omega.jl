module RandVars

using Spec
using DocStringExtensions

import ..IDS: ID, uid
import ..Space: Ω, ΩBase, ΩProj, TaggedΩ, Tags, defΩ, hastags, base, tag, parentω

include("nondetvar.jl")        # Non deterministic variable 
include("var.jl")              # Free variable
include("randvar.jl" )         # Random variables
include("urandvar.jl")         # Random variables
include("randvarapply.jl")     # Random variable application to ω::Ω
include("ciid.jl")             # Conditionally i.i.d. RandVars
include("elemtype.jl")         # Infer Element Type
include("memoize.jl")          # Infer Element Type

export NonDetVar
export Var
export mem
export unit, solve, optim
export RandVar, MaybeRV, ciid, isconstant, elemtype, params, constant, apl

end