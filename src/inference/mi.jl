"Metropolized Independent Sampling"
abstract type MI <: Algorithm end

isapproximate(::Type{MI}) = true

"Sample `ω | y == true` with Metropolis Hasting"
function Base.rand(ΩT::Type{OT}, y::RandVar, alg::Type{MI};
                   n = 1000,
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

# "Sample from `x | y == true` with Metropolis Hasting"
# function Base.rand(x::RandVar{T}, y::RandVar{Bool}, alg::Type{MI};
#                    n::Integer = 1000, ΩT::OT = DefaultΩ) where {T, OT}
#   map(x, rand(ΩT, y, alg, n=n))
# end

Base.rand(x::Union{RandVar, UTuple{RandVar}}, y::RandVar; kwargs...) = rand(x, y, MI; kwargs...)