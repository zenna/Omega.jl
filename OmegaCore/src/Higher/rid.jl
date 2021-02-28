import ..Interventions: intervene
export rid, ¦²

"Represents the parent variables of `child`"
struct Parents{T}
  child::T
end

"""
    `rid(x, \theta )`

Random Interventional Distribution of `x` given `\theta`
"""
rid(x, θ) = ω -> intervene(x, θ => θ(ω))

@inline x ¦² θ = rid(x, θ)