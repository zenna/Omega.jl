import ..Gradient
using ..Gradient: value, grad

"Hamiltonian Monte Carlo Sampling"
struct HMCFASTGAlg <: SamplingAlgorithm end

"Hamiltonian Monte Carlo Sampling"
const HMCFASTG = HMCFASTGAlg()
defΩ(::Type{HMCFASTGAlg}) = SimpleΩ{Vector{Int}, Flux.TrackedArray{Float64, 1, Array{Float64,1}}}
defΩ(::HMCFASTGAlg) = SimpleΩ{Vector{Int}, Flux.TrackedArray{Float64, 1, Array{Float64,1}}}
defcb(::HMCFASTGAlg) = default_cbs()

# Issues:
# 1. unbound should be parameterized 
# 2. Don't want to recompute keys
# 3. gradient

# Let me summarize the issues with gradient
# If we have purely functional interface, which just returns gradient
# The signature doesn't quite work
# I can't define a generic function gradient(::RandVar, ::Array{Array}, ::GradAlg)
# Because we would need to know how to go from the array{array} to the omega
# One option is to have a kind of structure

# Inefficiencies
# dots.  but better to leave them in and wait
# 

struct ΩView{O, A}
  ω::O
  arr::A
end

Gradient.grad(rv, ωv::ΩView, T) = Gradient.grad(rv, ωv.ω, T)

ΩView(ω::Ω) = ΩView(ω, [value(x) for x in values(ω)])
Base.getindex(ωv::ΩView, i) = ωv.arr[i]
Base.setindex!(ωv::ΩView, v, i) = ωv.arr[i] = v
Base.keys(ωw::ΩView) = keys(ωw.arr)

"""Hamiltonian Monte Carlo with leapfrog integration: https://arxiv.org/pdf/1206.1901.pdf"""
function hmcfastG(rng, U, q, prop_q, p, ω, nsteps, stepsize, gradalg)
  ids = keys(prop_q) # zt: compute this once

  # Unbound: Maps proposals in [0, 1] to R
  unbound!() = for i in ids; @inbounds prop_q[i] .= unbound.(prop_q[i]) end

  # bound: Maps values in R to [0, 1]
  bound!() = for i in ids; @inbounds prop_q[i] .= bound.(prop_q[i]) end

  # Initialise proposal as unbounded of current state
  for i in ids; @inbounds prop_q[i] .= q[i] end

  # Randomize the momentum
  for i in ids; @inbounds p[i] .= @show rand(rng) end

  # Current Kinetic Energy
  current_K =  sum(map(p->sum(p.^2), p.arr)) / 2.0
  ∇q = grad(U, prop_q, gradalg)
  @show ∇q[1]
  
  # Make a half step for momentum at beginning
  unbound!()
  for i in ids; @inbounds p[i] .= p[i] .- stepsize .* ∇q[i] .* jac.(prop_q[i]) ./ 2.0 end
  
  for i = 1:nsteps
    for i in ids; @inbounds prop_q[i] .= prop_q[i] .+ stepsize .* p[i] end

    κ = i !=  nsteps ? 1.0 : 0.5
    bound!()

    # grad step
    ∇q = grad(U, prop_q, gradalg)
    unbound!()
    for i in ids; @inbounds p[i] .= p[i] .- κ .* stepsize .* ∇q[i] .* jac.(q[i]) end
  end
  
  # Make half a step for momentum at the end
  bound!()

  # zt: separate out accept reject phase
  
  # Evaluate the potential and kinetic energies at start and end
  current_U = U(ω) # zt I'm computing this twice
  proposed_U = U(q.ω)
  proposed_K = sum(map(p->sum(p.^2), p.arr)) / 2.0

  #@show current_U, proposed_U, current_K, proposed_K
  # Accept or reject
  if log(rand(rng)) < current_U - proposed_U + current_K - proposed_K
    # Make current state proposed state
    for id in ids; q[id] .= prop_q[id]  end
    (proposed_U, true) # zt: make named tuple
  else
    (current_U, false)
  end
end

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
  ω = ωinit        # Current Ω state of chain
  logdensity(tagrng(ω, rng))           # Initialize omega
  q = ΩView(ω)                  # Position 
  prop_q = ΩView(deepcopy(ω))   # Proposal Position
  p = ΩView(deepcopy(ω))        # Momentum, deepcopy but could just zero
  
  ωsamples = ΩT[]               # Output samples
  U = -logdensity               # energy is negative logdensity

  accepted = 0
  for i = 1:n * takeevery
    p_, wasaccepted = hmcfastG(rng, U, q, prop_q, p, ω, nsteps, stepsize, gradalg)
    i % takeevery == 0 && push!(ωsamples, deepcopy(q.ω))
    if wasaccepted
      accepted += 1
    end
    lens(Loop, (ω = q.ω, accepted = accepted, p = p, i = i + offset))
  end
  ωsamples
end

# Opti1ons
# 1. Return tagged omegas
# 2. Tag then untag when putting n vector 
# -- untag everything> what if its already tagged with stuff we dont want to get rid of
# 3. Tag at individual callsites
#  -- bit messier, tagging is slow