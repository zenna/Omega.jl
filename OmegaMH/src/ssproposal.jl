import OmegaCore.Proposal
using OmegaCore: ExoRandVar, Member, like, propose, StdNormal, StdUniform, UniformInt

using OmegaCore.Util: update

export SSProposal

"Single-site proposal: change a single variable in `ω`"
struct SSProposal end

# Normally distribuetd proposal around `val`
function subpropose(qω, ::Member{<:StdNormal}, val; σ = 0.01)
  (randn(qω) * σ) + val
end

# Indepdent re-sample
function subpropose(qω, ::Member{<:UniformInt{T}}, val; σ = 0.01) where {T}
  # @assert false
  rand(qω, T)
  # (randn(qω) + val) * σ
end

function subpropose(qω, ::Member{<:StdUniform}, val; σ = 0.1)
  @assert false "not implemented"
end

function Proposal.propose(qω, f, ω, ::SSProposal)
  # Uniformly choose over sites
  k = rand(qω, keys(ω))
  qv = subpropose(qω, k, ω[k])

  # What about keeping most things constant?
  # ω_ = like(ω, k => qv)
  ω_ = update(ω, k, qv)

  # zt: is this ignore really necessary
  f(OmegaCore.tagignorecondition(OmegaCore.tagrng(ω_, qω)))
  ω_
end

function Proposal.propose_and_logratio(qω, f, ω, ss::SSProposal)
  ω_ = propose(qω, f, ω, ss)
  (ω_, 0.0) # Symmetric proposal
end

defpropose_and_logratio(f) = (qω, ω) -> Proposal.propose_and_logratio(qω, f, ω,  SSProposal())

# filter(x, ωO)