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
function iscausebf(ω::Ω, c::RandVar, e::RandVar, iset...)
  @pre Bool(c(ω)) && Bool(e(ω))
# @pre noche ck fo
  # 1. How to setup Optimization problem over intervention set
  # May want some indirection between values searched over (e.g. linear vector)
  # And actual interventions
  # Fix type inference on elemtype
  losser = let butfor = Omega.ciid(ω -> !c(ω) & !e(ω))
    function loss(vec, grad)
      # @show "hi"
      replmap = Dict(iset[i] => vec[i] for i = 1:length(vec))
      butforint = replace(butfor, replmap)
      Omega.logerr(butforint(ω))
    end 
  end
  # opt = NLopt.Opt(alg, n)
  # losser(x) = (println("hi", x); sum(x))
  opt = NLopt.Opt(:LN_COBYLA, length(iset))
  NLopt.max_objective!(opt, losser)
  # NLopt.lower_bounds!(opt, -1000)
  # NLopt.upper_bounds!(opt, 1000)
  initreplaces = [i(ω) for i in iset]
  (minf, ωvecoptim, ret) = NLopt.optimize(opt, initreplaces)
  minf == 0.0
end

# Separate optimization criteria
# Return true false