"Dual Soft Booleans (supports negation)"
struct DualSoftBool{S} <: AbstractSoftBool
  b0::S
  b1::S
end

# using ZenUtils
function DualSoftBool(a::A, b::B) where {A, B}
  a_, b_ = promote(a.logerr, b.logerr)
  DualSoftBool(SoftBool(a_), SoftBool(b_))
end

Base.:!(x::DualSoftBool{S}) where S = DualSoftBool{S}(x.b1, x.b0)
Bool(x::DualSoftBool) = Bool(x.b1)
err(x::DualSoftBool) = err(x.b1)
logerr(x::DualSoftBool) = logerr(x.b1)

dsofteq(x, y, k = globalkernel()) = DualSoftBool(SoftBool(x == y ? globalkernel(1) : 1), ssofteq(x, y, k)) # FIXME
dsoftgt(x, y, k = globalkernel()) = DualSoftBool(ssoftlt(x, y, k), ssoftgt(x, y, k))
dsoftlt(x, y, k = globalkernel()) = DualSoftBool(ssoftgt(x, y, k), ssoftlt(x, y, k))

Base.:&(x::DualSoftBool, y::DualSoftBool) = DualSoftBool(x.b0 & y.b0, x.b1 & y.b1)
Base.:|(x::DualSoftBool, y::DualSoftBool) = DualSoftBool(x.b0 | y.b0, x.b1 | y.b1)

dsofttrue(::Type{T} = Float64) where T = DualSoftBool(SoftBool(-inf(T)), SoftBool(zero(T)))
dsoftfalse(::Type{T} = Float64) where T = DualSoftBool(SoftBool(zero(T)), SoftBool(-inf(T)))
