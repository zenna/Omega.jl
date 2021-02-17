module Proposal

export propose, logproposalpdf, logproposalratio, propose_and_logratio

# Interfaces #

"""
`propose(qω, f, ω, proposal)`

Generate proposal for random variables within `f`, returns ω::Ω

# Input
- `f`   Random variable.  Proposal will generate values for depenends of `f`
- `ω::Ω` Initial mapping, to condition variables add to here
- `qω::Ω` Randomness for proposal
# Returns
- `ω::Ω` mapping from random variables to values
"""
function propose end

"""
`logproposalpdf(ω, ωnext, proposal)`

Log probability/density of generating `ωnext` from `ω` under `proposal`

```math
\\log(q(\\omega'|\\omega))
```
"""
function logproposalpdf end

"""
`logproposalratio(ω, ωnext, proposal)`

Log ratio of transition probabilities from `ω` to `ωnext`

```math
\\log(q(\\omega'|\\omega) / q(\\omega|\\omega'))
```
"""
function logproposalratio end

"proposal(ω"
function propose_and_logratio end

include("compproposal.jl")  # Composite Proposals
include("stdproposal.jl")   # Standard Proposals


# Notes #

# In general, a proposal is a function `q: Ω × Ω → Ω`
# That is, q(qω, ω) = ω' maps a current ω to ω'
# The additional input qω is necessary because proposals are not functions
# They are conditional distributions, qω is to capture the uncertainty
# in the proposal

# Most inference methods require that we can do two things with `q`, in general:
# The ability to construct samples, i.e. draw from q(ω' \mid ω)
# The ability to compute the (log) density / mass of q(ω' \mid ω)

# Here, we'll commit to a little more structure concerning `q`
# In particular, we'll define `q` through two things:
# (i) The random variable `x` that `ω` is defined on, and from which we ultimately which to sample
# (ii) A collection of subproposals `q_1, q_2, ... q_n` 

# A subproposal is a function `k :  Ω × Ω → Ω` with the same signature as `q`
# The difference is that with respect to the random variabel `x`, subproposals incomplete
# This means.

# Q. What's the interface

## The general approach here is:
## Assume as given some random variable `f` and some initial ω
## The initial ω may have some random variables that we wish to remain fixed
## Or it may be empty
## Execute the random variable `f`  and periodically fill in values of ω
## Our proposals are of the form:
## Given some preconditions (on ω) make some change to ω
## For example, suppose: x(ω) =   I have a normal distribution x = Normal(μ, σ)
## Given that `x`, μ, and σ are known then I may update the value of its StdNormal
## Alternatively given that I know

### If there's some primitive distribution within `f`



end