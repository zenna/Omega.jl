using Distributions: Distribution
using ..Basis, ..Traits
export ctxapply, Vari, prehook, posthook

# # Dispatch
# In the contextual execution of a 15able, every intermediate variable application
# of the form `f(ω)` is __intercepted__.  This allows us to do all kinds of things
# such as do causal interventions, track loglikelihood information, etc
# Our implementation models Cassette.jl

# FIXME: Add Conditional to Vari

"Interceptable Variable"
const Vari = Union{Variable, Distribution, Mv, Member, PwVar}


(f::Vari)(ω::Ω) where {Ω <: AbstractΩ} = f(traits(Ω), ω)
(f::Vari)(traits::Trait, ω::Ω) where {Ω <: AbstractΩ} = ctxapply(traits, f, ω)

@inline function ctxapply(traits::Trait, f, ω::AbstractΩ)
  # FIXME: CAUSATION CAN prehook/recurse change traits?
  prehook(traits, f, ω)
  ret = recurse(f, ω)
  posthook(traits, ret, f, ω)
  ret
end

# by default, pre and posthooks do nothing
@inline prehook(traits, f, ω) = nothing
@inline posthook(traits, ret, f, ω) = nothing

# # ## Families

# (f::Vari)(id, ω::Ω) where {Ω <: AbstractΩ} = f(traits(Ω), id, ω)
# (f::Vari)(traits::Trait, id, ω::Ω) where {Ω <: AbstractΩ} = ctxapply(traits, f, id, ω)

# @inline function ctxapply(traits::Trait, f, id, ω::AbstractΩ)
#   # FIXME: CAUSATION CAN prehook/recurse change traits?
#   prehook(traits, f, id, ω)
#   ret = recurse(f, id, ω)
#   posthook(traits, ret, f, id, ω)
#   ret
# end

# # by default, pre and posthooks do nothing
# @inline prehook(traits::Trait, f, id, ω) = nothing
# @inline posthook(traits::Trait, ret, f, id, ω) = nothing