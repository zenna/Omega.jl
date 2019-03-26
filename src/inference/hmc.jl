"Hamiltonian Monte Carlo Sampling"
struct HMCAlg <: SamplingAlgorithm end

"Hamiltonian Monte Carlo Sampling"
const HMC = HMCAlg()
isapproximate(::HMCAlg) = true
defΩ(::HMCAlg) = SimpleΩ{Vector{Int}, Float64}

"Hamiltonian monte carlo with leapfrog integration: https://arxiv.org/pdf/1206.1901.pdf"
function hmc(U, ∇U, nsteps, stepsize, current_q::Vector)
  q = transform.(current_q)
  p = randn(length(q))
  current_p = p

  # Make a half step for momentum at beginning
  # Rejects proposals outside domain TODO: Something smarter
  # any(notunit, q) && return (current_q, false)
  invq = inv_transform.(q)
  p = p - stepsize * ∇U(invq) .* jacobian.(q) / 2.0

  for i = 1:nsteps
    # Half step for the position and momentum
    q = q .+ stepsize .* p
    if i != nsteps
      invq = inv_transform.(q)
      p = p - stepsize * ∇U(invq) .* jacobian.(q) ./ 2.0
    end
  end

  # Make half a step for momentum at the end
  # any(notunit, q) && return current_q, false
  invq = inv_transform.(q)
  p = p .- stepsize .* ∇U(invq) .* jacobian.(q) ./ 2.0

  # Evaluate the potential and kinetic energies at start and end
  current_U = U(current_q)
  current_K =  sum(current_p.^2) / 2.0
  proposed_U = U(invq)
  proposed_K = sum(p.^2) / 2.0

  if log(rand()) < current_U - proposed_U + current_K - proposed_K
    return (proposed_U, invq, true) # accept ω
  else
    return (current_U, current_q, false)  # reject ω
  end
end

"Sample from `x | y == true` with Hamiltonian Monte Carlo"
function Base.rand(y::RandVar,
                   n::Integer,
                   alg::HMCAlg,
                   ΩT::Type{OT};
                   nsteps = 10,
                   stepsize = 0.001) where {OT <: Ω}
  ω = ΩT()
  indomainₛ(y, ω) # Initialize omega
  ωvec = linearize(ω)

  ωsamples = ΩT[]
  U(ω) = -logerr(indomainₛ(y, ω))
  U(ωvec::Vector) = U(unlinearize(ωvec, ω))
  ∇U(ωvec) = gradient(y, ω, ωvec)

  accepted = 0
  for i = 1:n
    p_, ωvec, wasaccepted = hmc(U, ∇U, nsteps, stepsize, ωvec)
    ω_ = unlinearize(ωvec, ω)
    push!(ωsamples, unlinearize(ωvec, ω))
    if wasaccepted
      accepted += 1
    end
    lens(Loop, (ω = ω_, accepted = accepted, p = p_, i = i))
  end
  [applynotrackerr(y, ω_) for ω_ in ωsamples]
end
