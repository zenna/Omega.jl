"Single Site MH"
abstract type SSMH <: Algorithm end

"Sample from `x | y == true` with Single Site Metropolis Hasting"
function Base.rand(x::RandVar{T}, y::RandVar{<:MaybeSoftBool},
                   alg::Type{SSMH};
                   n::Integer = 1000,
                   OmegaT = DiffOmega) where T
  ω = OmegaT()
  plast = y(ω).epsilon
  qlast = 1.0
  samples = T[]
  accepted = 0.0
  @showprogress 1 "Running Chain" for i = 1:n
    ω_ = if isempty(ω)
      ω
    else
      update_random(ω)
    end
    p_ = y(ω_).epsilon
    ratio = p_ / plast
    if rand() < ratio
      ω = ω_
      plast = p_
      accepted += 1.0
    end
    push!(samples, x(ω))
  end
  print_with_color(:light_blue, "acceptance ratio: $(accepted/float(n))\n")
  @show ω.d
  samples
end
