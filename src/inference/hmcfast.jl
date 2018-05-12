"Flux based Hamiltonian Monte Carlo Sampling"
abstract type HMCFAST <: Algorithm end

defaultomega(::Type{HMCFAST}) = Mu.SimpleOmega{Int, Flux.TrackedArray}

"""Hamiltonian monte carlo with leapfrog integration:
https://arxiv.org/pdf/1206.1901.pdf"""
function hmcfast(U, ∇U, qvals, prop_qvals, pvals, ω, prop_ω, nsteps, stepsize, cb)
  # Initialise proposal as unbounded of current state
  foreach(qvals, prop_qvals) do q, prop_q @. prop_q = (q) end
  
  # Randomize the momentum
  foreach(p -> @.(p = randn()), pvals)

  # Current Kinetic Energy
  current_K =  sum(map(p->sum(p.^2), pvals)) / 2.0
 
  # Make a half step for momentum at beginning
  ∇qvals = [x.grad for x in values(prop_ω)]
  ∇U(prop_ω)  # Gradient step
  foreach((p, ∇q) -> @.(p = p - stepsize * ∇q * jac(∇q) / 2.0), pvals, ∇qvals)

  # Unbound
  foreach(prop_qvals) do prop_q @. prop_q = unbound(prop_q) end

  for i = 1:nsteps
    cb(QP(prop_qvals, pvals), Inside)
    # @show prop_qvals
    # Half step p and q 
    foreach(pvals, prop_qvals) do p, q @. q = q + stepsize * p end    
    if i != nsteps
      # Bound q
      foreach(prop_qvals) do prop_q @. prop_q = bound(prop_q) end 

      # Gradient step
      ∇U(prop_ω)
      foreach(pvals, ∇qvals) do p, ∇q @. p = p - stepsize * ∇q * jac(∇q) / 2.0 end

      # Unbound q
      foreach(prop_qvals) do prop_q @. prop_q = unbound(prop_q) end
    end
  end
  # @assert false

  # Make half a step for momentum at the end
  # any(notunit, q) && return current_q, false
  foreach(prop_qvals) do prop_q @. prop_q = bound(prop_q) end
  foreach(pvals, ∇qvals) do p, ∇q @. p = p - stepsize * ∇q * jac(∇q) / 2.0 end

  # Evaluate the potential and kinetic energies at start and end
  current_U = U(ω)
  proposed_U = U(prop_ω)
  proposed_K = sum(map(p->sum(p.^2), pvals)) / 2.0

  # Accept or reject
  rand() < exp(current_U - proposed_U + current_K - proposed_K)
end

"Sample from `x | y == true` with Hamiltonian Monte Carlo"
function Base.rand(OmegaT::Type{OT}, y::RandVar, alg::Type{HMCFAST};
                   n = 100,
                   nsteps = 10,
                   stepsize = 0.001,
                   cb = default_cbs(n)) where {OT <: Omega}
  cb = runall(cb)
  ω = OmegaT()        # Current Omega state of chain
  y(ω)                # Initialize omega
  qvals = [x.data for x in values(ω)]   # Values as a vector
  # @grab ω

  prop_ω = deepcopy(ω)                          # Omega proposal
  prop_qvals = [x.data for x in values(prop_ω)] # as vector

  p = deepcopy(ω)                     # Momentum, deepcopy but could just zero
  pvals = [x.data for x in values(p)] # as vector
  
  ωsamples = OmegaT[] 
  U(ω) = -logepsilon(y(ω))
  ∇U(ω) = fluxgradient(y, ω)

  accepted = 0
  for i = 1:n
    wasaccepted = hmcfast(U, ∇U, qvals, prop_qvals, pvals, ω,
                          prop_ω, nsteps, stepsize, cb)
    if wasaccepted
      push!(ωsamples, deepcopy(prop_ω))
      accepted += 1
      foreach(qvals, prop_qvals) do q, prop_q @. q = prop_q  end
    else
      # QVALS need to reflect
      push!(ωsamples, deepcopy(ω))
    end
    cb(RunData(prop_ω, accepted, 1.0, i), Outside)
  end
  ωsamples
end