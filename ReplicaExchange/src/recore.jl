
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
      swap!(states, i, j)
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
        states,
        samples,
        sim_chain_keep_n,
        sim_chain_keep_last = last ∘ sim_chain_keep_n,
        swap_contexts! = swap_contexts!)`
             
Replica Exchange Markov Chain Monte Carlo (REMCMC)

Description:
- REMCMC is a Markov Chain Monte Carlo algorithm for sampling from the cartesian product 
  of a collection of `n` distributions given their respective densities.
- REMCMC works by running `n` independent MCMC chains in parallel for `samples_per_swap` steps using 
  a user-specified transition kernel (`sim_chain_keep_n`), and then subsequently proposing 
  a special transition kernel that swaps the position of parallel chains.
- REMCMC is agnostic to the user-specified transition kernel, as long as its stationary distribution
  is equal to the distribution corresponding to its respective input density. E.g. this permits HMC or RW-MCMC.
- A common use-case for REMCMC is when the target distribution is non-smooth and we would expect
  a single MCMC transition kernel to become stuck near a local optima. Then, the collection of distributions
  are induced by annealing the target distribution with a sequence of increasing temperatures.
- In this implementation we assume that the user is only interested in samples from the single target distribution
  and that the same `sim_chain_keep_n` is used for each of the `n` distributions.
- Note: re! mutates `states` and `samples`.

# Arguments
- `rng`: AbstractRng used to sample proposals in MH loop
- `logenergys`: collection of `n` logenergys (log unnormalized densities) to sample from. Each `logenergy = getindex(logenergys, i::Int64)`
  is a function from the domain of `states` to the reals.
- `samples_per_swap` : number of samples drawn between each exchange (i.e. swap)
- `num_swaps`: number of swaps
- `states`: initial states. Note: re! mutates `states`.
- `samples`: Collection of samples from the target density to mutate
- `sim_chain_keep_n` : algorithm to take `samples_per_swap` mcmc steps and return all n
  - should support `sim_chain_keep_n(rng, logenergy, init_state, samples_pre_swap, i)`
- `sim_chain_keep_last` : optional function that takes `samples_per_swap` mcmc steps and return only the last sample.
  - should support `sim_chain_keep_last(rng, logenergy, init_state, samples_pre_swap, i)`
- `swap_contexts!` : optional mutating function that swaps contexts every `num_swaps`, i.e. performs the exchange between
  parallel chains.
  - should support `swap_contexts!(rng, logenergys, states)`

# Returns
- `n` samples drawn from ground state
"""

function re!(rng,
             logenergys,
             samples_per_swap,
             num_swaps,
             states,
             samples,
             sim_chain_keep_n,
             sim_chain_keep_last = last ∘ sim_chain_keep_n,
             swap_contexts! = swap_contexts!)
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

@pre re!(rng, logenergys, samples_per_swap, num_swaps, states, samples, sim_chain_keep_n) = length(samples) == samples_per_swap * num_swaps
@pre re!(rng, logenergys, samples_per_swap, num_swaps, states, samples, sim_chain_keep_n) = num_swaps > 0 "There must be at least 1 swap"
@pre re!(rng, logenergys, samples_per_swap, num_swaps, states, samples, sim_chain_keep_n) = all([isa(logenergy, Function) for logenergy in logenergys]) "logenergys is a Function"
@pre re!(rng, logenergys, samples_per_swap, num_swaps, states, samples, sim_chain_keep_n) = isa(sim_chain_keep_n, Function) "sim_chain_keep_n is a Function"
@pre re!(rng, logenergys, samples_per_swap, num_swaps, states, samples, sim_chain_keep_n) = length(logenergys) == length(states) "Must have one density per initial state"
# usage of @cap and @ret in README of Spec.jl throws an error.
# @post re!(rng, logenergys, samples_per_swap, num_swaps, states, samples, sim_chain_keep_n, sim_chain_keep_last, swap_contexts!) = (@cap(x), @ret) "Result is sorted version of input"


"""
  `re(rng,
        logenergys,
        samples_per_swap,
        num_swaps,
        states,
        sim_chain_keep_n,
        sim_chain_keep_last = last ∘ sim_chain_keep_n,
        swap_contexts! = swap_contexts!)`
             
Replica Exchange Markov Chain Monte Carlo (REMCMC)
Non-mutating version of [re!](@ref).

Description:
- REMCMC is a Markov Chain Monte Carlo algorithm for sampling from the cartesian product 
  of a collection of `n` distributions given their respective densities.
- REMCMC works by running `n` independent MCMC chains in parallel for `samples_per_swap` steps using 
  a user-specified transition kernel (`sim_chain_keep_n`), and then subsequently proposing 
  a special transition kernel that swaps the position of parallel chains.
- REMCMC is agnostic to the user-specified transition kernel, as long as its stationary distribution
  is equal to the distribution corresponding to its respective input density. E.g. this permits HMC or RW-MCMC.
- A common use-case for REMCMC is when the target distribution is non-smooth and we would expect
  a single MCMC transition kernel to become stuck near a local optima. Then, the collection of distributions
  are induced by annealing the target distribution with a sequence of increasing temperatures.
- In this implementation we assume that the user is only interested in samples from the single target distribution
  and that the same `sim_chain_keep_n` is used for each of the `n` distributions.
- Note: re does not mutate `states`.

# Arguments
- `rng`: AbstractRng used to sample proposals in MH loop
- `logenergys`: collection of `n` logenergys (log unnormalized densities) to sample from. Each `logenergy = getindex(logenergys, i::Int64)`
  is a function from the domain of `states` to the reals.
- `samples_per_swap` : number of samples drawn between each exchange (i.e. swap)
- `num_swaps`: number of swaps
- `states`: initial states. Note: re does not mutate `states`.
- `sim_chain_keep_n` : algorithm to take `samples_per_swap` mcmc steps and return all n
  - should support `sim_chain_keep_n(rng, logenergy, init_state, samples_pre_swap, i)`
- `sim_chain_keep_last` : optional function that takes `samples_per_swap` mcmc steps and return only the last sample.
  - should support `sim_chain_keep_last(rng, logenergy, init_state, samples_pre_swap, i)`
- `swap_contexts!` : optional mutating function that swaps contexts every `num_swaps`, i.e. performs the exchange between
  parallel chains.
  - should support `swap_contexts!(rng, logenergys, states)`

# Returns
- `n` samples drawn from ground state
"""

re(rng,
   logenergys,
   samples_per_swap,
   num_swaps,
   states,
   sim_chain_keep_n,
   sim_chain_keep_last = last ∘ sim_chain_keep_n,  
  swap_contexts! = swap_contexts!) = 
  re!(rng,
      logenergys,
      samples_per_swap,
      num_swaps,
      deepcopy(states),
      Vector{eltype(states)}(undef, num_swaps * samples_per_swap),
      sim_chain_keep_n,
      sim_chain_keep_last,
      swap_contexts!)

@pre re(rng, logenergys, samples_per_swap, num_swaps, states, sim_chain_keep_n) = num_swaps > 0 #"There must be at least 1 swap"
@pre re(rng, logenergys, samples_per_swap, num_swaps, states, sim_chain_keep_n) = all([isa(logenergy, Function) for logenergy in logenergys]) "logenergys is a Function"
@pre re(rng, logenergys, samples_per_swap, num_swaps, states, sim_chain_keep_n) = isa(sim_chain_keep_n, Function) "sim_chain_keep_n is a Function"
@pre re(rng, logenergys, samples_per_swap, num_swaps, states, sim_chain_keep_n) = length(logenergys) == length(states) "Must have one density per initial state"
# usage of @cap and @ret in README of Spec.jl throws an error.
# @post re!(rng, logenergys, samples_per_swap, num_swaps, states, sim_chain_keep_n, sim_chain_keep_last, swap_contexts!) = (@cap(x), @ret) "Result is sorted version of input"

"""
  `re_all!(rng,
        logenergys,
        samples_per_swap,
        num_swaps,
        states,
        sim_chain_keep_n,
        sim_chain_keep_last = last ∘ sim_chain_keep_n,
        swap_contexts! = swap_contexts!)`
             
Replica Exchange Markov Chain Monte Carlo (REMCMC)
Version of [re!](@ref) that returns all chains, rather than just a single target.

Description:
- REMCMC is a Markov Chain Monte Carlo algorithm for sampling from the cartesian product 
  of a collection of `n` distributions given their respective densities.
- REMCMC works by running `n` independent MCMC chains in parallel for `samples_per_swap` steps using 
  a user-specified transition kernel (`sim_chain_keep_n`), and then subsequently proposing 
  a special transition kernel that swaps the position of parallel chains.
- REMCMC is agnostic to the user-specified transition kernel, as long as its stationary distribution
  is equal to the distribution corresponding to its respective input density. E.g. this permits HMC or RW-MCMC.
- A common use-case for REMCMC is when the target distribution is non-smooth and we would expect
  a single MCMC transition kernel to become stuck near a local optima. Then, the collection of distributions
  are induced by annealing the target distribution with a sequence of increasing temperatures.
- In this implementation we assume that `sim_chain_keep_n` is used for each of the `n` distributions.
- Note: re_all! mutates `states` and `samples`.

# Arguments
- `rng`: AbstractRng used to sample proposals in MH loop
- `logenergys`: collection of `n` logenergys (log unnormalized densities) to sample from. Each `logenergy = getindex(logenergys, i::Int64)`
  is a function from the domain of `states` to the reals.
- `samples_per_swap` : number of samples drawn between each exchange (i.e. swap)
- `num_swaps`: number of swaps
- `states`: initial states. Note: re does not mutate `states`.
- `sim_chain_keep_n` : algorithm to take `samples_per_swap` mcmc steps and return all n
  - should support `sim_chain_keep_n(rng, logenergy, init_state, samples_pre_swap, i)`
- `swap_contexts!` : optional mutating function that swaps contexts every `num_swaps`, i.e. performs the exchange between
  parallel chains.
  - should support `swap_contexts!(rng, logenergys, states)`
- `samples`: optional collection of samples from the target density to mutate

# Returns
- `n` samples drawn from ground state
"""

function re_all!(rng,
                 logenergys,
                 samples_per_swap,
                 num_swaps,
                 states,
                 sim_chain_keep_n,
                 swap_contexts! = swap_contexts!,
                 samples = [Vector{typeof(states[i])}(undef, num_swaps*samples_per_swap) for i = 1:length(states)])

  nreplicas = length(states)

  GROUNDID = 1
  for num_swap = 1:num_swaps
    lb = (num_swap - 1) * samples_per_swap + 1
    ub = lb + samples_per_swap - 1

    Threads.@sync for i = 1:nreplicas
      Threads.@spawn begin
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

@pre re_all!(rng, logenergys, samples_per_swap, num_swaps, states, sim_chain_keep_n) = num_swaps > 0 #"There must be at least 1 swap"
@pre re_all!(rng, logenergys, samples_per_swap, num_swaps, states, sim_chain_keep_n) = all([isa(logenergy, Function) for logenergy in logenergys]) "logenergys is a Function"
@pre re_all!(rng, logenergys, samples_per_swap, num_swaps, states, sim_chain_keep_n) = isa(sim_chain_keep_n, Function) "sim_chain_keep_n is a Function"
@pre re_all!(rng, logenergys, samples_per_swap, num_swaps, states, sim_chain_keep_n) = length(logenergys) == length(states) "Must have one density per initial state"
# usage of @cap and @ret in README of Spec.jl throws an error.
# @post re!(rng, logenergys, samples_per_swap, num_swaps, states, sim_chain_keep_n, sim_chain_keep_last, swap_contexts!) = (@cap(x), @ret) "Result is sorted version of input"