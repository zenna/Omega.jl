"""
Random Conditional Distribution of `x` given `y`

``
rcd(X,Y) = (y -> cond(X,Y == y))(Y)
              = \omega -> X \mid Y = Y(\omega)
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

function rcd(x::RandVar{T}) where T
  @assert false
end