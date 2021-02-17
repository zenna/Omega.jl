module TrackError

using ..Util, ..Tagging, ..Condition, ..Traits
import ..Condition
export applytrackerr, condvar, tagerror

# Issue is that type of err value depends on
# gradient method used
# Solutions
# Specialize: condvar/applytrackerr based on type of Omega

"""
`applytrackerr(x, ω, initerr)`

Is `ω` in the domain of `x`?
Returns `(f(ω), v)` where `v = ω ∈ dom(x)`
"""
function applytrackerr(x, ω, initerr)
  ω_ = tagerror(ω, initerr) # zt: surprisingly expensive
  fx = x(ω_)
  (fx = fx, err = ω_.tags.err.val)
end

# tagnotrackerr(ω) = tag(ω, (donttrack = true,))
# applynotrackerr(x, ω) = apl(x, tagnotrackerr(ω))

# "Soft `condvar`: distance from `ω` to the domain of `x`"
# condvarₛ(x, ω, initerr = softtrue()) = applytrackerr(x, ω, initerr).err
# condvarₛ(x) = ω -> condvarₛ(x, ω)

"Is `ω` in the domain of `x`?"
condvar(x, ω, initerr = true) = applytrackerr(x, ω, initerr).err
condvar(x) = ω -> condvar(x, ω)

"Update `err` by conjoining cu`rrent error with `b`"
conjoinerror!(err::Box, b) = err.val &= b

dotrack(ω) = !haskey(ω.tags, :donttrack) && haskey(ω.tags, :err)

function Condition.condf(::trait(Err), ω, x, y)
  dotrack(ω) && conjoinerror!(ω.tags.err, y(ω))
  x(ω)
end

function Condition.cond!(::trait(Err), ω, bool)
  dotrack(ω) && conjoinerror!(ω.tags.err, bool)
  bool
end

"Tag `ω` with `err`" 
tagerror(ω, initerr) = tag(ω, (err = Box(initerr),))

# tagerror(ω, initerr::AbstractBool) = tag(ω, (err = Ref(initerr),)) #FIXME UNCOMMENT THIS AND SPECIALISE BELOW TO OMEGA
# "Tag tω with error"
# function tagerror(tω::TaggedΩ, initerr::AbstractBool)
#   # If error already there, use that!
#   haskey(tω.tags, :err) ? tω : tag(tω, (err = Ref{Real}(initerr),))
# end

function combinetags(::Type{Val{:err}}, a, b)
  # @show a
  # @show b
  # @assert false
  @show a[]
  @show a[] & b[]
end

end