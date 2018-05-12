"Hamiltonian Monte Carlo Sampling"
abstract type HMC <: Algorithm end

defaultomega(::Type{HMC}) = Mu.SimpleOmega{Int, Float64}


"Hamiltonian monte carlo with leapfrog integration: https://arxiv.org/pdf/1206.1901.pdf"
function hmc(U, ∇U, nsteps, stepsize, current_q::Vector, cb)
  # current_q = [0.2, 0.2]
  q = transform(current_q)
  p = randn(length(q))
  # p = [0.2, 0.2]
  current_p = p

  

  # Make a half step for momentum at beginning
  # Rejects proposals outside domain TODO: Something smarter
  # any(notunit, q) && return (current_q, false)
  invq = inv_transform(q)
  # p = p - stepsize * ∇U(invq) .* jacobian(invq) / 2.0

  for i = 1:nsteps
    cb(QP(q, p), Inside)
    # Half step for the position and momentum
    q = q .+ stepsize .* p
    # @show mean(stepsize .* p), mean(q)
    if i != nsteps
      # any(notunit, q) && return (current_q, false)
      invq = inv_transform(q)
      @show p
      @show q
      @show invq  
      @show ∇U(invq)
      @show ∇U(invq) .* jacobian(invq)
      p = p - stepsize * ∇U(invq) .* jacobian(invq) ./ 2.0
    end
  end
  # @assert false

  # Make half a step for momentum at the end
  # any(notunit, q) && return current_q, false
  invq = inv_transform(q)
  p = p .- stepsize .* ∇U(invq) .* jacobian(invq) ./ 2.0

  # Evaluate the potential and kinetic energies at start and end
  current_U = U(current_q)
  current_K =  sum(current_p.^2) / 2.0
  proposed_U = U(invq)
  proposed_K = sum(p.^2) / 2.0

  @show current_p
  @show p

  H_current = current_U + current_K
  H_proposed = proposed_U + proposed_K
  @show H_proposed - H_current
  # @assert false

  # @show current_U, proposed_U, current_K,  proposed_K
  # @show  exp(current_U - proposed_U + current_K - proposed_K)

  # @assert false
  # if rand() < exp(current_U - proposed_U)
  if rand() < exp(current_U - proposed_U + current_K - proposed_K)
    println("accepted ")
    return (proposed_U, invq, true) # accept ω
  else
    println("rejected")
    return (current_U, current_q, false)  # reject ω
  end
end

"Sample from `x | y == true` with Hamiltonian Monte Carlo"
function Base.rand(OmegaT::Type{OT}, y::RandVar, alg::Type{HMC};
                   n = 100,
                   nsteps = 10,
                   stepsize = 0.001,
                   cb = default_cbs(n)) where {OT <: Omega}
  cb = runall(cb)
  ω = OmegaT()
  y(ω) # Initialize omega
  ωvec = linearize(ω)

  ωsamples = OmegaT[]
  U(ω) = -logepsilon(y(ω))
  U(ωvec::Vector) = U(unlinearize(ωvec, ω))
  ∇U(ωvec) = gradient(y, ω, ωvec)

  accepted = 1
  for i = 1:n
    p_, ωvec, wasaccepted = hmc(U, ∇U, nsteps, stepsize, ωvec, cb)
    ω_ = unlinearize(ωvec, ω)
    push!(ωsamples, unlinearize(ωvec, ω))
    if wasaccepted
      accepted += 1
    end
    cb(RunData(ω_, accepted, p_, i), Outside)
  end
  ωsamples
end
