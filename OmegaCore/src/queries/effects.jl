## Several different types of queries, direct, natural, controlled
export cde, acde, nde, ande, total_effect, ate, Y_x_z_x

"""
Total effect

`total_effect(Y, y, i::Intervention)`

This is the probability of the outcome given the intervention

```math
P(Y_x = y)
```
"""
total_effect(Y, y, i::AbstractIntervention) = prob(intervene(Y .== y, i))

"""
Controlled unit-level direct effect

`cde(Y, x, x_, Z, z, ω)`

The controlled direct eect of `X = x`` on `Y`
in world ω and setting (controlled) `Z => z` 
"""
function cde(Y, x, x_, Z, z, ω)
  Yo = intervene(Y, X => x, Z => z)
  Yt = intervene(Y, X => x_, Z => z)
  (Yo .- Yt)(ω)
end

"""
Average controlled direct effect

`acde(Y, x, x_, Z, z)`

The average controlled direct eect of `X = x`` on `Y`
"""
acde(Y, x, x_, Z, z) = mean(ω -> cde(Y, x, x_, Z, z, ω))

"""
Natural unit-level direct effect

An event X = x is said to have a
natural direct eect on variable Y
in situation ω if the following inequality holds
"""
function nde(Y, x, x_, Z, ω)
  z_ = intervene(Z, X => x_)(ω)
  Y_x_z_ = intervene(Y, X => x, Z => z)(ω)
  Y_x__ = intervene(Y, X => x_)(ω)
  Y_x_z_ == Y_x__
end

"""
Double Hypothetical:
Value `Y` would have taken in world `ω` if `X``had `x` but `Z` had been the value it actually took
in the Hypothetical scenario that `X` had `x_`

Same as:

hi(Y, ω -> Intervention(X => x, Z => z_(ω)))
# Not quite

Key thing is
that the intervention is a random variable
"""
@inline function Y_x_z_x(ω, Y, X, x, x_, Z) 
  z = intervene(Z, X => x_)(ω)
  intervene(Y, (X => x, Z => z))(ω)
end

"""
Average natural direct effect

`ande(Y, x, x_, Z)`

Example:
```julia
using Omega, Distributions

# Another example
# Taking a medicine probabilistically improves your sleep (in hours) and relieves your symptoms
# Your overall rested (between 0 and 1) is higher the more you've slept
# The more rested you are the less aggrevated your symptoms are
# The medecine also directly reduces your symptoms 

# Taken the medicine or not
taken_med = 1 ~ Bernoulli(0.5)
# The amount of sleep you get (in hours)
nsleep = Variable(ifelse.(taken_med, 2 ~ Truncated(Normal(8, 1), 0, Inf), 3 ~ Truncated(Normal(6, 1), 0, Inf)))
# How rested you are (between 0 and 1) is higher the more you've slept
a = 3 .* (nsleep .- 2)
# need a to be positive, so clamp
a2 = Variable(clamp.(a, 0.1, Inf))
rested = Variable(4 ~ Beta.(a2, 9))


# The medicine can improve my symptoms (between 0 and 1) and it's more effective if I've rested
med_effective = 5 ~ Bernoulli.(rested)

health = ifelse.(taken_med, 6 ~ Beta.(8, 2), 7 ~ Beta.(2, 8))

# I feel well if I'm both well rested and my symptoms are low
well_being = rested .* health

# Average natural direct effect of the medicine on my well being
# This represents the average effect of the medicine on my well being
@show ande(well_being, taken_med, true, false, nsleep)
# X = taken_med
# x = true
# x_ = false
# Z = nsleep
# Y = well_being
````
"""
function ande(Y, X, x, x_, Z) 
  # Should probably pull out this as it might
  # be a useful construction independently of `ande`
  # Wel lit is used in nde above, so there
  function Y_x_z_x(ω) # Effect of X = x on Y removing influence through Z
    z = intervene(Z, X => x_)(ω)
    @show intervene(Y, (X => x, Z => z))(ω)
  end
  𝔼(Y_x_z_x) - 𝔼(intervene(Y, X => x))
end

"""
Average treatment effect

`𝔼(Y | do(X = x)) - 𝔼(Y | do(X = x_))`

```julia
using Omega, Distributions

# Taken the medicine or not
taken_med = 1 ~ Bernoulli(0.5)
# The amount of sleep you get (in hours)
sleep = ifelse.(taken_med, 2 ~ Truncated(Normal(8, 1), 0, Inf), 3 ~ Truncated(Normal(6, 1), 0, Inf))
# How rested you are (between 0 and 1) is higher the more you've slept
α = 3 .* (sleep .- 2)
# need α to be positive, so clamp
α_ = clamp.(α, 0.1, Inf)
rested = 4 ~ Beta.(α_, 9)

# The medicine can improve my symptoms (between 0 and 1) and it's more effective if I've rested
med_effective = 5 ~ Bernoulli.(rested)

health = ifelse.(taken_med, 6 ~ Beta.(8, 2), 7 ~ Beta.(2, 8))

# I feel well if I'm both well rested and my symptoms are low
well_being = rested .* health

# Average treatment effect
ate(well_being, taken_med, true, false)

Now in Pyro:
```python
import pyro
import pyro.distributions as dist
import pyro.poutine as poutine
from pyro.infer import SVI, Trace_ELBO
from pyro.optim import Adam

def model():
    taken_med = pyro.sample("taken_med", dist.Bernoulli(0.5))
    sleep = pyro.sample("sleep", dist.TruncatedNormal(8 if taken_med else 6, 1, 0, 10))
    α = 3 * (sleep - 2)
    rested = pyro.sample("rested", dist.Beta(α, 9))
    med_effective = pyro.sample("med_effective", dist.Bernoulli(rested))
    health = pyro.sample("health", dist.Beta(8 if med_effective else 2, 2 if med_effective else 8))
    well_being = pyro.sample("well_being", dist.Beta(rested * health, 1 - rested * health))

def guide():
    taken_med = pyro.sample("taken_med", dist.Bernoulli(0.5))
    sleep = pyro.sample("sleep", dist.TruncatedNormal(8 if taken_med else 6, 1, 0, 10))
    α = 3 * (sleep - 2)
    rested = pyro.sample("rested", dist.Beta(α, 9))
    med_effective = pyro.sample("med_effective", dist.Bernoulli(rested))
    health = pyro.sample("health", dist.Beta(8 if med_effective else 2, 2 if med_effective else 8))
    well_being = pyro.sample("well_being", dist.Beta(rested * health, 1 - rested * health))
```
"""
function ate(Y, X, x, x_)
  𝔼(intervene(Y, X => x) .- intervene(Y, X => x_))
end