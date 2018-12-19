struct SSMHAlg <: SamplingAlgorithm end
"Single Site Metropolis Hastings"
const SSMH = SSMHAlg()
isapproximate(::SSMHAlg) = true

# defΩ(::SSMH) = SimpleΩ{Vector{Int}, Float64}

normalkernel(x, σ = 0.1) = inv_transform(transform(x) + σ * randn())
normalkernel(x::Array, σ = 0.1) = normalkernel.(x, σ)

"Changes a single site with kernel"
swapsinglesite(ω, kernel = normalkernel) = update(ω, rand(1:nelem(ω)), kernel)

"""
Sample from `x` conditioned on any constraints its conditioned on.

Arguments
- `x`: Real valued random variable
- `n`: Number of samples
- `propsal`: function ω::Omega -> ω::Omega
- `ωinit`: Initial omega to start chain from
"""
function Base.rand(ΩT::Type{OT},
                   density::RandVar,
                   n::Integer,
                   alg::SSMHAlg;
                   proposal = swapsinglesite,
                   cb = donothing,
                   ωinit = ΩT()) where {OT <: Ω}
  ω = ωinit
  plast = density(ω)
  qlast = 1.0
  ωsamples = OT[]
  accepted = 0
  for i = 1:n
    ω_ = isempty(ω) ? ω : proposal(ω)
    p_ = density(ω_)
    ratio = p_ - plast
    if log(rand()) < ratio
      ω = ω_
      plast = p_
      accepted += 1
    end
    push!(ωsamples, deepcopy(ω))
    cb((ω = ω, accepted = accepted, p = plast, i = i), IterEnd)
  end
  ωsamples
end

function Base.rand(x::RandVar,
                   n::Integer,
                   alg::SSMHAlg,
                   ΩT::Type{OT};
                   proposal = swapsinglesite,
                   cb = donothing,
                   ωinit = ΩT())  where {OT <: Ω}
  density = logerr(indomain(x))
  map(ω -> applynotrackerr(x, ω),
      rand(ΩT, density, n, alg; proposal = proposal, cb = cb, ωinit = ωinit))
end