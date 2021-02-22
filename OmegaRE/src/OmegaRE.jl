module OmegaRE

using Base.Threads: @spawn
export re!, re_all!, Replica, ReplicaAlg

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
function swap_contexts!(rng, logpdfs, states, evaluate)
  for i in length(states):-1:2
    j = i - 1

    # Evaluate energy of state i at temperature i
    E_i_i = evaluate(logpdfs[i], states[i])
    E_i_j = evaluate(logpdfs[i], states[j])
    E_j_i = evaluate(logpdfs[j], states[i])
    E_j_j = evaluate(logpdfs[j], states[j])
     
    # E_i_x = ctxapl(ctxs[i], logdensity, states[i])
    # E_j_x = ctxapl(ctxs[j], logdensity, states[i])
    # E_i_y = ctxapl(ctxs[i], logdensity, states[j])
    # E_j_y = ctxapl(ctxs[j], logdensity, states[j])

    probaccept = (E_i_j + E_j_i) - (E_i_i + E_j_j)
    
    doswap = log(rand(rng)) < probaccept
    if doswap
      swap!(states, i, j)
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
function re!(rng,
             logpdfs,
             samples_per_swap,
             num_swaps,
             states,
             simulate_n,
             simulate_1,
             evaluate,
             samples = Vector{typeof(states[1])}(undef, num_swaps*samples_per_swap))
            #  swap = every(div(n, 10)))
  # @pre length(ctxs) == length(algs)
  nreplicas = length(states)
  if length(logpdfs) != length(states)
    error("length(logpdfs) != length(states)")
  end

  GROUNDID = 1
  for num_swap = 1:num_swaps
    for i = 1:nreplicas
      if i == GROUNDID
        # If we're ground state, return swap_every samples
        lb = (num_swap - 1) * samples_per_swap + 1
        ub = lb + samples_per_swap - 1
        @show lb, ub
        @inbounds samples[lb:ub] = simulate_n(logpdfs[GROUNDID],
                                              states[GROUNDID],
                                              samples_per_swap)
        @inbounds states[GROUNDID] = samples[ub]
      else
        # If not ground state just return last sample
        @inbounds states[i] = simulate_1(logpdfs[i], states[i], samples_per_swap)
      end
    end
    swap_contexts!(rng, logpdfs, states, evaluate)
  end
  samples
end

function re_all!(rng,
                 logpdfs,
                 samples_per_swap,
                 num_swaps,
                 states,
                 simulate_n,
                 simulate_1,
                 evaluate,
                 samples = [Vector{typeof(states[i])}(undef, num_swaps*samples_per_swap) for i = 1:length(states)])
            #  swap = every(div(n, 10)))
  # @pre length(ctxs) == length(algs)
  nreplicas = length(states)
  if length(logpdfs) != length(states)
    error("length(logpdfs) != length(states)")
  end

  GROUNDID = 1
  for num_swap = 1:num_swaps
    for i = 1:nreplicas
      # If we're ground state, return swap_every samples
      lb = (num_swap - 1) * samples_per_swap + 1
      ub = lb + samples_per_swap - 1
      samples[i][lb:ub] = simulate_n(logpdfs[i],
                                               states[i],
                                               samples_per_swap)
      states[i] = samples[i][ub]
    end
    swap_contexts!(rng, logpdfs, states, evaluate)
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
