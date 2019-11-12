abstract type SSMHLoop <: Loop end
struct SSMHAlg <: SamplingAlgorithm end
"Single Site Metropolis Hastings"
const SSMH = SSMHAlg()

softhard(::Type{SSMHAlg}) = IsSoft{SSMHAlg}()

isapproximate(::SSMHAlg) = true

# defΩ(::SSMH) = SimpleΩ{Vector{Int}, Float64}

"Compute a score using the change in Prior of the *single* changed site"
function proposalkernel(kernel::Function, x)
  ∇logdensity(x) = x |> transform |> jacobian |> abs |> log
  before = ∇logdensity(x)
  proposed = kernel(x)
  after = ∇logdensity(proposed)
  ratio = after - before
  proposed, ratio 
end

normalkernel(rng, x, σ = 0.1) = proposalkernel(x) do x
        inv_transform(transform(x) + σ * randn(rng))
      end
# normalkernel(rng, x::Array, σ = 0.1) = normalkernel.(x, σ)

"Metropolized Independent sample"
mi(rng, x::T) where T = (rand(rng, T), 0.0)

"Changes a uniformly chosen single site with kernel"
function swapsinglesite(transitionkernel::Function, rng, ω)
  logtranstionp = 0.0
  function updater(x)
    result, logtranstionp = transitionkernel(x)
    result
  end
  update(ω, rand(1:nelem(ω)), updater), logtranstionp
end

"Changes a uniformly chosen single site with kernel"
swapsinglesite(rng, ω) = swapsinglesite(rng, ω) do x 
  mi(rng, x) 
end

function moveproposal(rng, ω)
  swapsinglesite(rng, ω) do x
    normalkernel(rng, x, 1.0)
  end
end


"""
Sample from `ω::Ω` conditioned on any constraints its conditioned on.

$(SIGNATURES)

# Arguments
- `x`: Real valued random variable
- `n`: Number of samples
- `logdensity`:  τ-valued `RandVar` s.t. logerr(τ) is defined
- `propsal`: function ω::Omega -> ω::Omega
- `ωinit`: Initial omega to start chain from
"""
function Base.rand(rng::AbstractRNG,
                   ΩT::Type{OT},
                   logdensity::RandVar,
                   n::Integer,
                   alg::SSMHAlg;
                   proposal = moveproposal,
                   ωinit = ΩT(),
                   offset = 0) where {OT <: Ω}
  ω = ωinit
  plast = logdensity(ω)
  qlast = 1.0
  ωsamples = OT[]
  accepted = 0
  for i = 1:n
    ω_, logtransitionp = isempty(ω) ? (ω,0) : proposal(rng, ω)
    p_ = logdensity(ω_)
    ratio = p_ - plast + logtransitionp
    if log(rand(rng)) < ratio
      ω = ω_
      plast = p_
      accepted += 1
    end
    push!(ωsamples, deepcopy(ω))
    lens(SSMHLoop, (ω = ω, accepted = accepted, p = plast, i = i + offset))
  end
  # println("accepted, ", accepted)
  ωsamples
end