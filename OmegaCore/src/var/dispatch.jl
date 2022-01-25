using ..Basis, ..Traits
export prepostapply, Vari, prehook, posthook

# # Dispatch
# In the contextual execution of a 15able, every intermediate variable application
# of the form `f(ω)` is __intercepted__.  This allows us to do all kinds of things
# such as do causal interventions, track loglikelihood information, etc
# Our implementation models Cassette.jl

# FIXME: Add Conditional to Vari

"Interceptable Variable"
# const Vari = Union{Variable, Mv, Member, PwVar}

@inline (f::AbstractVariable)(ω::Ω) where {Ω <: AbstractΩ} = dispatch(traits(Ω), f, ω)
@inline dispatch(traits::Trait, f, ω) = prepostapply(traits, f, ω)

# (f::Vari)(ω::Ω) where {Ω <: AbstractΩ} = f(traits(Ω), ω)
# (f::Vari)(traits::Trait, ω::Ω) where {Ω <: AbstractΩ} = prepostapply(traits, f, ω)

@inline function prepostapply(traits::Trait, f, ω::AbstractΩ)
  # FIXME: CAUSATION CAN prehook/recurse change traits?
  prehook(traits, f, ω)
  ret = recurse(traits, f, ω) # invoke(f, Tupe{AbstractΩ}, ω)
  # maybe i should do recurse(traits, f, ω)
  # And default recurse(traits, f, ω) = recurse(f, ω)
  posthook(traits, ret, f, ω)
  ret
end

# Default
@inline recurse(traits, f, ω) = recurse(f, ω)

# by default, pre and posthooks do nothing
@inline prehook(traits, f, ω) = nothing
@inline posthook(traits, ret, f, ω) = nothing

# # ## Families

# (f::Vari)(id, ω::Ω) where {Ω <: AbstractΩ} = f(traits(Ω), id, ω)
# (f::Vari)(traits::Trait, id, ω::Ω) where {Ω <: AbstractΩ} = prepostapply(traits, f, id, ω)

# @inline function prepostapply(traits::Trait, f, id, ω::AbstractΩ)
#   # FIXME: CAUSATION CAN prehook/recurse change traits?
#   prehook(traits, f, id, ω)
#   ret = recurse(f, id, ω)
#   posthook(traits, ret, f, id, ω)
#   ret
# end

# # by default, pre and posthooks do nothing
# @inline prehook(traits::Trait, f, id, ω) = nothing
# @inline posthook(traits::Trait, ret, f, id, ω) = nothing