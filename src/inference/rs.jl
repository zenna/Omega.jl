"Rejection Sampling"
struct RejectionSampleAlg <: Algorithm end

"Rejection Sampling"
const RejectionSample = RejectionSampleAlg()

isapproximate(::RejectionSampleAlg) = false

# "Sample from `x | y == true` with rejection sampling"
# function Base.rand(ΩT::Type{OT}, y::RandVar, alg::Type{RejectionSample};
#                    n = 100,
#                    cb = default_cbs(n)) where {OT <: Ω}
#   cb = runall(cb)
#   samples = ΩT[]
#   accepted = 1
#   i = 1
#   while accepted < n
#     ω = ΩT()
#     if Bool(y(ω))
#       push!(samples, ω)
#       accepted += 1
#       cb(RunData(ω, accepted, 0.0, accepted), Outside)
#     else
#       cb(RunData(ω, accepted, 1.0, i), Outside)
#     end
#     i += 1
#   end
#   samples
# end

"`n` samples from `x` with rejection sampling"
function Base.rand(x::RandVar{T},
                   n::Integer,
                   alg::RejectionSampleAlg,
                   ΩT::Type{OT};
                   cb = donothing) where {T, OT}
  cb = runall(cb)
  samples = []
  accepted = 0
  i = 1
  while accepted < n
    ω = ΩT()
    xω = x(ω)
    if xω != nothing
      push!(samples, xω)
      accepted += 1
      cb(RunData(ω, accepted, 0.0, accepted), Outside)
    else
      cb(RunData(ω, accepted, 1.0, i), Outside)
    end
    i += 1
  end
  samples
end