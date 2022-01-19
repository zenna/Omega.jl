module Condition

using ..Space, ..Tagging, ..Traits
using ..Var: AbstractVariable
export |ᶜ, cnd, conditions, cond!, condf, Conditional, ConditionException, tagignorecondition
export ==ₚ

# # Conditioning
# Conditioning a variable restricts the output to be consistent with some proposition.

"`x` given `y` is true"
struct Conditional{X, Y} <: AbstractVariable
  x::X
  y::Y
end

@inline x |ᶜ y = cnd(x, y)
@inline cnd(x, y) = Conditional(x, y)

"Conditions variable was conditioned on are not satisfied"
struct ConditionException <: Exception end

@inline condf(traits, ω, x, y) = Bool(y(ω)) ? x(ω) : throw(ConditionException())
@inline condf(::trait(IgnoreCondition), ω, x, y) = x(ω)
@inline condf(ω::Ω, x, y) where Ω = condf(traits(Ω), ω, x, y)

@inline tagcondition(ω, condition) = tag(ω, (condition = condition,))
@inline tagignorecondition(ω) = tag(ω, (ignorecondition = NoTagValue,))

# If error are violated then throw error
@inline (c::Conditional)(ω) = condf(ω, c.x, c.y)

"Conditions on `xy`"
conditions(xy::Conditional) = xy.y

"""
`cond!(ω::Ω, bool)`

Condition intermediate values from within the functional definition of a `RandVar`

```
function x_(ω)
  x = 0.0
  xs = Float64[]
  while bernoulli(ω, 0.8, Bool)
    x += uniform(ω, -5.0, 5.0)
    cond!(ω, x <=ₛ 1.0)
    cond!(ω, x >=ₛ -1.0)
    push!(xs, x)
  end
  xs
end

x = ciid(x_)
samples = rand(x, 100; alg = SSMH)
```
"""
cond!(ω::Ω, bool) where Ω = cond!(traits(Ω), ω, bool)
@inline cond!(traits, ω, bool) = nothing


"`selfcond(x, pred)` conditioned on `predₚ(x)`"
selfcond(x, pred) = cnd(x, ω -> pred(x(ω)))

end