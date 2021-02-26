module LogEnergies

using Distributions: Distribution, logpdf
using ..Traits, ..RNG, ..Var, ..Tagging, ..Space
using ..Util: Box

export logenergy, ℓ

## Simple Case
# In the simple case, the values of all the exogenous variables
# are within ω

"`logenergyexo(ω)` Log energy of `ω` only on exogenous variables"
function logenergyexo(ω)
  reduce(ω; init = 0.0) do logpdf_, (dist, val)
    logpdf_ + logpdf(dist, val)
  end
end

## Complex Case

@inline taglogenergy(ω, logenergy_ = 0.0, seen = Set()) = 
  tag(ω, (logenergy = (ℓ = Box(logenergy_), seen = seen),))

"""
`logenergy(rng::AbstractRNG, x, ω)`

Propose `ω::Ω` such that `x(ω)` is well defined with corresnponding proposal probability/density

# Returns
- `logenergy::Real`
"""
function logenergy(x, ω)
  ω_ = taglogenergy(ω)
  ret = x(ω_)
  ω_.tags.logpdf.ℓ.val
end

function Var.prehook(::trait(LogEnergy), ret, f, ω)
  #ω.tags.logpdf.val += logpdf(f, ret)
  # FIXME: scope doesn't exist.
  # What should it be?
  @show "HELLO"
  if f ∉ ω.tags.logenergy.seen
    @show "SEEN"
    ω.tags.logenergy.ℓ.val += logpdf(f, ret)
    push!(ω.tags.logenergy.seen, id)
  end
  nothing
end

function Var.posthook(::trait(LogEnergy), ret, f, ω)
  #ω.tags.logpdf.val += logpdf(f, ret)
  # FIXME: scope doesn't exist.
  # What should it be?
  @show "HELLO"
  if f ∉ ω.tags.logenergy.seen
    @show "SEEN"
    ω.tags.logenergy.ℓ.val += logpdf(f, ret)
    push!(ω.tags.logenergy.seen, id)
  end
  nothing
end


# """
# `logenergy(ω)`

# Unnormalized joint log density
# """
# function logenergy(ω)
#   reduce(ω.data; init = 0.0) do logenergy_, (id, (dist, val))
#     logpdf_ + logpdf(dist, val)
#   end
# end

const ℓ = logenergy

end