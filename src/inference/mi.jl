"Metropolized Independent Sampling"
abstract type MI <: Algorithm end

"Sample `ω | y == true` with Metropolis Hasting"
function Base.rand(OmegaT::Type{OT}, y::RandVar, alg::Type{MI};
                   n::Integer = 1000) where {OT <: Omega}
  ω = OmegaT()
  plast = epsilon(y(ω))
  qlast = 1.0
  ωsamples = OmegaT[]
  accepted = 0.0
  @showprogress 1 "Running Chain" for i = 1:n
    ω_ = OmegaT()
    p_ = epsilon(y(ω_))
    ratio = p_ / plast
    if rand() < ratio
      ω = ω_
      plast = p_
      accepted += 1.0
    end
    push!(ωsamples, ω)
    # lens(:end_iter, i, ratio, accepted)
  end
  print_with_color(:light_blue,  "acceptance ratio: $(accepted/float(n))\n")
  ωsamples
end

# "Sample from `x | y == true` with Metropolis Hasting"
# function Base.rand(x::RandVar{T}, y::RandVar{Bool}, alg::Type{MI};
#                    n::Integer = 1000, OmegaT::OT = DefaultOmega) where {T, OT}
#   map(x, rand(OmegaT, y, alg, n=n))
# end

Base.rand(x::Union{RandVar, UTuple{RandVar}}, y::RandVar; kwargs...) = rand(x, y, MI; kwargs...)