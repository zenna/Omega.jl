"Flux based Hamiltonian Monte Carlo Sampling"
struct HMCFASTAlg <: SamplingAlgorithm end

"Flux based Hamiltonian Monte Carlo Sampling"
const HMCFAST = HMCFASTAlg()
isapproximate(::HMCFASTAlg) = true
defΩ(::Type{HMCFASTAlg}) = SimpleΩ{Vector{Int}, Flux.TrackedArray{Float64, 1, Array{Float64,1}}}
defΩ(::HMCFASTAlg) = SimpleΩ{Vector{Int}, Flux.TrackedArray{Float64, 1, Array{Float64,1}}}
defcb(::HMCFASTAlg) = default_cbs()
# defcb = default_cbs(n)

"""Hamiltonian monte carlo with leapfrog integration:
https://arxiv.org/pdf/1206.1901.pdf"""
function hmcfast(rng, U, ∇U, qvals, prop_qvals, pvals, ω, prop_ω, nsteps, stepsize)
  # Initialise proposal as unbounded of current state
  foreach(qvals, prop_qvals) do q, prop_q @. prop_q = (q) end

  # Randomize the momentum
  foreach(p -> @.(p = randn()), pvals)

  # Current Kinetic Energy
  current_K =  sum(map(p->sum(p.^2), pvals)) / 2.0
  ∇qvals = [x.grad for x in values(prop_ω)]
  function ∇step()
    foreach(∇qvals) do ∇q @. ∇q = 0 end  # reset gradients
    ∇U(prop_ω)  # Gradient step
  end
  
  # Make a half step for momentum at beginning
  
  ∇step()
  # Unbound
  foreach(prop_qvals) do prop_q @. prop_q = unbound(prop_q) end
  foreach((p, ∇q, prop_q) -> @.(p = p - stepsize * ∇q * jac(prop_q) / 2.0), 
  pvals, ∇qvals, prop_qvals)
  
  for i = 1:nsteps
    # @show prop_qvals
    # Half step p and q
    # @show prop_qvals 
    foreach(pvals, prop_qvals) do p, q @. q = q + stepsize * p end    
    # @show prop_qvals
    κ = i !=  nsteps ? 1.0 : 0.5
    # Bound q
    foreach(prop_qvals) do prop_q @. prop_q = bound(prop_q) end 
    
    # Gradient step
    ∇step()
    # Unbound q
    foreach(prop_qvals) do prop_q @. prop_q = unbound(prop_q) end
    foreach(pvals, ∇qvals, prop_qvals) do p, ∇q, q 
      @. p = p - κ * stepsize * ∇q * jac(q)
    end
  end
  
  # Make half a step for momentum at the end
  # any(notunit, q) && return current_q, false
  foreach(prop_qvals) do prop_q @. prop_q = bound(prop_q) end
  
  # @assert false
  # Evaluate the potential and kinetic energies at start and end
  current_U = U(ω)
  proposed_U = U(prop_ω)
  proposed_K = sum(map(p->sum(p.^2), pvals)) / 2.0

  #@show current_U, proposed_U, current_K, proposed_K
  # Accept or reject
  if log(rand(rng)) < current_U - proposed_U + current_K - proposed_K
    (proposed_U, true)
  else
    (current_U, false)
  end
end

"Sample from `x | y == true` with Hamiltonian Monte Carlo"
function Base.rand(rng::AbstractRNG,
                   ΩT::Type{OT},
                   logdensity::RandVar,
                   n::Integer,
                   alg::HMCFASTAlg;
                   takeevery = 1,
                   nsteps = 10,
                   stepsize = 0.001,
                   ωinit = ΩT(),
                   gradalg = Omega.FluxGrad,
                   offset = 0) where {OT <: Ω}
  ω = ωinit # Current Ω state of chain
  logdensity(ω)  # Initialize omega
  qvals = [x.data for x in values(ω)]   # Values as a vector

  prop_ω = deepcopy(ω)                          # Ω proposal
  prop_qvals = [x.data for x in values(prop_ω)] # as vector

  p = deepcopy(ω)                     # Momentum, deepcopy but could just zero
  pvals = [x.data for x in values(p)] # as vector
  
  ωsamples = ΩT[] 
  U = -logdensity
  ∇U(ω) = Omega.back!(U, ω, gradalg)

  accepted = 0
  for i = 1:n*takeevery
    p_, wasaccepted = hmcfast(rng, U, ∇U, qvals, prop_qvals, pvals, ω,
                          prop_ω, nsteps, stepsize)
    if wasaccepted
      i % takeevery == 0 && push!(ωsamples, deepcopy(prop_ω))
      accepted += 1
      foreach(qvals, prop_qvals) do q, prop_q @. q = prop_q  end
    else
      # QVALS need to reflect
      i % takeevery == 0 && push!(ωsamples, deepcopy(ω))
    end
    lens(Loop, (ω = prop_ω, accepted = accepted, p = Flux.data(p_), i = i + offset))
  end
  ωsamples
end
