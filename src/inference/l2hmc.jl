"L2 Hamiltonian Monte Carlo Sampling"
abstract type L2HMC <: Algorithm end

function loss_fn(x, newx, p, λ)
  d = sum((x - newx).^2) * p
  return λ / d - d / λ
end

function mh_step(x, newx, p)
  if rand() < p
    return newx       # accept
  else
    return x          # reject
  end

"Training of parameterized Hamiltonian monte carlo sampler L2HMC: https://arxiv.org/pdf/1711.09268.pdf"
function train_l2hmc(U, ∇U, init_dist, niters, nbatch, lr, scale_λ, reg_λ)
  x = init_dist(nbatch)
  dim = length(x[0])

  for t = 1:niters
    loss = 0
    z = init_dist(nbatch)
    for i = 1:nbatch
      v = randn(dim); vz = randn(dim)
      newx, newv, p = hmc_update(U, ∇U, x[i], v, i)
      newz, newvz, pz = hmc_update(U, ∇U, z[i], vz, i)
      loss += loss_fn(x[i], v, newx, newv, p, scale_λ) + reg_λ * loss_fn(z[i], vz, newz, newvz, pz, scale_λ)
      x[i] = mh_step(x[i], newx, p)
    end
    # TODO: update parameters according to loss
  end

end


"Sample from `x | y == true` with Hamiltonian Monte Carlo"
function Base.rand(x::RandVar{T}, y::RandVar{Bool}, alg::Type{HMC};
                   n=1000, nsteps = 100, stepsize = 0.0001) where T
  ω = DiffOmega()
  y(ω) # Initialize omega
  ωvec = tovector(ω)

  xsamples = T[] # FIXME: preallocate (and use inbounds)
  U(ω::DiffOmega) = -log(y(ω).epsilon)
  U(ωvec::Vector) = U(todiffomega(ωvec, ω))
  ∇U(ωvec) = gradient(y, ω, ωvec)

  accepted = 0.0

  @showprogress 1 "Running HMC Chain" for i = 1:n
    ωvec, wasaccepted = hmc(U, ∇U, nsteps, stepsize, ωvec)
    push!(xsamples, x(todiffomega(ωvec, ω)))
    if wasaccepted
      accepted += 1.0
    end
  end
  print_with_color(:light_blue,  "acceptance ratio: $(accepted/float(n))\n")
  xsamples
end
