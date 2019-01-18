using Omega: withkernel, kseα

"Replica Exchange (Parallel Tempering)"
struct ReplicaAlg <: SamplingAlgorithm end

"Single Site Metropolis Hastings"
const Replica = ReplicaAlg()
defΩ(::ReplicaAlg) = Omega.LinearΩ{Vector{Int64}, Omega.Space.Segment, Real}

isapproximate(::ReplicaAlg) = true

function swap!(v, i, j)
  temp = v[i] 
  v[i] = v[j]
  v[j] = temp
end

"Swap adjacent chains"
function exchange!(rng, logdensity, ωs, temps)
  for i in length(ωs):-1:2
    j = i - 1
    E_i_x = withkernel(kseα(temps[i])) do
      logdensity(ωs[i])
    end
    E_j_x = withkernel(kseα(temps[j])) do
      logdensity(ωs[i])
    end
    E_i_y = withkernel(kseα(temps[i])) do
      logdensity(ωs[j])
    end
    E_j_y = withkernel(kseα(temps[j])) do
      logdensity(ωs[j])
    end
    k = (E_i_y + E_j_x) - (E_i_x + E_j_y)
    doswap = log(rand(rng)) < k
    if doswap
      swap!(ωs, i, j)
    end
  end
end

"Logarithmically spaced temperatures"
logtemps(n, k = 10) = exp.(k * range(-2.0, stop = 1.0, length = n))

"""Sample from `density` using Replica Exchange

$(SIGNATURES)

Replica exchange (aka parallel tempemring) runs `nreplicas` independent mcmc
chains in parallel.
Returns samples from lowest temperature chain

# Arguments
- `ΩT`: 
- `logdensity`: Real-valued `RandVar`
- `n`: Number of samples
- `swapevery` : performs swap every swapevery iterations
- `nreplicas` : number of replica chains to run
- `temps` : temperatures of different chains
- `inneralg` : Algorithm uses for each chain
- `algargs::NamedTuple` : keyword arguments to be passed to `inneralg` in:
   `rand(ΩT, density, swapevery, inneralg; algargs...)`
- `kernel`: Kernel to use for soft constraints (DEPRECATE ME)

# Returns

"""
function Base.rand(rng,
                   ΩT::Type{OT},
                   logdensity::RandVar,
                   n::Integer,
                   alg::ReplicaAlg;
                   inneralg = SSMH,
                   algargs = NamedTuple(),
                   swapevery = 1,
                   nreplicas = 4,
                   temps = logtemps(nreplicas),
                   kernel = Omega.kseα,
                   cb = donothing) where {OT <: Ω}
  @pre issorted(temps)
  @pre n % swapevery == 0
  @pre nreplicas == length(temps)
  @show temps
  ωsamples = OT[]
  ωs = [ΩT() for i = 1:nreplicas]

  # Do swapevery steps for each chain, then swap ωs
  for j = 1:div(n, swapevery)
    @show j
    for i = 1:nreplicas
      @show i
      withkernel(kernel(temps[i])) do
        try
          ωst = rand(rng, ΩT, logdensity, swapevery, inneralg; ωinit = ωs[i], cb = cb, algargs...)
          if i == length(ωs) # keep lowest temperatre
            append!(ωsamples, ωst)
          end
          ωs[i] = ωst[end]
        catch e
          println("Chain at temp $(temps[i]) Failed due to:", e)
        end
      end
    end
    exchange!(rng, logdensity, ωs, temps)
  end
  ωsamples
end