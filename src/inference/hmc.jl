"Hamiltonian Monte Carlo Sampling"
abstract type HMC <: Algorithm end

defaultomega(::Type{HMC}) = Mu.SimpleOmega{Int, Float64}

# "ω ∉ [0, 1]"
# notunit(ω) = ω > 1.0 || ω < 0.0

"Hamiltonian monte carlo with leapfrog integration: https://arxiv.org/pdf/1206.1901.pdf"
function hmc(U, ∇U, nsteps, stepsize, current_q::Vector)
  q = transform(current_q)
  p = randn(length(q))
  current_p = p

  # Make a half step for momentum at beginning
  # Rejects proposals outside domain TODO: Something smarter
  # any(notunit, q) && return (current_q, false)
  invq = inv_transform(q)
  p = p - stepsize * ∇U(invq) .* jacobian(invq) / 2.0


  for i = 1:nsteps
    # Half step for the position and momentum
    q = q .+ stepsize .* p
    if i != nsteps
      # any(notunit, q) && return (current_q, false)
      invq = inv_transform(q)
      p = p - stepsize * ∇U(invq) .* jacobian(invq) ./ 2.0
    end
  end

  # Make half a step for momentum at the end
  # any(notunit, q) && return current_q, false
  invq = inv_transform(q)
  p = p .- stepsize .* ∇U(invq) .* jacobian(invq) ./ 2.0

  # Evaluate the potential and kinetic energies at start and end
  current_U = U(current_q)
  current_K =  sum(current_p.^2) / 2.0
  proposed_U = U(invq)
  proposed_K = sum(p.^2) / 2.0

  # @assert false
  if rand() < exp(current_U - proposed_U + current_K - proposed_K)
    return (invq, true) # accept ω
  else
    return (current_q, false)  # reject ω
  end
end

"Sample from `x | y == true` with Hamiltonian Monte Carlo"
function Base.rand(OmegaT::Type{OT}, y::RandVar{Bool}, alg::Type{HMC};
                   n=100,
                   nsteps = 10,
                   stepsize = 0.0001) where {OT <: Omega}
  ω = OmegaT()
  y(ω) # Initialize omega
  ωvec = linearize(ω)

  ωsamples = OmegaT[]
  # xsamples = T[] # FIXME: preallocate (and use inbounds)
  U(ω) = -logepsilon(y(ω))
  U(ωvec::Vector) = U(unlinearize(ωvec, ω))
  ∇U(ωvec) = gradient(y, ω, ωvec)

  accepted = 0.0

  m = div(n, 10)

  @showprogress 1 "Running HMC Chain" for i = 1:n
    ωvec, wasaccepted = hmc(U, ∇U, nsteps, stepsize, ωvec)
    # push!(xsamples, x(unlinearize(ωvec, ω)))
    push!(ωsamples, unlinearize(ωvec, ω))
    if wasaccepted
      accepted += 1.0
    end
    i % m == 0 && print_with_color(:light_blue,
                                   "acceptance ratio: $(accepted/float(i)) ",
                                   "Last log likelihood $(U(ω))\n")
  end
  print_with_color(:light_blue, "acceptance ratio: $(accepted/float(n))",
                                "Last log likelihood $(U(ω))\n")
  # xsamples
  ωsamples
end
