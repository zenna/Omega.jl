module OmegaFlux

import ..Omega: ciid, logistic
import Flux
export OmegaDense

# "Dense network layer"
# function Flux.Dense(ω::Omega.Ω, in::Integer, out::Integer, σ = identity;
#                     initW = (ω, dims) -> logistic(ω, 0.0, 0.1, dims),
#                     initb = (ω, dims) -> logistic(ω, 0.0, 0.1, dims))
#   initW_ = initW(ω[@uid][1], (out, in))
#   initb_ = initb(ω[@uid][2], (out,))
#   Flux.Dense(initW_, initb_, σ)
# end

function OmegaDense(in, out, σ = identity;
  initW = logistic(0.0, 0.1, (in, out,)),
  initb = logistic(0.0, 0.1, (out,)))
  ciid(ω -> Flux.Dense(initW(ω), initb(ω), σ))
end

end