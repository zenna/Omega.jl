"Rejection Sampling"
struct RejectionSampleAlg <: Algorithm end

"Rejection Sampling"
const RejectionSample = RejectionSampleAlg()

isapproximate(::RejectionSampleAlg) = false

"`n` samples from `x` with rejection sampling"
function Base.rand(x::RandVar{T},
                   n::Integer,
                   alg::RejectionSampleAlg,
                   ΩT::Type{OT};
                   cb = donothing) where {T, OT}
  samples = []
  accepted = 0
  i = 1
  while accepted < n
    ω = ΩT()
    xω = x(ω)
    if xω != nothing
      push!(samples, xω)
      accepted += 1
      cb(RunData(ω = ω, accepted = accepted, p = 0.0, i = i), Outside)
    else
      cb(RunData(ω = ω, accepted = accepted, p = 1.0, i = i), Outside)
    end
    i += 1
  end
  samples
end