module Solver

export solve, complete, isconditioned

import OmegaCore

using Spec
import ..Var
using ..Tagging: Solve, tag
using ..Traits: trait
using ..Tagging
using ..Conditioning: Conditional
using ..Var: PrimRandVar, Member, Variable
using ..Var: Pw

export propagate!, propagate, complete

# FIXME: Not a good way to check const type
const ConstTypes = Union{Real, Array{<:Real}}

# FIXME
"Variable of the form `X .== x`"
const EqualityCondition{A, B} = Pw{Tuple{A, B}, typeof(==)} where {A, B <: ConstTypes}

tagcomplete(ω) = tag(ω, (solve = (ω = ω),))

"""
`complete(auxω, x, ω)`

*completes* `ω` in that it adds additional values in `ω` (assignments of random variables to values)
so that.

Inputs:
- `auxω`: auxiliary ω that determines how to complete initial `ω`
- `x`: a function of `ω`
- `ω`: initial ω

Returns:
`ω::Ω` such that is well defined `x(ω)` is well-defined
"""
function complete(auxω, x, initω)
  ω_ = tagcomplete(initω)
  ret = x(ω_)
  ω_.tags.solve
end
@post complete(x, ω) = (ω_ = __ret__; isvalid(x, ω_) & (ω_ ⊆ ω))

# # Add a prehook for conditional variable
# function Var.prehook(::trait(Solve), f::Conditional, ω) #FIXME: Use AndTraits
#   propagate!(ω, f.y, true)
# end

function Var.recurse(::trait(Solve), f::PrimRandVar, ω)
  @show f
  @show ω
  # Produce a value for f from its prior

  ω.tags.solve.ω[f] = # auxω(f)
  @assert false
end

@inline function propagate!(ω, x::EqualityCondition, x_)
  if x_
     # if (X == x_ )is true then X := x_
    propagate!(ω, x.args[1], x.args[2])
  end
end

# propagate back to exogenous
propagate!(ω, x::PrimRandVar, x_) =
  ω[x] = x_

"If x is a random variable of the form X == x_, propagate further"
@inline propagate(rng, x::EqualityCondition, tf) =
  tf ? propagate(rng, x.args[1], x.args[2]) : error("Toimplement")

@inline propagate(rng, x::PrimRandVar, x_) = (x => x_)

@inline propagate(rng, x_y::Conditional, tf::Bool) = 
  tf ? propagate(rng, x_y.y, true) : error("Unhandled cas") 

# So what are the questions?
# 1. Should auxω support the randomnes 
end