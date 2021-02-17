module Solution

using Random
using Distributions
using ..Space, ..RNG, ..Tagging, ..Var, ..Traits
using ..Condition: Conditional
import ..Var
export solution

# # Equality Condition
# Many (but not all) inference problems are of the form `X = x` where `X` is a
# a random variable abd `x` is a concrete constant.  Problems in this form often
# permit more tractable inference.  To exploit this we use a new type EqualityCondition
# so that we can identify theses cases just from their types


"""
`solution(x)`

Solution (aka model, interpretation) to constraints on random variable.

Returns any `ω` such that `x(ω) != ⊥`
"""
function solution end

const ConstTypes = Union{Real, Array{<:Real}}
const EqualityCondition{A, B} = PwVar{Tuple{A, B}, typeof(==)} where {A, B <: ConstTypes}
tagcondition(ω, condition) = tag(ω, (condition = condition,))

"""

`solution(rng, f, Ω)`

```
μ = 1 ~ Normal(0, 1)
y = 2 ~ Normal(μ, 1)
μc = μ |ᶜ (y ==ₚ 5.0)
solution(μc)
```
"""
function solution(rng::AbstractRNG,
                  f::Conditional{X, Y},
                  Ω = defΩ()) where {X, Y <: EqualityCondition}
  ω = tagrng(Ω(), rng)
  ωc = tagcondition(ω, f.y)
  f(ωc)
  ω
end

idof(m::Member) = m.id
  idof(v::Variable) = v.f.id

function Var.prehook(::trait(Cond), d::Distribution, id, ω)
  # FIXME: Is this correct?
  matches = idof(ω.tags.condition.a) == id
  if matches
    inv = invert(d, ω.tags.condition.b)
    ω[id] = (primdist(d), inv)
  end
end

solution(f::Conditional, Ω = defΩ()) =
  solution(Random.GLOBAL_RNG, f, Ω)

end


## What's wrong
# We need to indicate that a value does not need to be modified for conditioning
# I'm not 100 percent confident in the way im checking (id matching)
# this g(nothing) seems smelly
# What if we have more than one condition??
# Can we distinguish from X == X to X == Const at type level?
# how are we actually distapplyign to do it !
# what more do we need for MH

# Changes 
# change condition such that we also wat condition and add default behaviour
#   to do this erroring
# setup function barrier in this prehook such that if logpdf is there we update
# get rid of seen shit and rely on fact that rand in lazyomega is statefuk
# account for fact that we may have already done the update