# Tagged Omega Tracking
mutable struct Wrapper{T}
  elem::T
end

conjoinerror!(sbw::Wrapper{<: AbstractSoftBool}, y::Nothing) = nothing
conjoinerror!(sbw::Wrapper{<: AbstractSoftBool}, yω::AbstractSoftBool) = sbw.elem &= yω
function conjoinerror!(sbw::Wrapper{<: AbstractSoftBool}, yω::Bool)
  if yω
    conjoinerror!(sbw, softtrue())
  else
    conjoinerror!(sbw, softfalse())
  end
end
conjoinerror!(wrap::Wrapper{Bool}, yω::SoftBool) = conjoinerror!(wrap, Bool(yω))
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
function applytrackerr(x, ω, wrap = Wrapper(softtrue()))
  ω_ = tagerror(ω, wrap)
  fx = x(ω_)
  (fx, ω_.tags.tags.err.elem)
end

"Soft `indomain`: distance from `ω` to the domain of `x`"
indomainₛ(x, ω, wrap = Wrapper{SoftBool}(softtrue())) = applytrackerr(x, ω, wrap)[2]
indomainₛ(x::RandVar) = ciid(ω -> indomainₛ(x, ω))

"Is `ω` in the domain of `x`?"
indomain(x, ω, wrap = Wrapper{Bool}(true)) = applytrackerr(x, ω, wrap)[2]
indomain(x::RandVar) = ciid(ω -> indomain(x, ω))


"Is `ω` in the domain of `x`?"
applynotrackerr(x, ω, wrap = Wrapper{SoftBool}(softtrue())) = x(tagerror(ω, wrap))  # FIXME: This could be made more efficient but actually not tracking