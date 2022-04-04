using TransformVariables
# using Distributions
using OmegaCore:StdNormal, StdUniform
# 1. Space might already be constrained
# 2. Custom proposals?
# 3. Dont modify derived values
# 4. 

# function propose(rng, ::StdNormal, x)

# end

# function propose(rng, ::StdUniform, x)
#   x_ = transform(asℝ, x) + σ * randn(rng)
#   inverse()


#   inv_transform(transform(x) + σ * randn(rng))
# end

"Compute a score using the change in prior of the *single* changed site"
function proposalkernel(kernel, x)
  ∇logdensity(x) = x |> transform |> jacobian |> abs |> log
  before = ∇logdensity(x)
  proposed = kernel(x)
  after = ∇logdensity(proposed)
  ratio = after - before
  proposed, ratio 
end

# Do the transform (move unconstrained space)

normalkernel(rng, x, σ = 0.1) = proposalkernel(x) do x
        inv_transform(transform(x) + σ * randn(rng))
      end

"Changes a uniformly chosen single site with kernel"
function swapsinglesite(transitionkernel, rng, ω)
  logtranstionp = 0.0
  function updater(x)
    result, logtranstionp = transitionkernel(x)
    result
  end
  update(ω, rand(rng, keys(ω)), updater), logtranstionp
end

function moveproposal(rng, ω; σ = 1.0)
  swapsinglesite(rng, ω) do x
    normalkernel(rng, x, σ)
  end
end