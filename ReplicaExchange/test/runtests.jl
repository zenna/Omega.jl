using ReplicaExchange

# FIXME, and rename
rescale(l, t) = exp(l, t)

function custom_proposal(rng = MersenneTwister(0),  nreplicas = 4)
  m2 = MixtureModel(
	  [MvNormal([0.9, 0.0], [0.3, 0.2]),
	   MvNormal([2.0, 3.0], [0.3, 0.4]),
	   MvNormal([-2.0, -1.0], [0.25, 0.33])],
	  [0.5, 0.3, 0.2]);
  # nreplicas initial start states
  ωinits = [((x_, ϵ_) = rand(2); (x = x_, ϵ = ϵ_, y = x_ + ϵ_)) for _ = 1:nreplicas]

  # Create one temperature for each replica
  logtemps(n, k) = exp.(k * range(-2.0, stop = 1.0, length = n))
  ctxs = logtemps(nreplicas)

  function somefunc(alg, temp, ωinit)
    let ℓ(ω) = logenergy(ω, temp)
      mh!(rng, ℓ, y, 10000, ωinit, CustomProp(prop))
    end
  end

end

