struct SSMHAlg <: SamplingAlgorithm end
"Single Site Metropolis Hastings"
const SSMH = SSMHAlg()
isapproximate(::SSMHAlg) = true

# defΩ(::SSMH) = SimpleΩ{Vector{Int}, Float64}

normalkernel(x, σ = 0.1) = inv_transform(transform(x) + σ * randn())
normalkernel(x::Array, σ = 0.1) = normalkernel.(x, σ)

function Base.rand(x::RandVar,
                   n::Integer,
                   alg::SSMHAlg,
                   ΩT::Type{OT};
                   proposal = normalkernel,
                   cb = donothing) where {OT <: Ω}
  ω = ΩT()
  xω, sb = applytrackerr(x, ω)
  plast = logerr(sb) # FIXME, rather than do transformaiton here, make function depend on real-valued random variable (maybe?)
  qlast = 1.0
  samples = [] #FIXME: Type
  accepted = 0
  for i = 1:n
    ω_ = if isempty(ω)
      ω
    else
      # FIXME: move randunifkey into propsoal
      resample(ω, randunifkey(ω), proposal)
    end
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
    cb((ω = ω, accepted = accepted, p = plast, i = i), IterEnd)
  end
  samples
end

function x()
  x = normal(0.0, 1.0, (3,))
  rand(x, sum(x) ==ₛ 0.0, 100; alg = SSMH)
end