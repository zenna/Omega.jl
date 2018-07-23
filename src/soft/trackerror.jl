Cassette.@context TrackErrorCtx

mutable struct SoftBoolWrapper{ET <: Real}
  sb::SoftBool{ET}
end

conjoinerror!(sbw, y::Nothing) = nothing
conjoinerror!(sbw, yω::SoftBool) = sbw.sb &= yω

# FIXME PRIMITIVE STOPS EXECUTION

@primitive function condf(ω, x, y) where {__CONTEXT__ <: TrackErrorCtx{SoftBoolWrapper{Float64}}}
  conjoinerror!(__context__.metadata, y(ω))
  x(ω)
end

function trackerrorapply(f, args...)
  sbw = SoftBoolWrapper(SoftBool(Val{true}))
  fx = Cassette.overdub(TrackErrorCtx(metadata=sbw), f, args...)
  (fx, sbw.sb)
end