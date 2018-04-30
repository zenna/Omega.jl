
"""
Random Conditional Distribution of `X` given `Y`

``
rcd(X, Y) = ω -> X | Y = Y(ω)
``
"""
function rcd(x::RandVar{T}, y::RandVar) where T
  function g(ω1::Omega)
    res = y(ω1) # Because ω is lazy, this causes values to be instantiated
    function h(ω2::Omega)
      merge!(ω2, ω1)
      x(ω2)
    end
    RandVar{T}(h)
  end
  RandVar{RandVar{T}}(g)
end

"`rcd(x) = rcd(x, parents(x))`"
function rcd(x::RandVar{T}) where T
  @assert false
end

const ∥ = rcd

""
struct RCDRandVar{O <: Omega, RVX <: AbstractRandVar, RVY <: AbstractRandVar}
  X::RVX
  Y::RVY
  ω::Omega
end

function rcd2(x::RandVar, y::RandVar)
end