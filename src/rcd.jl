
using ZenUtils

omegatype(::Type{OmegaProj{O, I}}) where {O, I} = O

"""
Random Conditional Distribution of `X` given `Y`

``
rcd(X, Y) = ω -> X | Y = Y(ω)
``
"""
function rcd(x::RandVar{T}, y::Union{RandVar, UTuple{RandVar}}) where T
  function g(ω_s::T2) where {T2 <: Omega}
    # @show T2
    o = omegatype(T2)
    ω_p = o()
    y(ω_p)
    projintersect!(ω_p, ω_s.ω)
    # @grab ω_
    # @grab ω1
    # @assert false
    function h(ω2::Omega)
      merge!(ω2.ω, ω_p)
      x(ω2)
    end
    RandVar{T}(h)
  end
  RandVar{RandVar{T}}(g)
end

"`rcd`, x ∥ y"
const ∥ = rcd

"rcd(x, y)"
struct RCDRandVar{O <: Omega, RVX <: AbstractRandVar, RVY <: AbstractRandVar}
  x::RVX
  y::RVY
  ω::Omega
end

# function (rv::RCDRandVar)(ω::Omega)
#   x.y(ω)
#   resolve(x, y)
# end

# function resolve(x::RandVar, ω::Omega)
  
# end