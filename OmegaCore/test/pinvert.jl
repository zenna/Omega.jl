using OmegaCore
using Test

function ptest1()
  x = 1 ~ Normal(0, 1)
  y = 2 ~ Normal(0, 1)
  z(ω) = x(ω) + y(ω)
  xy(ω) = (x(ω), y(ω))
  xy |ᶜ z ==ₚ z_

  # Defines pararametric representatio nover x and y
  proposal(::typeof(z), z_, θ) =
    (x => z_ - θ, y => θ)

  # defines distribution over x and y
  function proposal(::typeof(z), z_, ω)
    θ = 3 ~ Normal(0, 1)(ω)
    (x => z_ - θ, y => θ)
  end



end

function ptest2()
  β = 1 ~ Beta(0.5)
  x = 2 ~ Bernoulli(β)
  function proposal(::typeof(x), x_, ω)
    if x_
      r = uniform(0, p)
  end

end

def bernoulli(p):
  u = sample(rand(), "u")
  return u < p
with proposal(b):
  if b:
    r = sample(uniform(0, p), "r")
  else:
    r = sample(uniform(p, 1), "r")
  return {"u": r}
with proposal(t):
  return {"r": t["u"]}

  # Issues:

# How will this be implemented?
Conceptually what we want to do is something parametric relational programming, where we take the values we know, e.g. the conditioned outputs,
and use those to construct proposals on the rest.
The difficulties are how to fit this into a forward simulation framework, which Julia is

In posthook of funciton, we evaluate the proposal
-- e.g. after computing z(w), we do the proposal to update values of x and y (WHERE?)
This seems a bit late, to compute z we have to have already computed x and y.  We could overwrite it of course.

How about in prehook, z depends on x and y so in some sense contains x and y, so __before__ we evaluate z(w) we do the proposal for x and y

# How we will determine "who" chooses value for "who"

# What if no pinv given

# is typeof(z) specific enough, i.e. different randvars can have same type?
