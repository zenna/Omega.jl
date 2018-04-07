## Sampling and Inference
## ======================
"Unconditional Sample from `x`"
Base.rand(x::RandVar) = x(Omega())

"Unconditional Sample from `x`"
function Base.rand(x::NTuple{N, RandVar}) where N
  ω = Omega()
  applymany(x, ω)
end

"Sample from `x | y == true` with rejection sampling"
function Base.rand(x::RandVar, y::RandVar{Bool}, alg::Type{RejectionSample})
  while true
    ω = Omega()
    if y(ω)
      return x(ω)
    end
  end
end

"Sample from `x | y == true` with Metropolis Hasting"
function Base.rand(x::RandVar{T}, y::RandVar{<:MaybeSoftBool},
                   alg::Type{MH};
                   n::Integer = 1000) where T
  ω = Omega()
  plast = y(ω).epsilon
  qlast = 1.0
  samples = T[]
  accepted = 0.0
  @showprogress 1 "Running Chain" for i = 1:n
    ω_ = Omega()
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

"Sample from `x | y == true` with Single Site Metropolis Hasting"
function Base.rand(x::RandVar{T}, y::RandVar{<:MaybeSoftBool},
                   alg::Type{SSMH};
                   n::Integer = 1000) where T
  ω = Omega()
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

"Default rand (rejection sample)"
Base.rand(x, y) = rand(x, y, RejectionSample)
