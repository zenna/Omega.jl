module OmegaIMCMC

using Distributions
using Random
# using Zygote

export imh, imcmc

"""Involutive MCMC

# Input:
- `p_v_x`:  conditional random variable `p(v ∣ x)` where `v` are auxiliary variables
- `p`: target density `p(x, v) -> Real`
- `f`: an involution `f: x × v -> x × v` where `f(f(x)) == x`
- `ω`: Sample space
- `n`: Number of samples
- `x`: Initial value of `x`

# Returns
- Set of samples drawn approimately according to `p`
""" 
function imcmc(ω, p, p_v_x, f, x; n)
  xs = [x]
  for i = 1:n
    v = p_v_x(ω, x)
    x_n, v_n = f(x, v)
    @show x, v, x_n, v_n
    ratio = p(x_n, v_n) / p(x, v)
    P = min(1, ratio)
    if rand(ω, Bernoulli(P))
      x = x_n
    end
    push!(xs, x)
  end
  xs
end

"""
Involutive mcmc based Metropolis-Hastings"""
function imh(ω, p, q, x; n)
  f(x, v) = (v, x)
  imcmc(ω, p, q, f, x; n = n)
end

function test()
  ω = Random.GLOBAL_RNG
  p(x) = pdf(Normal(0, 1), x)
  p(x, v) = qpdf(x,v) * p(x)
  qpdf(v, x) = pdf(Normal(x, 0.1), v)
  q(ω, x) = rand(ω, Normal(x, 0.1))
  x = 0.1
  imh(ω, p, q, x; n = 100000)
end

# How would v fit into the frameworks I have considered?
# How to define involutions
end # module
