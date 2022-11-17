## Several different types of queries, direct, natural, controlled
export cde, acde, nde, ande, total_effect, ate

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
Average natural direct effect

`ande(Y, x, x_, Z)`

Example:
```julia
using Omega, Distributions
# Simple example of a model where X has a natural direct effect on Y but is mediated by Z
# There's a switch to turn the heater on or off : X
heater_on = 1 ~ Bernoulli(0.5)
heater_temp = ifelse.(heater_on, 10 ~ Normal(20, 1), 11 ~ Normal(0, 1))

# The ambient temperature is a function of the season
iswinter = 231 ~ Bernoulli(0.5)
ambient_temp = ifelse.(iswinter, 2 ~ Normal(0, 1), 3 ~ Normal(20, 1))

# The total temperature is the sum of the ambient and heater temperature
total = ambient_temp .+ heater_temp
temp = 43131 ~ Normal.(total, 1)

# Average natural direct effect of the heater on the temperature
ande(temp, heater_on, true, false, ambient_temp)


```
"""
function ande(Y, X, x, x_, Z) 
  # Should probably pull out this as it might
  # be a useful construction independently of `ande`
  # Wel lit is used in nde above, so there

  function Y_x_z_x(ω)
    z = intervene(Z, X => x_)(ω)
    intervene(Y, (X => x, Z => z))(ω)
  end
  𝔼(Y_x_z_x) - 𝔼(intervene(Y, X => x_))
end

"""
Average treatment effect

`𝔼(Y | do(X = x)) - 𝔼(Y | do(X = x_))`

```julia
using Omega, Distributions

# There's a switch to turn the heater on or off : X
heater_on = 1 ~ Bernoulli(0.5)
heater_temp = ifelse.(heater_on, 10 ~ Normal(10, 1), 11 ~ Normal(0, 1))

# The ambient temperature is a function of the season
iswinter = 1 ~ Bernoulli(0.5)
ambient_temp = ifelse.(iswinter, 2 ~ Normal(0, 1), 3 ~ Normal(20, 1))

# The total temperature is the sum of the ambient and heater temperature
total = ambient_temp .+ 10 .* heater_temp
temp = 4 ~ Normal.(total, 1)

# Average treatment effect of the heater on the temperature
ate(temp, heater_on, true, false)
```
"""
function ate(Y, X, x, x_)
  𝔼(intervene(Y, X => x) .- intervene(Y, X => x_))
end