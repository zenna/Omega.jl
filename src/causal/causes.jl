using NLopt
"""$(SIGNATURES)
Actual Cause: is `c` the actual cause of `e` in the context `ω`,  `isset`

But-for causality.

∃ inter, s.t
```
let c_, e_ = replace(c, e, (isset[i] => inter[i] for i = 1:length(inter))
  !c_(ω) && e_(ω)
end
```

```jldoctest  
temp = constant(101.0)
icetemp = lift(identity)(temp) # identity necessary to make them different variables
chairtemp = lift(identity)(temp)
icemelt = icetemp >ₛ 100
chairmelt = chairtemp >ₛ 100
ω = defΩ()()
iscausebf(ω, temp >ₛ 100, icemelt, temp)
julia> iscausebf(ω, temp >ₛ 100, icemelt, temp)
true

julia> iscausebf(ω, chairtemp >ₛ 100, icemelt, chairtemp)
false

```
"""
function iscausebf(ω::Ω, c::RandVar, e::RandVar, iset;
                   sizes = [size(i(ω)) for i in iset],
                   proj = identity,
                  #  cb = donothing,
                   optargs...)
  @pre Bool(c(ω)) && Bool(e(ω)) "Both cause and effect must be true in ω"
  loss = let rngs = splitvec(sizes), butfor = Omega.ciid(ω -> !c(ω) & !e(ω)), proj = proj
    ii = 1
    function loss(vec, grad)
      # typeof(proj(vec[rngs[1]]))
      replmap = Dict(iset[i] => proj(vec[rng]) for (i, rng) in enumerate(rngs))
      butforint = replace(butfor, replmap)
      loss = Omega.logerr(butforint(ω))
      # @show cb, IterEnd
      # cb((loss = loss, replmap = replmap), IterEnd)
      # @show ii
      if loss == -0.0 && ii > 10
        @show ii, loss
        error()
      end
      ii += 1
      loss
    end 
  end
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
  @show (minf, ωvecoptim, ret) = NLopt.optimize(opt, initreplaces)
  if ret == :FORCED_STOP
    error("Forced Stop")
  end
  @show eq(minf, 0.0)
end


# Specify map from vector of values to intervention values
# Separate optimization criteria
# Return true false
# Have some tolerance in equality?
# Is the fact that the temperature is warm  
# Implement Pearl things.  leep other things constant?
# 