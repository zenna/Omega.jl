module Soft
using Spec
using ..Omega
using ..Omega:TaggedΩ, tag, apl
import Omega
import ForwardDiff
import Cassette
using LinearAlgebra: norm

using DocStringExtensions
export  d,
        SoftBool,
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
        @atα,

        indomain,
        indomainₛ,
        applynotrackerr,
        applytrackerr

abstract type AbstractSoftBool <: Real end
const AbstractBool = Union{AbstractSoftBool, Bool}

include("inf.jl")            # Infinity
include("kernels.jl")        # Kernels
include("softbool.jl")       # Soft Boolean
include("dualsoftbool.jl")   # Dual Soft Boolean
include("distances.jl")      # Standard Distance Functions
include("trackerror.jl")     # Tracking error
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

# Lifts #
  # Omega.lift(:softeq, 2)
  # Omega.lift(:softeq, 3)
  # Omega.lift(:softgt, 2)
  # Omega.lift(:softlt, 2)
  # Omega.lift(:logerr, 1)
  # Omega.lift(:err, 1)
  # Omega.lift(:kf1β, 1)
  # Omega.lift(:kseα, 1)
  # Omega.lift(:logkseα, 1)

end