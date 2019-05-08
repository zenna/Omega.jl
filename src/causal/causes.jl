using NLopt
"""
`iscausebf(ω, c, e, iset; kwargs...)`

But-for causality.

Is `c` (provably) the actual cause of `e` in the causal world `ω`, allowing
interventions on variables defined in  `isset`
"""
function iscausebf(ω::Ω, c::RandVar, e::RandVar, iset;
                   sizes = [length(i(ω)) for i in iset],
                   proj = identity,
                   optargs...)
  @pre Bool(c(ω)) && Bool(e(ω)) "Both cause and effect must be true in ω"

  # Construct a loss function that is 1 when the constraint is satisfied
  loss = let rngs = splitvec(sizes), butfor = Omega.ciid(ω -> !c(ω) & !e(ω)), proj = proj
    function loss(vec, grad)
      # Since optimization requries vectors, we must do some book keeping
      replmap = Dict(iset[i] => proj(vec[rng]) for (i, rng) in enumerate(rngs))
      # In loss function we construct intervened mode where intervenable variables
      # in iset have been set to values under consideration  
      butforint = replace(butfor, replmap)

      # Get a score of the degree tow hich the effect `e` stil holds (in log scale)
      Omega.logerr(butforint(ω))
    end 
  end
  # optimize this loss function
  nlopt(loss, ω, iset, sizes; optargs...)
end

"Sequence of ranges of lengths in lengths"
function splitvec(lengths)
  i = 1
  ll = UnitRange{Int}[]
  for l in lengths
    b = i + l
    push!(ll, i:b - 1)
    i = b
  end
  ll
end

function nlopt(loss, ω, iset, sizes;
               n = prod(sizes),
               eq = isapprox,
               NlOptAlg = :LN_COBYLA,
               init = () -> rand(n))
  # n = prod(sizes)
  opt = NLopt.Opt(NlOptAlg, n)
  NLopt.max_objective!(opt, loss)
  NLopt.stopval!(opt, -0.0)
  NLopt.initial_step!(opt, 0.5)
  initreplaces = init()
  # loss(initreplaces, rand(3))
  (minf, ωvecoptim, ret) = NLopt.optimize(opt, initreplaces)
  if ret == :FORCED_STOP
    error("Forced Stop")
  end
  eq(minf, 0.0)
end


# Specify map from vector of values to intervention values
# Separate optimization criteria
# Return true false
# Have some tolerance in equality?
# Is the fact that the temperature is warm  
# Implement Pearl things.  leep other things constant?
# 