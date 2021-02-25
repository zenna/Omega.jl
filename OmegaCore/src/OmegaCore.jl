module OmegaCore

using Reexport
using Spec

include("util/util.jl")         # General utilities
@reexport using .Util

include("traits.jl")
@reexport using .Traits

include("tagging/tagging.jl")      # Tags
using .Tagging

include("rng.jl")               # Random number generation
using ..RNG

include("ids/ids.jl")           # IDs
@reexport using .IDS

include("basis/basis.jl")
@reexport using .Basis

include("var/var.jl")           # Random / Parameteric Variables
@reexport using .Var

include("space/space.jl")       # Probability / Paramter Spaces
@reexport using .Space

# include("ciid.jl")            # Conditional Independence
# @reexport using .CIID

include("interventions/interventions.jl")         # Causal interventions
@reexport using .Interventions

include("Higher/higher.jl")            # Higher order inference
@reexport using .Higher


# include("cassette.jl")

include("condition.jl")         # Conditioning variables
@reexport using .Condition

include("queries.jl")           # Query Templtes
@reexport using .Queries

include("sample.jl")            # Sample
@reexport using .Sample

include("trackerror.jl")
using .TrackError

include("proposal/proposal.jl")            # Log density
@reexport using .Proposal

include("solution.jl")               # Satisfy
@reexport using .Solution

include("logenergy.jl")
@reexport using .LogEnergy

# Basic Inference methods
# include("fail.jl")              # Fails when conditions are not satisfied
# @reexport using .Fail

include("rejection.jl")         # Rejection sampling Inference
@reexport using .OmegaRejectionSample

# include("pointwise.jl")
# @reexport using .Pointwise

include("syntax/syntax.jl")
@reexport using .Syntax


end