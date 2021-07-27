module OmegaRejectionSample
import Base.Threads

import ..OmegaCore
using ..Util, ..Sample, ..Condition, ..TrackError, ..RNG
const OC = OmegaCore
# import ..OmegaCore: randsample

export RejectionSample

"Rejection Sampling  Algorithm"
struct RejectionSampleAlg end
const RejectionSample = RejectionSampleAlg()

OmegaCore.defrandalg(args...) = RejectionSample

function omegarandsample1(rng,
                          ΩT::Type{OT},
                          y,
                          alg::RejectionSampleAlg) where OT
  @label restart
  ω = ΩT()
  ω_ = tagrng(ω, rng)
  !y(ω_) && @goto restart
  ω
end


"`n` samples from ω::ΩT such that `y(ω)` is true"
function OC.omegarandsample(rng,
                       ΩT::Type{OT},
                       y,
                       n,
                       alg::RejectionSampleAlg) where OT
  hack = OT()
  ωsamples = Vector{typeof(hack)}(undef, n)  # Fixme
  accepted = 0
  i = 1
  # rngs = OC.duplicaterng(rng, Threads.nthreads())
  # Threads.@threads for i = 1:n
  #   rng = rngs[Threads.threadid()]
  #   @inbounds ωsamples[i] = omegarandsample1(rng, ΩT, y, n, alg)
  # end
  for i = 1:n
    # rng = rngs[Threads.threadid()]
    @inbounds ωsamples[i] = omegarandsample1(rng, ΩT, y, alg)
  end

  ωsamples
end

function OC.randsample(rng,
                       ΩT::Type{OT},
                       x,
                       n,
                       alg::RejectionSampleAlg) where {OT}
  # introduce conditions
  # y = OC.mem(OC.indomain(x))
  y = condvar(x, Bool)
  ωsamples = OC.omegarandsample(rng, ΩT, y, n, alg)
  # map(OC.mem(x), ωsamples)
  map(x, ωsamples)
end

end