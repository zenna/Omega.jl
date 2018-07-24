
## Common
mutable struct SoftBoolWrapper{ET <: Real}
  sb::SoftBool{ET}
end

conjoinerror!(sbw::SoftBoolWrapper, y::Nothing) = nothing
conjoinerror!(sbw::SoftBoolWrapper, yω::SoftBool) = sbw.sb &= yω

## Hacked Tracking
## ===============

struct ErrorTagged{I, ΩT, E} <: Ω{I}
  ω::ΩT
  err::E
  ErrorTagged(ω::Ω{I}, err) = ErrorTagged{I}(ω, err)
end

condf(ω::ErrorTagged, x, y) = (conjoinerror!(ω.err, y(ω)); x(ω))

function trackerrorapply(x, ω)  
  sbw = SoftBoolWrapper(SoftBool(Val{true}))
  ω_ = Omega.ErrorTagged{Int, typeof(ω), typeof(sbw)}(ω, sbw)
  fx = x(ω_)
  @show (fx, sbw.sb)
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