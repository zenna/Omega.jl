abstract type SSMHLoop <: Loop end
struct SSMHAlg <: SamplingAlgorithm end
"Single Site Metropolis Hastings"
const SSMH = SSMHAlg()
isapproximate(::SSMHAlg) = true

# defΩ(::SSMH) = SimpleΩ{Vector{Int}, Float64}

normalkernel(rng, x, σ = 0.1) = inv_transform(transform(x) + σ * randn(rng))
normalkernel(rng, x::Array, σ = 0.1) = normalkernel.(x, σ)

"Metropolized Independent sample"
mi(rng, x::T) where T = rand(rng, T)

"Changes a uniformly chosen single site with kernel"
swapsinglesite(rng, ω, kernel = x -> mi(rng, x)) =
  update(ω, rand(1:nelem(ω)), kernel)

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
function Base.rand(rng,
                   ΩT::Type{OT},
                   logdensity::RandVar,
                   n::Integer,
                   alg::SSMHAlg;
                   proposal = swapsinglesite,
                   ωinit = ΩT(),
                   offset = 0) where {OT <: Ω}
  ω = ωinit
  plast = logdensity(ω)
  qlast = 1.0
  ωsamples = OT[]
  accepted = 0
  for i = 1:n
    ω_ = isempty(ω) ? ω : proposal(rng, ω)
    p_ = logdensity(ω_)
    ratio = p_ - plast
    if log(rand(rng)) < ratio
      ω = ω_
      plast = p_
      accepted += 1
    end
    push!(ωsamples, deepcopy(ω))
    lens(SSMHLoop, (ω = ω, accepted = accepted, p = plast, i = i + offset))
  end
  ωsamples
end