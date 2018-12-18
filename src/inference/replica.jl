"Replica Exchange (Parallel Tempering)"
struct ReplicaAlg <: SamplingAlgorithm end

"Single Site Metropolis Hastings"
const Replica = ReplicaAlg()

"""
# Arguments
Ei - energy of chain i
Ej - energy of chain j
Ti - temperature of system i
Tj - temperature of system j
k - 
"""
function doexchange(Ei, Ej, k, Ti, Tj)
  p = rand()
  k = min(1, exp((Ei - Ej)*(1/k*Ti - 1/k*Tj)))
  p < k
end

"Swap adjacent chains"
function exchange!(ωs, temps, es; k = 1.0)
  @show es, temps
  for i in 1:2:length(ωs)
    j = i + 1
    # @showes[i], es[j], k, temps[i], temps[j]
    if doexchange(es[i], es[j], k, temps[i], temps[j])
      temp = ωs[i]
      ωs[i] = ωs[j]
      ωs[j] = temp
      println("Swapping $i with $j")
    else
      println("Not swapping!")
    end
  end
end

"""Sample from `x` using Replica Exchange

Replica exchange (aka parallel tempemring) runs `nreplicas` independent mcmc
chains in parallel.
Returns samples from lowest temperature chain

# Arguments
- swapevery : performs swap every swapevery iterations
- nreplicas : number of replica chains to run
- temps : temperatures 
# Returns

"""
function Base.rand(x::RandVar,  # This should just be the error randvar
                   n::Integer,
                   alg::ReplicaAlg,
                   ΩT::Type{OT};
                   inneralg = SSMH,
                   algargs = NamedTuple(),
                   swapevery = 1,
                   nreplicas = 4,
                   temps = exp.(23*range(0.0, stop = 1.0, length = nreplicas)),
                   kernel = Omega.kseα,
                   cb = donothing) where {OT <: Ω}
  # @pre issorted(temps)
  # @pre n % swapevery == 0
  # @pre nreplicas == length(temps)

  ωsamples = OT[]
  ωs = [ΩT() for i = 1:nreplicas]

  # Do swapevery steps for each chain, then swap ωs
  for j = 1:div(n, swapevery)
    for i = 1:nreplicas
      ωst = Omega.withkernel(kernel(temps[i])) do
        rand(x, swapevery, inneralg, ΩT; ω = ωs[i], cb = cb, algargs...)
      end
      if i == length(ωs) # keep lowest temperatre
        append!(ωsamples, ωst)
      end
      ωs[i] = ωst[end]
    end
    exchange!(ωs, temps, map(ω -> logerr(indomain(x, ω)), ωs))
  end
  ωsamples
end
