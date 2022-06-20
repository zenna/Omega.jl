import OmegaCore
import OmegaCore: propose_and_logratio
export MH, mh, mh!

using InferenceBase: keepall, tonothing

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
- `n`: number of samples
- `state_init`: point to initialise from
- `propose_and_logratio`: function to propose a new state and return its log density ratio
Has the form:
  `(x_, log_p_q) = proposal_and_logratio(rng, x)` where:
    `x_` is the proposal
    `log_pqqp` is `log(g(p|q)/g(q|p))` the transition probability of moving from q to p
- `keep`: function from `i -> b::Bool` which says whether to keep the sample at ith iteration or not
Useful for defining burn in or thinning.
  Example `keep = i -> ignorefirstn(100)(i) & thin(m)(i)`
- `prestore` - function applied to each state before addition to result
- `cb`: callback, called in each iteration.  Can be used for logging
"""
function mh!(rng,
             logdensity,
             n,
             state_init,
             propose_and_logratio,
             samples;
             keep = keepall,
             prestore = identity,
             cb = tonothing)
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
    cb((i = i, p = p_, accepted = accepted))
    i += 1
  end
  samples
end

function mh(rng,
            logdensity,
            n,
            state_init::X,
            propose_and_logratio; keep = keepall,
            prestore = identity,
   cb = tonothing) where X
  mh!(rng,
      logdensity,
      n,
      state_init,
      propose_and_logratio,
      Vector{X}(undef, n);
      keep = keep,
      prestore = prestore, cb = cb)
end