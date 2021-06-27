module LogEnergies

using ..Traits, ..RNG, ..Var, ..Tagging, ..Space
using ..Util: Box
using ..Basis: AbstractΩ

export logenergy, ℓ, logenergyexo

## Simple Case
# In the simple case, the values of all the exogenous variables
# are within FIXME

# zt: fix me precision of these two are different,
logenergy(::StdNormal{T}, v) where T = - v^2/2 - log(sqrt(2π))
logenergy(::StdUniform{T}, v) where T = zero(T)
logenergy(dist::ExoRandVar, v) = logenergy(dist.class, v)

"`logenergyexo(ω)` Log energy of `ω` only on exogenous variables"
function logenergyexo(ω)
  reduce(pairs(ω); init = 0.0) do logpdf_, (dist, val)
    logpdf_ + logenergy(dist, val)
  end
end

## Complex Case

@inline taglogenergy(ω, logenergy_ = 0.0, seen = Set()) = 
  tag(ω, (logenergy = (ℓ = Box(logenergy_), seen = seen),))

"""
`logenergy(rng::AbstractRNG, x, ω)`

# Returns
- joint log probability of
"""
function logenergy(x, ω::AbstractΩ)
  ω_ = taglogenergy(ω)
  ret = x(ω_)
  ω_.tags.logenergy.ℓ.val
end

function Var.posthook(::trait(LogEnergy), ret, f::ExoRandVar, ω)
  @show f isa ExoRandVar
  if f ∉ ω.tags.logenergy.seen
    @show "SEEN"
    ω.tags.logenergy.ℓ.val += logenergy(f, ret)
    push!(ω.tags.logenergy.seen, id)
  end
  nothing
end

const ℓ = logenergy

end