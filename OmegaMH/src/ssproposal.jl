import OmegaCore.Proposal
using OmegaCore: ExoRandVar, Member, like, propose, StdNormal, StdUniform

export SSProposal

"Single-site proposal: change a single variable in `ω`"
struct SSProposal end

function subpropose(qω, ::Member{<:StdNormal}, val; σ = 0.01)
  (randn(qω) + val) * σ
end

function subpropose(qω, ::Member{<:StdUniform}, val; σ = 0.1)
  @assert false "not implemented"
end

function Proposal.propose(qω, f, ω, ::SSProposal)
  # Uniformly choose over sites
  k = rand(qω, keys(ω))
  qv = subpropose(qω, k, ω[k])

  # What about keeping most things constant?
  ω_ = like(ω, k => qv)

  # zt: is this ignore really necessary
  f(OmegaCore.tagignorecondition(OmegaCore.tagrng(ω_, qω)))
  ω_
end

function Proposal.propose_and_logratio(qω, f, ω, ss::SSProposal)
  ω_ = propose(qω, f, ω, ss)
  (ω_, 0.0)
end

defpropose_and_logratio(f) = (qω, ω) -> Proposal.propose_and_logratio(qω, f, ω,  SSProposal())