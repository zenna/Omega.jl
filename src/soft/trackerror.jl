mutable struct SoftBoolWrapper
  sb::SoftBool # FIXME: Loose type because error when tracked softbool was changing to softbool
end

conjoinerror!(sbw::SoftBoolWrapper, y::Nothing) = nothing
conjoinerror!(sbw::SoftBoolWrapper, yω::SoftBool) = sbw.sb &= yω
conjoinerror!(sbw::SoftBoolWrapper, yω::Bool) = conjoinerror!(sbw, SoftBool(log(yω)))

## Tagged Omega Tracking
## =====================
function condf(tω::TaggedΩ, x, y)
  res = y(tω)
  conjoinerror!(tω.tags.tags.sbw, res)
  x(tω)
end

tagerror(ω) = tag(ω, (sbw = SoftBoolWrapper(SoftBool(Val{true})),))

"Is `ω` in the domain of `x`?"
function trackerrorapply(x, ω)  
  ω_ = tagerror(ω)
  fx = x(ω_)
  (fx, ω_.tags.tags.sbw.sb)
end

"Is `ω` in the domain of `x`?"
indomain(x, ω) = trackerrorapply(x, ω)[2]

"Is `ω` in the domain of `x`?"
function applywoerror(x, ω)
  ω_, sbw = tagerror(ω)
  x(ω_)
end