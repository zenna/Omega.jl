import OmegaCore
import OmegaCore: propose_and_logratio
export MH, mh, mh!

"Metropolis Hastings Samplng Algorithm"
struct MHAlg end
const MH = MHAlg()

# FIXME: Move these to MH common

"`burnin(n)` keep function that ignores first `n` samples"
ignorefirstn(n) = i -> i > n

"`thin(n)` keep function that accept only every `n` samples"
thin(n) = i -> i % n == 0

@inline keepall(i) = true

"`a &ₚ b` Pointwise logical `x->a(x) & b(x)`"
a &ₚ b = (x...)->a(x...) &ₚ b(x...)

"""
`mh(rng, ΩT, logdensity, f, n; proposal, ωinit)`

Metropolis Hastings Sampler

Initialised at `ωinit`, yields `n` samples `::ΩT` using Metropolis Hastings algorithm.

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
- `keep`: function from `i -> b::Bool` which says whether to keep the sample at ith iteration or not
Useful for defining burn in or thinning.
  Example `keep = i -> ignorefirstn(100)(i) & thin(m)(i)`
"""
function mh!(rng,
             logdensity,
             f,  #FIXME: Do we need f as input?
             n,
             ωinit::OT,
             proposal,
             ΩT::Type = OT,
             ωsamples = Vector{ΩT}(undef, n),
             keep = keepall) where OT # should this be sat(f)
  ω = ωinit
  plast = logdensity(ω)
  qlast = 1.0
  accepted = 0
  tot = 0
  i = 0
  while i < n
    ω_, logtransitionp = propose_and_logratio(rng, ω, f, proposal)
    p_ = logdensity(ω_)
    ratio = p_ - plast + logtransitionp
    if log(rand(rng)) < ratio
      if keep(i)
        ω = ω_
        plast = p_
        i += 1
        @inbounds ωsamples[i] = deepcopy(ω)
      end
      accepted += 1
    end
    tot += 1
  end
  ωsamples
end

# FIXME: move this to an interface file

function OmegaCore.randsample(rng,
                              ΩT::Type{OT},
                              x,
                              n,
                              alg::MHAlg) where {OT}
end

OmegaCore.randsample(rng, ΩT, x, n, ::MHAlg; kwargs...) = 
  mh(rng, ΩT, condvar(x), n; kwargs...) 