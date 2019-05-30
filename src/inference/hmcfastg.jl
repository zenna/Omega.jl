"Hamiltonian Monte Carlo Sampling"
struct HMCFASTGAlg <: SamplingAlgorithm end

"Hamiltonian Monte Carlo Sampling"
const HMCFASTG = HMCFASTGAlg()
isapproximate(::HMCFASTGAlg) = true
defΩ(::Type{HMCFASTGAlg}) = SimpleΩ{Vector{Int}, Flux.TrackedArray{Float64, 1, Array{Float64,1}}}
defΩ(::HMCFASTGAlg) = SimpleΩ{Vector{Int}, Flux.TrackedArray{Float64, 1, Array{Float64,1}}}
defcb(::HMCFASTGAlg) = default_cbs()
# defcb = default_cbs(n)

"""Hamiltonian Monte Carlo with leapfrog integration: https://arxiv.org/pdf/1206.1901.pdf"""
function hmcfastG(rng, U, qvals, prop_qvals, pvals, ω, prop_ω, nsteps, stepsize, gradalg)
  # Initialise proposal as unbounded of current state
  foreach(qvals, prop_qvals) do q, prop_q @. prop_q = (q) end

  # Randomize the momentum
  foreach(p -> @.(p = randn()), pvals)

  # Current Kinetic Energy
  current_K =  sum(map(p->sum(p.^2), pvals)) / 2.0
  ∇qvals = gradient(U, prop_ω, gradalg)
  
  # Make a half step for momentum at beginning
  
  # Unbound
  foreach(prop_qvals) do prop_q @. prop_q = unbound(prop_q) end
  foreach((p, ∇q, prop_q) -> @.(p = p - stepsize * ∇q * jac(prop_q) / 2.0), 
  pvals, ∇qvals, prop_qvals)
  
  for i = 1:nsteps
    foreach(pvals, prop_qvals) do p, q @. q = q + stepsize * p end    
    κ = i !=  nsteps ? 1.0 : 0.5
    # Bound q
    foreach(prop_qvals) do prop_q @. prop_q = bound(prop_q) end 
    
    # Gradient step
    # ∇step!()
    ∇qvals = gradient(U, prop_ω, gradalg)
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

vals(x) = map(value, values(x))

"Sample from `x | y == true` with Hamiltonian Monte Carlo"
function Base.rand(rng::AbstractRNG,
                   ΩT::Type{OT},
                   logdensity::RandVar,
                   n::Integer,
                   alg::HMCFASTGAlg;
                   takeevery = 1,
                   nsteps = 10,
                   stepsize = 0.001,
                   ωinit = ΩT(),
                   gradalg = Omega.TrackerGrad,
                   offset = 0) where {OT <: Ω}
  ω = ωinit # Current Ω state of chain
  logdensity(ω)  # Initialize omega
  qvals = vals(ω)                               # Values as a vector

  prop_ω = deepcopy(ω)                          # Ω proposal
  prop_qvals = vals(prop_ω)                     # as vector

  p = deepcopy(ω)                     # Momentum, deepcopy but could just zero
  pvals = vals(p)                     # as vector
  
  ωsamples = ΩT[] 
  U = -logdensity

  accepted = 0
  for i = 1:n*takeevery
    p_, wasaccepted = hmcfastG(rng, U, qvals, prop_qvals, pvals, ω,
                          prop_ω, nsteps, stepsize, gradalg)
    if wasaccepted
      i % takeevery == 0 && push!(ωsamples, deepcopy(prop_ω))
      accepted += 1
      foreach(qvals, prop_qvals) do q, prop_q @. q = prop_q  end
    else
      # QVALS need to reflect
      i % takeevery == 0 && push!(ωsamples, deepcopy(ω))
    end
    lens(Loop, (ω = prop_ω, accepted = accepted, p = p, i = i + offset))
  end
  ωsamples
end
