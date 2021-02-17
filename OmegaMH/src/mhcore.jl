import OmegaCore
export MH, mh

"Metropolis Hastings Samplng Algorithm"
struct MHAlg end
const MH = MHAlg()

"""
`mh(rng, ΩT, logdensity, f, n; proposal, ωinit)`

Metropolis Hastings Sampler

Initialised at `ωinit` yields `n` samples `ΩT` using Metropolis Hastings algorithm.


# Arguments
- `rng`: AbstractRng used to sample proposals in MH loop
- `ΩT`: Type of samples
- `n`: number of samples
- `logdensity`:  Density that `mh` will sample from. Function of `ω`.
- `f`: The random variable that we are taking samples from
- `proposal`: a proposal distributioion.   Has the form:
  `(ω_, log_p_q) = proposal(rng, ω)` where:
    `ω_` is the proposal
    `log_pqqp` is `log(g(p|q)/g(q|p))` the transition probability of moving from q to p
- `ωinit`: point to initialise from
"""
function mh(rng,
            ΩT::Type{OT},
            logdensity,
            f,
            n;
            proposal = SSProposal(),
            ωinit = ΩT()) where OT # should this be sat(f)
  ω = ωinit
  plast = logdensity(ω)
  qlast = 1.0
  ωsamples = OT[]  # zt - FIXME: Why aren't we storing the original sample
  accepted = 0
  # zt: what about burn-in Add skip
  for i = 1:n
    # ω_, logtransitionp = isempty(ω) ? (ω,0) : proposal(rng, ω)
    ω_, logtransitionp = propose_and_logratio(rng, ω, f, proposal)
    p_ = logdensity(ω_)
    ratio = p_ - plast + logtransitionp # zt: assumes symmetric?
    if log(rand(rng)) < ratio
      ω = ω_
      plast = p_
      accepted += 1
    end
    push!(ωsamples, deepcopy(ω))
  end
  ωsamples
end

function OmegaCore.randsample(rng,
                              ΩT::Type{OT},
                              x,
                              n,
                              alg::MHAlg) where {OT}
end

OmegaCore.randsample(rng, ΩT, x, n, ::MHAlg; kwargs...) = 
  mh(rng, ΩT, condvar(x), n; kwargs...) 