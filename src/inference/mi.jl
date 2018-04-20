"Metropolized Independent Sampling"
abstract type MI <: Algorithm end

"Sample from `x | y == true` with Metropolis Hasting"
function Base.rand(x::RandVar{T}, y::RandVar{Bool}, alg::Type{MI};
                   n::Integer = 1000, OmegaT::T2 = DefaultOmega) where {T, T2}
  ω = OmegaT()
  plast = y(ω).epsilon
  qlast = 1.0
  samples = T[]
  accepted = 0.0
  @showprogress 1 "Running Chain" for i = 1:n
    ω_ = OmegaT()
    p_ = y(ω_).epsilon
    ratio = p_ / plast
    if rand() < ratio
      ω = ω_
      plast = p_
      accepted += 1.0
    end
    push!(samples, x(ω))
    # lens(:end_iter, i, ratio, accepted)
  end
  print_with_color(:light_blue,  "acceptance ratio: $(accepted/float(n))\n")
  samples
end

Base.rand(x::RandVar, y::RandVar; kwargs...) = rand(x, y, MI; kwargs...)