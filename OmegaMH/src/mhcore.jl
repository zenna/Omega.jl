import OmegaCore
import OmegaCore: propose_and_logratio
export MH, mh, mh!

using InferenceBase: keepall

"Metropolis Hastings Samplng Algorithm"
struct MHAlg end
const MH = MHAlg()

function propose_and_logratio end

"""
`mh(rng, ΩT, logdensity, f, n; proposal, state_init)`

Metropolis Hastings Sampler

Initialised at `state_init`, yields `n` samples `::ΩT` using Metropolis Hastings algorithm.

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
- `state_init`: point to initialise from
- `keep`: function from `i -> b::Bool` which says whether to keep the sample at ith iteration or not
Useful for defining burn in or thinning.
  Example `keep = i -> ignorefirstn(100)(i) & thin(m)(i)`
"""
function mh!(rng,
             logdensity,
             n,
             state_init,
             propose_and_logratio,
             samples;
             keep = keepall,
             prestore = identity)
  state = state_init
  plast = logdensity(state)
  qlast = 1.0
  accepted = 0
  i = 1
  s = 1
  while s <= n
    propstate, logtransitionp = propose_and_logratio(rng, state)
    p_ = logdensity(propstate)
    ratio = p_ - plast + logtransitionp
    if log(rand(rng)) < ratio
      state = propstate
      plast = p_
      accepted += 1
    end
    if keep(i)
      @inbounds samples[s] = prestore(state)
      s += 1
    end
    i += 1
  end
  samples
end

mh(rng, logdensity, n, state_init::X, propose_and_logratio; keep = keepall, prestore = identity) where X = 
  mh!(rng, logdensity, n, state_init, propose_and_logratio, Vector{X}(undef, n); keep = keep, prestore = prestore)