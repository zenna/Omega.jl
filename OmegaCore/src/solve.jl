module Solver

export solve, complete!, isconditioned

import OmegaCore

using Spec
import ..Var
using ..Tagging: Solve, tag
using ..Traits: trait
using ..Tagging
using ..Conditioning: Conditional
using ..Var: PrimRandVar, Member, Variable
using ..Var: Pw

export propagate!

# FIXME: Not a good way to check const type
const ConstTypes = Union{Real, Array{<:Real}}

"Variable of the form `X .== x`"
const EqualityCondition{A, B} = Pw{Tuple{A, B}, typeof(==)} where {A, B <: ConstTypes}

tagcomplete(ω) = tag(ω, (solve = true,))

"
`complete!(x, ω)`

*completes* `ω` in that it adds additional values in `ω` (assignments of random variables to values)
so that.

`ω::Ω` such that is well defined `x(ω)` is well-defined"
function complete!(x, ω)
  # FIXME: THere's a double use of ω
  # One use is as the input we're going to extend
  # And the other use is to generate new randomness
  # Is this okay
  ω_ = tagcomplete(ω)
  ret = x(ω_)
  ω_
end
@post complete!(x, ω) = (ω_ = __ret__; isvalid(x, ω_) & (ω_ ⊆ ω))

# Add a prehook for conditional variable
function Var.prehook(::trait(Solve), f::Conditional, ω) #FIXME: Use AndTraits
  propagate!(ω, f.y, true)
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

# idof(m::Member) = m.id
#   idof(v::Variable) = v.f.id

# function Var.prehook(::trait(Cond), d::Distribution, id, ω)
#   # FIXME: Is this correct?
#   matches = idof(ω.tags.condition.a) == id
#   if matches
#     inv = invert(d, ω.tags.condition.b)
#     ω[id] = (primdist(d), inv)
#   end
# end

# solution(f::Conditional, Ω = defΩ()) =
#   solution(Random.GLOBAL_RNG, f, Ω)

# end

end