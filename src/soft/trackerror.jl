# Tagged Omega Tracking

mutable struct Wrapper{T}
  elem::T
end

SoftBoolWrapper = Wrapper{SoftBool}

conjoinerror!(sbw::SoftBoolWrapper, y::Nothing) = nothing
conjoinerror!(sbw::SoftBoolWrapper, yω::SoftBool) = sbw.elem &= yω
conjoinerror!(sbw::SoftBoolWrapper, yω::Bool) = conjoinerror!(sbw, SoftBool(log(yω)))
conjoinerror!(wrap::Wrapper{Bool}, yω::SoftBool) =
  error("Model has soft constraints but sampling algorithm doesn't support them")
conjoinerror!(wrap::Wrapper{Bool}, yω::Bool) = wrap.elem &= yω


function condf(tω::TaggedΩ, x, y)
  res = y(tω)
  conjoinerror!(tω.tags.tags.err, res)
  x(tω)
end

function cond(tω::TaggedΩ, bool)
  conjoinerror!(tω.tags.tags.err, bool)
end

tagerror(ω, wrap) = tag(ω, (err = wrap,))

"Is `ω` in the domain of `x`?"
function applytrackerr(x, ω, wrap = SoftBoolWrapper(trueₛ))
  ω_ = tagerror(ω, wrap)
  fx = x(ω_)
  (fx, ω_.tags.tags.err.elem)
end

"Is `ω` in the domain of `x`?"
indomain(x, ω, wrap = SoftBoolWrapper(trueₛ)) = applytrackerr(x, ω, wrap)[2]

"Is `ω` in the domain of `x`?"
applynotrackerr(x, ω, wrap = SoftBoolWrapper(trueₛ)) = x(tagerror(ω, wrap))