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
                   alg::RejectionSampleAlg) where {OT <: Ω}
  ωsamples = OT[]
  accepted = 0
  i = 1
  while accepted < n
    ω = ΩT() # FIXME, use rng to select random points
    issat = pred(Omega.Space.tagrng(ω, rng))
    if issat
      push!(ωsamples, ω)
      accepted += 1
    end
    # cb((ω = ω, accepted = accepted, p = float(issat), i = i), IterEnd)
    lens(Loop, (ω = ω, accepted = accepted, p = float(issat), i = i))
    i += 1
  end
  ωsamples
end
    
function Base.rand(rng::AbstractRNG,
                   x::RandVar,
                   n::Integer,
                   alg::RejectionSampleAlg;
                   ΩT::Type{OT} = defΩ(alg),
                   memoize = true) where {OT <: Ω}
  pred = Omega.mem(Omega.indomain(x))
  ωsamples = rand(rng, ΩT, pred, n, alg)
  map(Omega.mem(x), ωsamples)
end