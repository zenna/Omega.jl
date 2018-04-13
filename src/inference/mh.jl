"Metropolized Hasing Sampling"
abstract type MH <: Algorithm end

"Sample from `x | y == true` with Metropolis Hasting"
function Base.rand(x::RandVar{T}, y::RandVar{Bool}, alg::Type{MH};
                   n::Integer = 1000) where T
  ω = DirtyOmega()
  plast = y(ω).epsilon
  qlast = 1.0
  samples = T[]
  accepted = 0.0
  @showprogress 1 "Running Chain" for i = 1:n
    ω_ = DirtyOmega()
    p_ = y(ω_).epsilon
    ratio = p_ / plast
    if rand() < ratio
      ω = ω_
      plast = p_
      accepted += 1.0
    end
    push!(samples, x(ω))
  end
  print_with_color(:light_blue,  "acceptance ratio: $(accepted/float(n))\n")
  samples
end