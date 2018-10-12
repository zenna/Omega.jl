"Replica Exchange (Parallel Tempering)"
struct ReplicaAlg end

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
  exp((Ei - Ej)*(1/k*Ti - 1/k*Tj))
end

"exhanged"
function exchange!(ωs, temps, es)
  for (ω1, ω2) in ω
    if doexhange(e1, e2, t1, t2)
      println("Replica switch")
    else
      println("Replica switch")
    end
  end
end

"""Sample from `x` using Replica Exchange

Replica exchange (aka parallel tempemring) runs `nreplicas` independent mcmc
chains in parallel

# Arguments
- swapevery : performs swap every swapevery iterations
- nreplicas : number of replica chains to run
- temps : temperatures 
# Returns

"""
function Base.rand(x::RandVar,
                   n::Integer,
                   alg::ReplicaAlg,
                   ΩT::Type{OT};
                   algs,
                   swapevery = 1,
                   nreplicas = 2,
                   temps = sort([rand() for i = 1:nreplicas]),
                   cb = donothing) where {OT <: Ω}

  ωssamples = OT[]
  ωs = [ΩT() for i = 1:nreplicas]
  for i = 1:nreplicas
    withkernel() do
      rand(ΩT, x, swapevery, alg, ω)
    end
    exchange!(ωs, temps, map(x, ωs))
  end
  ωssamples
end

