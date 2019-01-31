
## Casette Powered Tracking
## ========================
Cassette.@context TrackErrorCtx

function Cassette.execute(ctx::TrackErrorCtx, ::typeof(condf), ω, x, y)
  conjoinerror!(ctx.metadata, Cassette.overdub(ctx, y, ω))
  Cassette.overdub(ctx, x, ω)
end

function casetteapplytrackerr(f, args...)
  sbw = SoftBoolWrapper(SoftBool(Val{true}))
  fx = Cassette.overdub(TrackErrorCtx(metadata=sbw), f, args...)
  (fx, sbw.sb)
end