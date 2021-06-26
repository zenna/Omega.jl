import ..OmegaCore
using ..Var, ..Traits, ..Util, ..Tagging, ..Space, ..Basis

# Dynamics

##
# @inline tagpropose(ω, logpdf_ = 0.0, seen = Set{Basis.idtype(ω)}()) = 
#   tag(ω, (logpdf = (ℓ = Box(logpdf_), seen = seen),))

@inline tagpropose(ω, qω, q) = 
  tag(ω, (logpdf = (qω = qω, q = q),))

"""A composite proposal defined by a set of sub proposals
Sequence of subproposals

`subq(rng, x::RV, ω) -> ω'

- `x` is the random variable just executed?
and where `ω'` has some of the values

"""
struct CompProposal{T}
  subproposals::T
end

function subproposals!(qω, f, ω, q::CompProposal)
  for subq in q.subproposals
    @show "!!" f
    subω = subq(qω, f, ω)
    if !isnothing(subω)
      ω = merge!(ω, subω)
    end
  end
  ω
end

function Var.posthook(::trait(Propose), ret, f, ω)
  @show typeof(f) "GAGAGA!#@@"
  ## Add f to ω, since some proposal might depend on it
  if f in keys(ω.data)
    @assert ω.data[f] == ret # FIXME, this shouldn't be an assert,
    # Or should it?
  else
    ω.data[f] = ret
  end
  # FIXME, need to get qω in here and subqs
  subproposals!(ω.tags.logpdf.qω, f, ω, ω.tags.logpdf.q)
end

function propose!(qω, f, ωc, q::CompProposal)
  @show "\n\n"
  display(ωc)
  subproposals!(qω, f, ωc, q)
  f(tagpropose(ωc, qω, q))
  ωc
end

propose(qω, f, ω, q::CompProposal) = 
  propose!(qω, f, deepcopy(ω), q::CompProposal)
