module LogEnergy

using Distributions: Distribution, logpdf
using ..Traits, ..RNG, ..Var, ..Tagging, ..Space
using ..Util: Box

export logenergy

@inline taglogpdf(ω, logpdf_ = 0.0, seen = Set()) = 
  tag(ω, (logpdf = (ℓ = Box(logpdf_), seen = seen),))

"""
`logenergy(rng::AbstractRNG, x, ω)`

Propose `ω::Ω` such that `x(ω)` is well defined with corresnponding proposal probability/density

# Returns
- `ret = (ω = ω_, ℓ = ℓ_)::NamedTuple` where
  - `ret.ω`:
  - `ret.ℓ`:
"""
function logenergy(rng, x, ω)
  ω_ = taglogpdf(ω)
  ret = x(ω_)
  ω.tags.logpdf.ℓ.val
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

end