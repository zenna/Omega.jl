module OmegaRE
# module ReplicaExchange
# import ..Ctx: ctxapl

export re, Replica, ReplicaAlg

"Replica Exchange (Parallel Tempering)"
struct ReplicaAlg end
const Replica = ReplicaAlg()

# defΩ(::ReplicaAlg) = Omega.LinearΩ{Vector{Int}, UnitRange{Int64}, Vector{Real}}
# defΩ(x, ::ReplicaAlg; inneralg...) = defΩ(inneralg)

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

"""
`re(rng, logdensity, n, ctxs, algs)`

Replica Exchange Markov Chain Monte Carlo

# Arguments
- `rng`: AbstractRng used to sample proposals in MH loop
- `logdensity`: density to sample from
- `n`: number of samples
- `algs`: Sampling algorithms, each should support
  - each alg should support `alg(ω, ctx)`
- `ctxs`: List of contexts where:
  - a context is an object that implements:
    1. `under(f, context)`
    2. I need to be able to compute in some context (e.g. temp), the logdensity of another point
  evalincontext(context, logdensity, ω)

"""
function re(rng,
            logdensity,
            n,
            ctxs,
            algs)
  # @pre length(ctxs) == length(algs)
  # n different contexts
  # need ability to:
  # - Simulate n MCMC steps in a given context 
  # - evaluate current state
  # Schedules
  # nsteps for eacs

  # Option 1: assume different
  # ωs = [ΩT() for ΩT in ΩTs]
  # Defer initialization to function
  for j = 1:div(n, swapevery)
    for i = 1:nreplicas
      # In context i take n/swapevery samples
      ctxpl(ctxs[i], rand(rng, ΩT, logdensity, swapevery, inneralg;
                             ωinit = ωs[i], algargs...))
      swap_contexts!(rng)
    end
  end
end


# """
# Replica Exchange (fixed kernel and varying temperatures)
# # Arguments
# - temps; list of temperatures
# - kα: parameterized kernel - mapping from temperature to kernel  
# """
# function Base.rand(rng::AbstractRng,
#                    logdensity::RandVar,
#                    n::Integer,
#                    temps,
#                    kα,
#                    algs)
#   kctxs = [KernelContext(kα(t)) for t in temps]
#   rand(rng, logdensity, n, kctxs, algs)
# end

# function Base.rand(rng::AbstractRNG,
#   ΩT::Type{OT},
#   logdensity::RandVar,
#   n::Integer,
#   alg::SSMHAlg;
#   proposal = moveproposal,
#   ωinit = ΩT(),
#   offset = 0) where {OT <: Ω}
# end

# function test()
#   θ = normal(0, 1)
#   x = normal(θ, 1)
#   rand(cond(θ, x ==\_s 3.0), 100, alg = Replica)
# end

# TODO
# - Should be async
# - Uses Threads
# - Swaps temperatures not omegas
# - Should support different algs
end # module
