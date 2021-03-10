module Proposals
# using Distributions: Distribution, logpdf
using Random: AbstractRNG
using ..Traits, ..RNG, ..Var, ..Tagging, ..Space
using ..Util

abstract type ProposalAlg end

export propose

"""
  `propose(rng::AbstractRNG, x, Ω = defΩ())`

Propose `ω::Ω` such that `x(ω)` is well defined with corresnponding proposal probability/density

# Returns
- `ret = (ω = ω_, ℓ = ℓ_)::NamedTuple` where
  - `ret.ω`:
  - `ret.ℓ`:
"""
function propose end

@inline taglogpdf(ω, logpdf_ = 0.0, seen = Set{idtype(ω)}()) = 
  tag(ω, (logpdf = (ℓ = Box(logpdf_), seen = seen),))

function propose(rng::AbstractRNG, x, Ω = defΩ())
  ω = tagrng(Ω(), rng)
  ω = taglogpdf(ω)
  ret = x(ω)
  (ω = ω, ℓ = ω.tags.logpdf.ℓ.val)
  # FIXME, should we return ω with rng tagged? Feel like i answers this with rejsample
end

function Var.posthook(::trait(LogPdf), ret, f::Distribution, id, ω)
  #ω.tags.logpdf.val += logpdf(f, ret)
  # FIXME: scope doesn't exist.
  # What should it be?
  if id ∉ ω.tags.logpdf.seen
    ω.tags.logpdf.ℓ.val += logpdf(f, ret)
    push!(ω.tags.logpdf.seen, id)
  end
  nothing
end

## Probs
# id or without id
# avoid duplicats, need seen
# generalize to anything with a logpdf

end