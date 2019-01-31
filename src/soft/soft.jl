abstract type AbstractSoftBool end
const AbstractBool = Union{AbstractSoftBool, Bool}

include("kernels.jl")        # Kernels
include("softbool.jl")       # Soft Boolean
include("dualsoftbool.jl")   # Dual Soft Boolean
include("distances.jl")      # Standard Distance Functions
include("trackerror.jl")     # Tracking error


# Using Dual Soft Bools
# const softeq = dsofteq
# const softgt = dsoftgt
# const softlt = dsoftlt

# const softtrue = dsofttrue
# const softfalse = dsoftfalse

# Using Not Dual Soft Bools
const softeq = ssofteq
const softgt = ssoftgt
const softlt = ssoftlt

const softtrue = ssofttrue
const softfalse = ssoftfalse

const >ₛ = softgt
const >=ₛ = softgt
const <=ₛ = softlt
const <ₛ = softlt
const ==ₛ = softeq

## Lifts
## =====
Omega.lift(:softeq, 2)
Omega.lift(:softeq, 3)
Omega.lift(:softgt, 2)
Omega.lift(:softlt, 2)
Omega.lift(:logerr, 1)
Omega.lift(:err, 1)
