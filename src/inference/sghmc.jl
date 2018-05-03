"Stochastic Gradient Hamiltonian Monte Carlo Sampling"
abstract type SGHMC <: Algorithm end

"ω ∉ [0, 1]"
notunit(ω) = ω > 1.0 || ω < 0.0

"Stochastic Gradient Hamiltonian Monte Carlo with Langevin Dynamics Friction: https://arxiv.org/pdf/1402.4102.pdf"
function sghmc(ygen, nsteps, stepsize, current_q::Vector, ω)
  d = length(q)
  q = current_q
  p = randn(d)
  current_p = p

  # Rejects proposals outside domain TODO: Something smarter
  any(notunit, q) && return (current_q, false)

  # construct friction and noise estimate matrices
  Bhat = zeros(d, d); C = eye(d)

  for i = 1:nsteps
    # get a new batch, construct the stochastic gradient
    predicate = ygen()
    ∇U(q) = gradient(predicate, unlinearize(q, ω), q)
    
    # update the location and momentum parameters
    q = q .+ stepsize .* p
    any(notunit, q) && return (current_q, false)
    p = p - stepsize .* ∇U(q) - stepsize .* C * p + rand(MvNormal(2 * stepsize .* (C .- Bhat)))
  end

  # no MH step necessary
  return (q, true)
end

"Sample from `x | y == true` with Hamiltonian Monte Carlo"
function Base.rand(OmegaT::OT, ygen, alg::Type{SGHMC};
                   n=1000,
                   nsteps = 100,
                   stepsize = 0.0001) where {T, OT}
  ω = OmegaT()
  y(ω) # Initialize omega
  ωvec = linearize(ω)

  ωsamples = OmegaT[] # FIXME: preallocate (and use inbounds)
  accepted = 0.0
  @showprogress 1 "Running SGHMC Chain" for i = 1:n
    ωvec, wasaccepted = sghmc(ygen, nsteps, stepsize, ωvec, ω)
    push!(ωsamples, unlinearize(ωvec, ω))
    if wasaccepted
      accepted += 1.0
    end
    i % 10 == 0 && print_with_color(:light_blue,  "acceptance ratio: $(accepted/float(i))\n")
  end
  ωsamples
end

"Sample from `x | y == true` with Metropolis Hasting"
function Base.rand(x::UTuple{<:RandVar}, ygen, alg::Type{SGHMC};
                   n::Integer = 1000, OmegaT::OT = DefaultOmega) where {OT}
  map(x, rand(OmegaT, ygen, alg, n=n))
end
