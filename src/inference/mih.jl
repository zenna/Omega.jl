"Metropolized Independent Sampling"
abstract type MIH <: Algorithm end

"Sample from `x | y == true` with Metropolis Hasting"
function Base.rand(x::RandVar{T}, y::RandVar{Bool}, alg::Type{MIH};
                   n::Integer = 1000) where T
  ω = DictOmega()
  plast = y(ω).epsilon
  qlast = 1.0
  samples = T[]
  accepted = 0.0
  @showprogress 1 "Running Chain" for i = 1:n
    ω_ = DictOmega()
    p_ = y(ω_).epsilon
    ratio = p_ / plast
    if rand() < ratio
      if y(ω).epsilon == best
        @show "Down!" best, p_, ratio, x(ω), x(ω_)
      end
      ω = ω_
      plast = p_
      accepted += 1.0
    end
    push!(samples, x(ω))
  end
  print_with_color(:light_blue,  "acceptance ratio: $(accepted/float(n))\n")
  samples
end

Base.rand(x::RandVar, y::RandVar; kwargs...) = rand(x, y, MH; kwargs...)