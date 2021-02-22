import OmegaCore.Proposal
using OmegaCore: ExoRandVar, Member, like, propose
using Distributions: Normal

"Single-site proposal: change a single variable in `ω`"
struct SSProposal
end

function subpropose(qω, ::Member{<:StdNormal}, val; σ = 0.1)
  rand(qω, Normal(val, σ))
end

function subpropose(qω, ::Member{<:StdUniform}, val; σ = 0.1)
  rand(qω, Uniform(0, 1))
  # @assert false "not implemented"
  # rand(qω, Normal(val, σ))
end

function Proposal.propose(qω, f, ω, ::SSProposal)
  # Uniformly choose over sites
  k = rand(qω, keys(ω))

  # Make a proposal for v
  qv = subpropose(qω, k, ω[k])
  ω_ = like(ω, k => qv)

  # Resimulate everything
  propose(qω, f, ω_, Proposal.CompProposal((Proposal.stdproposal,) ))
end

function Proposal.propose_and_logratio(qω, f, ω, ss::SSProposal)
  ω_ = propose(qω, ω, f, ss)
  (ω_, 0.0)
  # What should this be?
end