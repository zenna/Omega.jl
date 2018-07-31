"Metropolized Independent Sampling"
struct MIAlg <: Algorithm end
const MI = MIAlg()

isapproximate(::MIAlg) = true

"Sample `ω | y == true` with Metropolis Hasting"
function Base.rand(y::RandVar,
                   n,
                   alg::MIAlg,
                   ΩT::Type{OT};
                   cb = default_cbs(n),
                   hack = true) where {OT <: Ω}
  cb = runall(cb)
  ω = ΩT()
  plast = epsilon(y(ω))
  qlast = 1.0
  ωsamples = ΩT[]
  accepted = 0
  for i = 1:n
    ω_ = ΩT()
    p_ = epsilon(y(ω_))
    ratio = p_ / plast
    if rand() < ratio
      ω = ω_
      plast = p_
      accepted += 1
    end
    push!(ωsamples, ω)
    cb(RunData(ω, accepted, p_, i), Outside)
  end
  ωsamples
end