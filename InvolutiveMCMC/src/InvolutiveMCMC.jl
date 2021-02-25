module InvolutiveMCMC

# using Distributions
# using Random
using InferenceBase: keepall

export imcmc!, imcmc

"`imcmc!(rng, p, Vₓ, p_vₓ, f, x, xs; n)` like `imcmc`, except mutates `xs`"
function imcmc!(rng, p, Vₓ, p_vₓ, f, x, xs; n, keep = keepall)
  logjoint(x, v) = p(x) + p_vₓ(v, x)
  i = 1
  s = 1
  while s <= n
    v = Vₓ(rng, x)
    x_n, v_n = f(x, v)
    ratio = logjoint(x_n, v_n) - logjoint(x, v)
    if log(rand(rng)) < ratio
      x = x_n
    end
    if keep(i)
      @inbounds xs[s] = x
      s += 1
    end
    i += 1
  end
  xs
end

"""
`imcmc(rng, p, Vₓ, f, x; n)`

Involutive MCMC

# Input:
- `rng`: RNG object
- `p(x)`: target logdensity `p(x) -> Real`
- `Vₓ(rng, x)`:  conditional random variable - samples from `v` given `x` where
    `v` is auxiliary variable
- `f(x, v) -> (x', v')`: an involution, i.e., `f(f((x, v))) == (x, v)`
- `x`: initial value of `x`
- `n`: number of samples

# Returns
- Set of samples drawn approimately according to `p`
""" 
imcmc(rng, p, Vₓ, p_vₓ, f, x::X; n, keep = keepall) where X = 
  imcmc!(rng, p, Vₓ, p_vₓ, f, x, Vector{X}(undef, n); n = n, keep = keep)

end # module
