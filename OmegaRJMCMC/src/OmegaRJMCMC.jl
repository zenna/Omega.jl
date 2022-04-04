"Reversible Jump MCMC"
module OmegaRJMCMC

using OmegaCore
using LinearAlgebra: det
using ForwardDiff: jacobian

export rjmcmc, RJMCMC

struct RJMCMCAlg end
const RJMCMC = RJMCMCAlg()


"""
Reversible Jump MCMC is an MCMC method designed for models where the number
of parameters is unknown.  These are sometimes called open-world or trans-
dimensional models.

# Arguments
- `rng::AbstractRNG`:  used to sample proposals in MH loop
- `x` : Initial state
- `moves`: Conditional random variable over moves
- `ℓ`: Function `ℓ(x::X)::Real` Density to sample from
- `n`: number of samples

# Returns
- 'xs': set of samples distributed according to `ℓ`
"""
function rjmcmc(rng, x, moves, ℓ, n)
  xs = [x]

  # Sample a moveset
  m = moves(rng, x) # TODO: THis is invalid
  for i = 1:n
    u = g(ω, m)
    (x_, u_) = m(x, u)
    ℓratio = ℓ(x_) / ℓ(x)
    jratio = j(m, x)
    jac = abs(det(jacobian(m)))
    accept_ratio - ℓratio * jratio * jac
    if rand(rng, Bernoulli(accept_ratio))
      x = x'
    end
    push!(xs, x)
  end
  xs
end

function OmegaCore.randsample(rng,
                              ΩT::Type{OT},
                              x,
                              n,
                              alg::RJMCMCAlg) where {OT}
  # introduce conditions
  # y = OC.mem(OC.indomain(x))
  y = condvar(x)
  ωsamples = OC.condomegasample(rng, ΩT, y, n, alg)
  # map(OC.mem(x), ωsamples)
  map(x, ωsamples)
end

end
