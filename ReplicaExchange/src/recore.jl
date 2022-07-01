
using Spec
using Base.Threads: @sync, @spawn
export re!, re, re_all!, Replica, ReplicaAlg

using InferenceBase

"Replica Exchange (Parallel Tempering)"
struct ReplicaAlg end
const Replica = ReplicaAlg()

"swap `v[i]` and `v[j]`"
function swap!(v, i, j)
  temp = v[i] 
  v[i] = v[j]
  v[j] = temp
end

struct PreSwap end
struct PostSwap end

"Swap adjacent chains"
function swap_contexts!(rng, logenergys, states)
  for i in length(states):-1:2
    j = i - 1

    # Evaluate energy of state i at temperature i
    E_i_i = logenergys[i](states[i])
    E_i_j = logenergys[i](states[j])
    E_j_i = logenergys[j](states[i])
    E_j_j = logenergys[j](states[j])

    probaccept = (E_i_j + E_j_i) - (E_i_i + E_j_j)
    
    doswap = log(rand(rng)) < probaccept
    if doswap
      # println("did swap", i, j)
      swap!(states, i, j)
    # else
      # println("did not swap", i, j)
    end
  end
end
  

"`every(m)` -- `f` where `f(i) is true every i steps"
every(m) = i -> i % m == 0

"""
  `re!(rng,
        logenergys,
        samples_per_swap,
        num_swaps,
        samples,
        states,
        sim_chain_keep_n,
        sim_chain_keep_last = last ∘ sim_chain_keep_n,
        swap_contexts! = swap_contexts!)`
             
Replica Exchange Markov Chain Monte Carlo

Replica exhange:
- There are `n` different contexts, where a different context means a different target density
- There are `A` different algorithms.  These may be actually different algorithms
  such as HMC vs SSMH, or different parameterizations of the same algorithm
- The user provides some subset of the cross product, i.e. `(ctx1, alg1), (ctx2, alg2)`
- runs `nreplicas = length(algs)` MCMC chains in parallel
- Each alg is run in a different context.
  - The most common form of a context is a temperature
- We assume there is a ground context which is the true model we wish to sample from
- 

# Arguments
- `rng`: AbstractRng used to sample proposals in MH loop
- `logenergys`: collection of `n` logenergys to sample from
- `samples_per_swap` : number of samples drawn between each exchange
- `num_swaps`: number of swaps (num_samples = `samples_per_swap` * `num_swaps`)
- `states`: initial states
- `sim_chain_keep_n` : algorithm to take `samples_per_swap` mcmc steps and return all n
  - should support `sim_chain_keep_n(logenergy, init_state, n_samples)``
- `sim_chain_keep_1` : algorithm to take `samples_per_swap` mcmc steps and return only last
- `samples`: Vector of samples to mutate
- `swap_contexts!` function that swaps contexts every `num_swaps`, i.e. does exchange

# Returns
- `n` samples drawn from ground state
"""
# @pre length(logenergys) == length(states) "Must have one density per initial state"

function re!(rng,
             logenergys,
             samples_per_swap,
             num_swaps,
             states,
             samples,
             sim_chain_keep_n,
             sim_chain_keep_last = last ∘ sim_chain_keep_n,
             swap_contexts! = swap_contexts!,
             cb = tonothing)
  nreplicas = length(states)

  GROUNDID = 1
  for num_swap = 1:num_swaps
    lb = (num_swap - 1) * samples_per_swap + 1
    ub = lb + samples_per_swap - 1

    Threads.@sync for i = 1:nreplicas
      Threads.@spawn begin
        if i == GROUNDID
          # If we're ground state, return swap_every samples
          @inbounds samples[lb:ub] = sim_chain_keep_n(rng,
                                                  logenergys[GROUNDID],
                                                  states[GROUNDID],
                                                  samples_per_swap,
                                                  i)
          @inbounds states[GROUNDID] = samples[ub]
        else
          # If not ground state just return last sample
          @inbounds states[i] = sim_chain_keep_last(rng, logenergys[i], states[i], samples_per_swap, i)
        end
      end
    end
    swap_contexts!(rng, logenergys, states)
  end
  samples
end

"Non-mutating re!"
re(rng,
   logenergys,
   samples_per_swap,
   num_swaps,
   states,
   sim_chain_keep_n,
   sim_chain_keep_last = last ∘ sim_chain_keep_n,  
  swap_contexts! = swap_contexts!,
  cb = tonothing) = 
  re!(rng,
      logenergys,
      samples_per_swap,
      num_swaps,
      deepcopy(states),
      Vector{eltype(states)}(undef, num_swaps * samples_per_swap),
      sim_chain_keep_n,
      sim_chain_keep_last,
      swap_contexts!,
      cb)

function re_all!(rng,
                 logenergys,
                 samples_per_swap,
                 num_swaps,
                 states,
                 sim_chain_keep_n,
                 swap_contexts! = swap_contexts!,
                 samples = [Vector{typeof(states[i])}(undef, num_swaps*samples_per_swap) for i = 1:length(states)])
            #  swap = every(div(n, 10)))
  # @pre length(ctxs) == length(algs)
  nreplicas = length(states)
  if length(logenergys) != length(states)
    error("length(logenergys) != length(states)")
  end

  GROUNDID = 1
  for num_swap = 1:num_swaps
    lb = (num_swap - 1) * samples_per_swap + 1
    ub = lb + samples_per_swap - 1

    Threads.@sync for i = 1:nreplicas
      Threads.@spawn begin
        # If we're ground state, return swap_every samples
        @inbounds samples[i][lb:ub] = sim_chain_keep_n(rng,
                                                      logenergys[GROUNDID],
                                                      states[GROUNDID],
                                                      samples_per_swap,
                                                      i)
        @inbounds states[i] = samples[i][ub]
      end
    end
    swap_contexts!(rng, logenergys, states)
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
# Choice of representation:
## - alg(ctx, init_state)
## - apply(alg, ctx, init_state)
## - userprovidedfunc(alg, ctx, init_state)
## Do we need both Algs and Ctxs??