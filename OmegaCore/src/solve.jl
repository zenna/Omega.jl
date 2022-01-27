module Solver

export solve, complete, isconditioned

import OmegaCore

import ..Var
using ..Tagging: Solve, tag
using ..Traits: trait
using ..Condition: Conditional

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
solve(f, ω) = Var.recurse(f, ω)

# # Defaualt case
# solve(f, id, ω) = f(ω)

function complete(x, ω = OmegaCore.defω())
  x(tag(ω, (solve = true,)))
end


# States:
# NoExpansion, always used specialised, don't expand
# Expand

end