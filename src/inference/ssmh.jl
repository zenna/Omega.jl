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
- `x`: Random variablet o sample from
- `n`: Number of samples
- `propsal`: function ω::Omega -> ω::Omega
- ω`: Initial omega
"""
function Base.rand(x::RandVar,
                   n::Integer,
                   alg::SSMHAlg,
                   ΩT::Type{OT};
                   proposal = swapsinglesite,
                   cb = donothing,
                   ω = ΩT()) where {OT <: Ω}
  xω, sb = applytrackerr(x, ω)
  plast = logerr(sb) # FIXME, rather than do transformaiton here, make function depend on real-valued random variable (maybe?)
  qlast = 1.0
  samples = [] #FIXME: Type, remove
  ωsamples = OT[]
  accepted = 0
  for i = 1:n
    ω_ = isempty(ω) ? ω : proposal(ω)
    xω_, sb = applytrackerr(x, ω_)
    p_ = logerr(sb)
    ratio = p_ - plast
    if log(rand()) < ratio
      ω = ω_
      plast = p_
      accepted += 1
      xω = xω_
    end
    push!(samples, xω)
    push!(ωsamples, deepcopy(ω))
    cb((ω = ω, accepted = accepted, p = plast, i = i), IterEnd)
  end
  # samples
  ωsamples
end