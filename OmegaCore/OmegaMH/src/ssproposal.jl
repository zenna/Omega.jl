import OmegaCore.Proposal
using OmegaCore: ExoRandVar, Member, like, propose

"Single-site proposal: change a single variable in `ω`"
struct SSProposal
end

function subpropose(qω, ::Member{<:StdNormal}, val; σ = 0.1)
  rand(qω, Normal(val, σ))
end

function subpropose(qω, ::Member{<:StdUniform}, val; σ = 0.1)
  @assert false "not implemented"
  # rand(qω, Normal(val, σ))
end

function Proposal.propose(qω, f, ω, ::SSProposal)
  # Uniformly choose over sites
  k = rand(qω, keys(ω))
  v = ω.data[k]
  qv = subpropose(qω, k, v)
  ω_ = like(ω, k => qv)
  # Resimulate
  propose(qω, f, ω, Proposal.CompProposal((Proposal.stdproposal,) ))
end

function Proposal.propose_and_logratio(qω, f, ω, ss::SSProposal)
  ω_ = propose(qω, ω, f, ss)
  (ω_, 0.0)
  # What should this be?
end