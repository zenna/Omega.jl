
## Common
mutable struct SoftBoolWrapper
  sb::SoftBool
end

# mutable struct SoftBoolWrapper{ET <: Real}
#   sb::SoftBool{ET}
# end

conjoinerror!(sbw::SoftBoolWrapper, y::Nothing) = nothing
conjoinerror!(sbw::SoftBoolWrapper, yω::SoftBool) = sbw.sb &= yω
conjoinerror!(sbw::SoftBoolWrapper, yω::Bool) = conjoinerror!(sbw, SoftBool(log(yω)))
## Tagged Omega Tracking
## =====================

Error{T} = Union{
  Tuple{SoftBoolWrapper},
  Tuple{T, SoftBoolWrapper},
  Tuple{SoftBoolWrapper, T},
}

# function condf(ω::TaggedΩ{I, E}, x, y) where E <: Error
#   @show "do we get hereo?"
#   conjoinerror!(ω.err, y(ω))
#   x(ω)
# end

function condf(tω::TaggedΩ, x, y)
  res = y(tω)
  conjoinerror!(tω.tags.sbw, res)
  x(tω)
end

function tagerror(ω, sb::SoftBool = SoftBool(Val{true}))
  sbw = SoftBoolWrapper(sb)
  ω_ = TaggedΩ(ω, ErrorTag(sbw))
  ω_, sbw
end

"Is `ω` in the domain of `x`?"
function trackerrorapply(x, ω)  
  ω_, sbw = tagerror(ω)
  fx = x(ω_)
  (fx, sbw.sb)
end

"Is `ω` in the domain of `x`?"
indomain(x, ω) = trackerrorapply(x, ω)[2]

"Is `ω` in the domain of `x`?"
function applywoerror(x, ω)
  ω_, sbw = tagerror(ω)
  x(ω_)
end