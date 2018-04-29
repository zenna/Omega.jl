"Hamiltonian Monte Carlo Sampling"
abstract type HMC <: Algorithm end

"ω ∉ [0, 1]"
notunit(ω) = ω > 1.0 || ω < 0.0 

"Hamiltonian monte carlo with leapfron integration: https://arxiv.org/pdf/1206.1901.pdf"
function hmc(U, ∇U, nsteps, stepsize, current_q::Vector)
  q = current_q
  p = randn(length(q))
  current_p = p

  # Make a half step for momentum at beginning
  # Rejects proposals outside domain TODO: Something smarter
  any(notunit, q) && return (current_q, false)
  p = p - stepsize * ∇U(q) / 2.0
  

  for i = 1:nsteps
    # Helf step for the position and momentum
    q = q .+ stepsize .* p   
    if i != nsteps
      any(notunit, q) && return (current_q, false)
      p = p - stepsize * ∇U(q) ./ 2.0
    end
  end
  
  # Make half a step for momentum at the end
  any(notunit, q) && return current_q, false
  p = p .- stepsize .* ∇U(q) ./ 2.0
  
  # Evaluate the potential and kinetic energies at start and end
  current_U = U(current_q)
  current_K =  sum(current_p.^2) / 2.0
  proposed_U = U(q)
  proposed_K = sum(p.^2) / 2.0
  
  # @assert false
  if rand() < exp(current_U - proposed_U + current_K - proposed_K)
    return (q, true) # accept ω
  else
    return (current_q, false)  # reject ω
  end
end

"Sample from `x | y == true` with Hamiltonian Monte Carlo"
function Base.rand(x::RandVar{T}, y::RandVar{Bool}, alg::Type{HMC};
                   n=100,
                   nsteps = 10,
                   stepsize = 0.0001,
                   OmegaT::OT = Mu.SimpleOmega{Int, Float64}) where {T, OT}
  ω = OmegaT()
  y(ω) # Initialize omega
  ωvec = linearize(ω)

  xsamples = T[] # FIXME: preallocate (and use inbounds)
  U(ω) = -log(y(ω).epsilon)
  U(ωvec::Vector) = U(unlinearize(ωvec, ω))
  ∇U(ωvec) = gradient(y, ω, ωvec)

  accepted = 0.0

  @showprogress 1 "Running HMC Chain" for i = 1:n
    ωvec, wasaccepted = hmc(U, ∇U, nsteps, stepsize, ωvec)
    push!(xsamples, x(unlinearize(ωvec, ω)))
    if wasaccepted
      accepted += 1.0
    end
    i % 1000 == 0 && print_with_color(:light_blue, 
                                      "acceptance ratio: $(accepted/float(i)) ",
                                      "Last log likelihood $(U(ω))\n")
  end
  xsamples
end