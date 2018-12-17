"Stochastic Gradient Hamiltonian Monte Carlo Sampling"
abstract type SGHMC <: Algorithm end

isapproximate(::Type{<:SamplingAlgorithm}) = true

defΩ(::Type{SGHMC}) = Omega.SimpleΩ{Int, Float64}

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
    @assert !(any(isnan(invq)))
    ∇U(q) = gradient(predicate, unlinearize(invq, ω), invq) .* jacobian(invq)
    # ∇U(q) = gradient(predicate, unlinearize(q, ω), q)

    # update the location and momentum parameters
    q = q .+ stepsize .* p
    @assert !(any(isnan(q)))
    #@show q[1], p[1]
    # any(notunit, q) && return (current_q, false, state)
    #@show state
    term = rand(MvNormal(d, 2 * stepsize .* (C .- Bhat)))
    @assert !(any(isnan(term)))
    p = p - stepsize .* ∇U(q) - stepsize .* C * p + term
    @assert !(any(isnan(p)))
    #@show ∇U(q)
  end

  # no MH step necessary
  q = inv_transform(q)
  @assert !(any(isnan(q)))
  return (q, true, state)
end

"Sample from `ω | y == true` with Stochastic Gradient Hamiltonian Monte Carlo"
function Base.rand(ΩT::Type{OT}, ygen, state, alg::Type{SGHMC};
                   n=1000,
                   nsteps = 100,
                   stepsize = 0.001,
                   cb = default_cbs(n)) where {OT <: Ω}
  ω = ΩT()
  predicate, state = ygen(state)
  predicate(ω) # Initialize omega
  ωvec = linearize(ω) # UNNEC

  # ωsamples = ΩT[] # FIXME: preallocate (and use inbounds)
  ωsamples = [] # FIXME: preallocate (and use inbounds)
  accepted = 0
  m = div(n, 10)
  @show n
  @showprogress 1 "Running SGHMC Chain" for i = 1:n
    ωvec, wasaccepted, state = sghmc(ygen, nsteps, stepsize, ωvec, ω, state)
    @show mean(ωvec)
    @show std(ωvec)
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
                   stepsize = 0.001,
                   ΩT::OT = Omega.SimpleΩ{Int, Float64},
                   cb = default_cbs(n)) where {OT}
  map(x, rand(ΩT, ygen, state, alg;
              n = n, nsteps = nsteps, stepsize = stepsize, cb = cb))
end