## Several different types of queries, direct, natural, controlled

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
"""
function ande(Y, x, x_, Z) 
  # Should probably pull out this as it might
  # be a useful construction independently of `ande`
  # Wel lit is used in nde above, so there
  function Y_x_z_x(ω)
    z = intervene(Z, X => x)(ω)
    intervene(Y, X => x, Z => z)(ω)
  end
  mean(Y_x_z_x) - mean(intervene(Y, X => x_))
end