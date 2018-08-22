"Rejection Sampling"
struct RejectionSampleAlg <: Algorithm end

"Rejection Sampling"
const RejectionSample = RejectionSampleAlg()

isapproximate(::RejectionSampleAlg) = false

"`n` samples from `x` with rejection sampling"
function Base.rand(x::RandVar,
                   n::Integer,
                   alg::RejectionSampleAlg,
                   ΩT::Type{OT};
                   cb = donothing) where {OT}
  samples = []
  accepted = 0
  i = 1
  while accepted < n
    ω = ΩT()
    xω, sat = trackerrorapply(x, ω, Wrapper(true))
    if sat
      push!(samples, xω)
      accepted += 1
      cb((ω = ω, sample = xω, accepted = accepted, p = 0.0, i = i), Outside)
    else
      cb((ω = ω, sample = xω, accepted = accepted, p = 1.0, i = i), Outside)
    end
    i += 1
  end
  [samples...]
end