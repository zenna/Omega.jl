
"""
Random Conditional Distribution of `X` given `Y`

``
rcd(X, Y) = ω -> X | Y = Y(ω)
``
"""
function rcd(x::RandVar{T}, y::Union{RandVar, UTuple{RandVar}}) where T
  function g(ω1::Ω)
    res = y(ω1) # Because ω is lazy, this causes values to be instantiated
    function h(ω2::Ω)
      merge!(ω2, ω1)
      x(ω2)
    end
    RandVar{T}(h)
  end
  RandVar{RandVar{T}}(g)
end

const ∥ = rcd

""
struct RCDRandVar{O <: Ω, RVX <: AbstractRandVar, RVY <: AbstractRandVar}
  X::RVX
  Y::RVY
  ω::Ω
end

function rcd2(x::RandVar, y::RandVar)
end