module OmegaRE

using Base.Threads: @spwan
export re, Replica, ReplicaAlg

"Replica Exchange (Parallel Tempering)"
struct ReplicaAlg end
const Replica = ReplicaAlg()

"swap `v[i]` and `v[j]`"
function swap!(v, i, j)
  temp = v[i] 
  v[i] = v[j]
  v[j] = temp
end

"Logarithmically spaced temperatures"
logtemps(n, k = 10) = exp.(k * range(-2.0, stop = 1.0, length = n))

struct PreSwap end
struct PostSwap end

"Swap adjacent chains"
function swap_contexts!(rng, ctxs, logdensity, ωs)
  for i in length(ωs):-1:2
    j = i - 1
    E_i_x = ctxapl(ctxs[i], logdensity, ωs[i])
    E_j_x = ctxapl(ctxs[j], logdensity, ωs[i])
    E_i_y = ctxapl(ctxs[i], logdensity, ωs[j])
    E_j_y = ctxapl(ctxs[j], logdensity, ωs[j])

    k = (E_i_y + E_j_x) - (E_i_x + E_j_y)
    
    doswap = log(rand(rng)) < k
    if doswap
      swap!(ωs, i, j)
    end
  end
end

"`every(m)` -- `f` where `f(i) is true every i steps"
every(m) = i -> i % m == 0

"""
`re(rng, logdensity, n, ctxs, algs)`

Replica Exchange Markov Chain Monte Carlo

Replica exhange:
- There are `n` different contexts, where a different context means a different target density
- There arae `A` different algorithms.  These may be actually different algorithms
  such as HMC vs SSMH, or different parameterizations of the same algorithm
- The user provides some subset of the cross product, i.e. `(ctx1, alg1), (ctx2, alg2)`
- runs `nreplicas = length(algs)` MCMC chains in parallel
- Each alg is run in a different context.
  - The most common form of a context is a temperature
- We assume there is a ground context which is the true model we wish to sample from
- 

# Arguments
- `rng`: AbstractRng used to sample proposals in MH loop
- `logdensity`: density to sample from
- `n`: number of samples
- `algs`: Sampling algorithms, each should support
  - each alg should support `alg(ω, ctx)`
- `ctxs`: List of contexts where:
  - a context is an object that implements:
    1. `logpdf(ctx, s)` -- logpdf of `x`
    2. `simulate(ctx, s)` -- simulate from density ctx, starting at ctx producing new state

# Returns
- `n` samples draw from ctx[1]
"""
function re(rng,
            n,
            ctxs,
            state,
            samples = Array{typeof(inits[1])}(undef, n),
            algs;
            keep = keepall,
            swap = every(div(n, 10)))
  # @pre length(ctxs) == length(algs)
  nreplicas = length(algs)

  GROUNDID = 1
  i = 0
  while i < n
    logpdf(ctx[groundid], state[groundid])
    # Simulate each replica
    for i = 1:nreplicas
      if i == groundid
        @inbounds samples[i:j] = simulaten(ctx[GROUNDID], state[GROUNDID], algs[GROUNDID])
        @inbounds state[GROUNDID] = samples[j]
      else
        @inbounds state[i] = simulate1(ctx[i], state[i], algs[i])
      end
    end
    swap(i) && swap_contexts!(rng, ctxs, logdensity, ωs)
  end
  samples
end

# Questions:
# Can there be more than one ground context?
# Is it true that from the ground context we need many samples and from
# everythinge else we need 1 sample?
# -- No, we only need samples from the ground context, we need scores
# From the others
# We need to be able to compute:
  # In some context i, density of some other point

# How should burn in / thinning work?
# Choice of representaiton:
## - alg(ctx, init_state)
## - apply(alg, ctx, init_state)
## - userprovidedfunc(alg, ctx, init_state)
## Do we need both Algs and Ctxs??
end # module
