module TrackError

using ..Util, ..Tagging, ..Condition, ..Traits
import ..Condition
export applytrackerr, condvar, tagerror, initerror

# Options
# 1. Always initialize with correct type -- best performance
# 2. Have nothing, small union ⊥ ∪ Float64
# 3. Vector

"""
`applytrackerr(x, ω, initerr)`

Is `ω` in the domain of `x`?
Returns `(x(ω), v)` where `v = ω ∈ dom(x)`
"""
function applytrackerr(x, ω, initerr)
  ω_ = tagerror(ω, initerr) # zt: surprisingly expensive
  fx = x(ω_)
  (fx = fx, err = ω_.tags.err.val)
end

"Equivalent to `condvar(x)(ω)`, but more efficient"
condvarapply(x, ω, initerr) = applytrackerr(x, ω, initerr).err
condvarapply(x, ω, errtype::Type{T} = Bool) where T =
  condvarapply(x, ω, initerror(T))

function initerror end
initerror(::Type{Bool}) = true
"""
`condvar(x)`

Random variable that `x` is conditioned on.
I.e. if `x` can be expressed as `x | y`, then `y = condvar(x)` 
"""
condvar(x, initerr) = ω -> condvarapply(x, ω, initerr)

"Update `err` by conjoining current error with `b`"
conjoinerror!(err::Box, b) = err.val &= b

# Track error for this ω
dotrack(ω) = !haskey(ω.tags, :donttrack) && haskey(ω.tags, :err)

function Condition.condf(::trait(Err), ω, x, y)
  dotrack(ω) && conjoinerror!(ω.tags.err, y(ω))
  x(ω)
end

function Condition.cond!(::trait(Err), ω, bool)
  dotrack(ω) && conjoinerror!(ω.tags.err, bool)
  bool
end

# conjoinerror!(ω.tags.err, y(ω))
tagerror(::trait(Err), ω, initerr) = tag(ω,  (err = Box(initerr),))
tagerror(traits, ω, initerr) = tag(ω, (err = Box(initerr),))

"Tag `ω` with `err`" 
tagerror(ω::Ω, initerr) where Ω = tagerror(traits(Ω), ω, initerr)

function combinetags(::Type{Val{:err}}, a, b)
  # @show a
  # @show b
  # @assert false
  @show a[]
  @show a[] & b[]
end

end