module Solver

export solve, complete, isconditioned

import OmegaCore

import ..Var
using ..Tagging: Solve, tag
using ..Traits: trait
using ..Conditioning: Conditional

function isconditioned end

function solve end

# function Var.

# function Var.prehook(::trait(Solve), f, ω)
#   # Assume h has no specialization
#   solve(f, ω)
#     # then just continue as normal
#   # either the recurse itself
#   solve(f, ω)
# end

# Doesn't have specialization we'll get here
hasspecial(f, ω) = solve(f, ω)  ## don't want to do a prehook

# doesn't have specialization
solve(f, ω) = nothing


function Var.recurse(::trait(Solve), f, ω)
  solve(f, ω)
end

# Default case, no specialization:
# solve(f, ω) = Var.recurse(f, ω)

# # Defaualt case
# solve(f, id, ω) = f(ω)

function complete(x, ω = OmegaCore.defω())
  x(tag(ω, (solve = true,)))
end


# States:
# NoExpansion, always used specialised, don't expand
# Expand

# "Given that we know `X` is `x_`"
# function propagate_to_exo(ω, X, x_)

# end

# What's the relationship between a conditioned rand var and 
# This propagation

# What's a better name for propagation
## implication? 
# Shouod return a set of pairs or some omega
# Do we need to return auxilaries too?
## Yes!
# Do we expcect the omega to be "full", like in solve?

# Where should we specify how far we want to go back?
# Might be unnecessary to go back to exogenous, e.g. in case of Bernoulli
# how to ensure this is a safe thing to do