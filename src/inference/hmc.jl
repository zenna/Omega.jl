"Hamiltonian Monte Carlo Sampling"
abstract type HMC <: Algorithm end

gradient(y, ω) = ω

"Sample from `x | y == true` with Hamiltonian Monte Carlo"
function Base.rand(x::RandVar{T}, y::RandVar{Bool}, alg::Type{HMC};
                   L::Integer = 100, ϵ::Float = 0.1) where T
  lastω = DiffOmega()
  ω = lastω
  lastm = Dict()
  for (key, cv) in enumerate(ω)
    dim = cv.count
    lastm[key] = Vector()
    for i = 1:dim
      push!(lastm[key], rand(normal(0, 1)))
    end
  end
  m = lastm
  # do a half step
  grad = gradient(y, ω)
  for (key, cv) in enumerate(ω)
    m[key] = m[key] - ϵ * grad[key] / 2
  end

  for i = 1:L
    grad = gradient(y, ω)
    for (key, cv) in enumerate(ω)
      ω[key] = ω[key] + ϵ * m[key]
      if i != L
        m[key] = m[key] - ϵ * grad[key]
      end
    end
  # do another half step
  grad = gradient(y, ω)
  for (key, cv) in enumerate(ω)
    m[key] = m[key] - ϵ * grad[key] / 2
  end

  lastp = y(lastω).epsilon
  currentp = y(ω).epsilon
  lastk = 0; currentk = 0
  for (key, cv) in enumerate(lastm)
    lastk = lastk + sum(lastm[key].^2) / 2
    currentk = currentk + sum(m[key].^2) / 2
  end

  if rand() < exp(lastp - currentp + lastk - currentk)
    return x(ω)       # accept ω
  else
    return x(lastω)   # reject ω
  end
end
