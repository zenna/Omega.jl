"Rejection Sampling"
struct RejectionSampleAlg <: SamplingAlgorithm end

"Rejection Sampling"
const RejectionSample = RejectionSampleAlg()

isapproximate(::RejectionSampleAlg) = false

"`n` samples from `x` with rejection sampling"
function Base.rand(rng,
                   ΩT::Type{OT},
                   pred::RandVar,
                   n::Integer,
                   alg::RejectionSampleAlg;
                   cb = donothing) where {OT <: Ω}
  ωsamples = OT[]
  accepted = 0
  i = 1
  while accepted < n
    ω = ΩT() # FIXME, use rng to select random points
    issat = pred(ω)
    if issat
      push!(ωsamples, ω)
      accepted += 1
    end
    cb((ω = ω, accepted = accepted, p = float(issat), i = i), IterEnd)
    # lens(:loopend, (ω = ω, accepted = accepted, p = float(sat), i = i))
    i += 1
  end
  ωsamples
end
    
function Base.rand(rng::AbstractRNG,
                   x::RandVar,
                   n::Integer,
                   alg::RejectionSampleAlg;
                   ΩT::Type{OT} = defΩ(alg),
                   cb = donothing,
                   memoize = true) where {OT <: Ω}
  pred = Omega.mem(Omega.indomain(x))
  ωsamples = rand(rng, ΩT, pred, n, alg; cb = cb)
  map(Omega.mem(x), ωsamples)
end