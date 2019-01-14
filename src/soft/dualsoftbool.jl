# abstract type DualSoftBool{S} <: AbstractSoftBool end

"Dual Soft Booleans"
struct DualSoftBool{S} <: AbstractSoftBool
  b0::S
  b1::S
end

Base.:!(x::DualSoftBool{S}) where S = DualSoftBool{S}(x.b1, x.b0)
Bool(x::DualSoftBool) = Bool(x.b1)
err(x::DualSoftBool) = err(x.b1)
logerr(x::DualSoftBool) = logerr(x.b1)

dsofteq(x, y, k = globalkernel()) = DualSoftBool(SoftBool(float(x == y)), ssofteq(x, y, k)) # FIXME
dsoftgt(x, y, k = globalkernel()) = DualSoftBool(ssoftlt(x, y, k), ssoftgt(x, y, k))
dsoftlt(x, y, k = globalkernel()) = DualSoftBool(ssoftgt(x, y, k), ssoftlt(x, y, k))

Base.:&(x::DualSoftBool, y::DualSoftBool) = DualSoftBool(x.b0 & y.b0, x.b1 & y.b1)
Base.:|(x::DualSoftBool, y::DualSoftBool) = DualSoftBool(x.b0 | y.b0, x.b1 | y.b1)

dsofttrue() = DualSoftBool(SoftBool(-Inf), SoftBool(0.0))
dsoftfalse() = DualSoftBool(SoftBool(0.0), SoftBool(-Inf))

# Cassette.@context DSBContext
# Cassette.overdub(::DSBContext, ::typeof(softgt), x, y) = dsoftgt(x, y)
# Cassette.overdub(::DSBContext, ::typeof(softlt), x, y) = dsoftlt(x, y)
# Cassette.overdub(::DSBContext, ::typeof(softtrue)) = dsofttrue()
# Cassette.overdub(::DSBContext, ::typeof(softfalse)) = dsoftfalse()

# dsbapply(f, args...) = Cassette.overdub(DSBContext(), f, args...)
# dsb(x::RandVar) = ciid(ω -> dsbapply(x, ω))

# function testdsb()
#   x = uniform(-1, 1)
#   y = !(x >ₛ 0.0)
#   Omega.dsbapply(() -> rand(x, y, 100; alg = SSMH))
# end