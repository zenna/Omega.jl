
## Common
mutable struct SoftBoolWrapper{ET <: Real}
  sb::SoftBool{ET}
end

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
  ω_ = TaggedΩ(ω, (sbw = sbw,))
  ω_, sbw
end

function trackerrorapply(x, ω)  
  ω_, sbw = tagerror(ω)
  fx = x(ω_)
  (fx, sbw.sb)
end

## Casette Powered Tracking
## ========================
Cassette.@context TrackErrorCtx

function Cassette.execute(ctx::TrackErrorCtx, ::typeof(condf), ω, x, y)
  conjoinerror!(ctx.metadata, Cassette.overdub(ctx, y, ω))
  Cassette.overdub(ctx, x, ω)
end

function casettetrackerrorapply(f, args...)
  sbw = SoftBoolWrapper(SoftBool(Val{true}))
  fx = Cassette.overdub(TrackErrorCtx(metadata=sbw), f, args...)
  (fx, sbw.sb)
end