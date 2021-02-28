import ..Interventions: intervene
export rid, ∥ᵈ
"Represents the parent variables of `child`"
struct Parents{T}
  child::T
end

"""
`rid(x, θ)`

Random Interventional Distribution of `x` given `θ`

# Arguments
`x` - random variable
`θ` - random variable that is causal parent of `x`

# Returns 
random-variable valued random variable defined as:
  `ω -> intervene(x, θ => θ(ω))`
"""
rid(x, θ) = ω -> intervene(x, θ => θ(ω))


@inline x ∥ᵈ θ = rid(x, θ)