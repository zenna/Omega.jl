"Stochastic Gradient Hamiltonian Monte Carlo Sampling"
abstract type SGHMC <: Algorithm end

defaultomega(::Type{SGHMC}) = Mu.SimpleOmega{Int, Float64}

# FIXME: Inefficient because:
# Doing all this unnecessary work linearizing / reshaping, should use broadcast
# The rejection proposali isn't good, we should probably move to an unconstrained space


# Annealing
# (i) Hyperparameter search on temperature
# (ii) Anneal temperature
# (iii) Parallel Tempering
# (iv) Make Javier's framework for learned
# (v) Implement distance functi onlearning

# Fix rcd
#

## Issue is I want to specify what loss function to use
## But these things aren't specialized by type
## So either specialize them by type or:
## Provide way to make randbool

"Bijective transformation from [0, 1] to the real line, T(x)=log(1/(1-x)-1)"
transform(x) = log.(1./(1.-x).-1)

"The inverse of the transformation above, T^(-1)(y)=1-1/(1+e^y)"
inv_transform(y) = 1.-1./(1.+exp.(y))

"Jacobian of the transformation above, J(x) = 1/x(1-x)"
jacobian(x) = 1./(x .* (1.-x))

"Stochastic Gradient Hamiltonian Monte Carlo with Langevin Dynamics Friction: https://arxiv.org/pdf/1402.4102.pdf"
function sghmc(ygen, nsteps, stepsize, current_q::AbstractVector, ω, state)
  d = length(current_q)
  q = transform(current_q)
  p = randn(d)
  current_p = p

  # Rejects proposals outside domain TODO: Something smarter
  # https://stats.stackexchange.com/questions/73885/mcmc-on-a-bounded-parameter-space
  # any(notunit, q) && return (current_q, false, state)

  # construct friction and noise estimate matrices
  Bhat = 0.1
  C = 1

  for i = 1:nsteps
    #@show i
    # generate a predicate and get the gradient of its ϵ
    predicate, state = ygen(state)
    invq = inv_transform(q)
    ∇U(q) = gradient(predicate, unlinearize(invq, ω), invq) .* jacobian(invq)

    # update the location and momentum parameters
    q = q .+ stepsize .* p
    #@show q[1], p[1]
    # any(notunit, q) && return (current_q, false, state)
    #@show state
    term = rand(MvNormal(d, 2 * stepsize .* (C .- Bhat)))
    p = p - stepsize .* ∇U(q) - stepsize .* C * p + term
    #@show ∇U(q)
  end

  # no MH step necessary
  q = inv_transform(q)
  return (q, true, state)
end

"Sample from `ω | y == true` with Stochastic Gradient Hamiltonian Monte Carlo"
function Base.rand(OmegaT::Type{OT}, ygen, state, alg::Type{SGHMC};
                   n=1000,
                   nsteps = 100,
                   stepsize = 0.000001) where {OT <: Omega}
  ω = OmegaT()
  predicate, state = ygen(state)
  predicate(ω) # Initialize omega
  ωvec = linearize(ω) # UNNEC

  # ωsamples = OmegaT[] # FIXME: preallocate (and use inbounds)
  ωsamples = [] # FIXME: preallocate (and use inbounds)
  accepted = 0
  m = div(n, 10)
  @showprogress 1 "Running SGHMC Chain" for i = 1:n
    ωvec, wasaccepted, state = sghmc(ygen, nsteps, stepsize, ωvec, ω, state)
    push!(ωsamples, unlinearize(ωvec, ω)) # UNNEC
    if wasaccepted
      accepted += 1
    end
    i % m == 0 && print_with_color(:light_blue,  "acceptance ratio: $(accepted/i)\n")
  end
  ωsamples
end

"Sample from `x | y == true` with Metropolis Hasting"
function Base.rand(x::Union{RandVar, UTuple{<:RandVar}}, ygen, state, alg::Type{SGHMC};
                   n::Integer = 1000,
                   nsteps = 100,
                   stepsize = 0.00001,
                   OmegaT::OT = Mu.SimpleOmega{Int, Float64}) where {OT}
  map(x, rand(OmegaT, ygen, state, alg; n=n, nsteps=nsteps, stepsize=stepsize))
end
