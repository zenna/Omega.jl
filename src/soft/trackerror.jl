
## Common
mutable struct SoftBoolWrapper{ET <: Real}
  sb::SoftBool{ET}
end

conjoinerror!(sbw::SoftBoolWrapper, y::Nothing) = nothing
conjoinerror!(sbw::SoftBoolWrapper, yω::SoftBool) = sbw.sb &= yω

## Tagged Omega Tracking
## =====================

Error{T} = Union{
  Tuple{SoftBoolWrapper},
  Tuple{T, SoftBoolWrapper},
  Tuple{SoftBoolWrapper, T},
}

condf((ω::TaggedΩ{I, E}), x, y) where E <: Error = (conjoinerror!(ω.err, y(ω)); x(ω))

function trackerrorapply(x, ω)  
  sbw = SoftBoolWrapper(SoftBool(Val{true}))
  ω_ = TaggedΩ(ω, sbw)
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