abstract type DualSoftBool{S} end

"Dual Soft Booleans"
struct LeftSoftBool{S} <: DualSoftBool{S}
  l::S
  r::s
end

struct RightSoftBool{S} <: DualSoftBool{S}
  l::S
  r::s
end

side(x::LeftSoftBool) = x.l
side(x::RightSoftBool) = x.r
Base.(!)(x::LeftSoftBool) = RightSoftBool(x.l, x.r)
Base.(!)(x::RightSoftBool) = LeftSoftBool(x.l, x.r)
Bool(x::DualSoftBool) = Bool(side(x))
err(x::DualSoftBool) = err(side(x))
logerr(x::DualSoftBool) = logerr(side(x))

# TO DO This properly need change interpretation of x>_2
# Can use Cassette for that