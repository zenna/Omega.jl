"Predicate Relaxation"
module SoftPredicates

using Spec
# import Omega
# import ForwardDiff  
import Cassette
using LinearAlgebra: norm
using DocStringExtensions

export  d,
        SoftBool,
        recursofteq,
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
        @atα
        
        # indomain,
        # indomainₛ,
        # applynotrackerr,
        # applytrackerr

abstract type AbstractSoftBool <: Real end
const AbstractBool = Union{AbstractSoftBool, Bool}

include("inf.jl")            # Infinity
include("kernels.jl")        # Kernels
include("kernelctx.jl")      # Kernels context
include("softbool.jl")       # Soft Boolean
include("dualsoftbool.jl")   # Dual Soft Boolean
include("distances.jl")      # Standard Distance Functions
include("recur.jl")          # Recursive
include("any.jl")            # any, all

# Using Dual Soft Bools
softeq(x, y) = dsofteq(x, y)
softgt(x, y) = dsoftgt(x, y)
softlt(x, y) = dsoftlt(x, y)

const softtrue = dsofttrue
const softfalse = dsoftfalse

# Using Not Dual Soft Bools
# const softeq = ssofteq
# const softgt = ssoftgt
# const softlt = ssoftlt

# const softtrue = ssofttrue
# const softfalse = ssoftfalse

const >ₛ = softgt
const >=ₛ = softgt
const <=ₛ = softlt
const <ₛ = softlt
const ==ₛ = softeq

end
