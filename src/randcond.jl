
function Base.merge!(sω1::SubOmega, sω2::SubOmega)
  # Where this gets a little tricky is that they are both sub omegas
  for (k, v) in sω2.ω.d
    sω1.ω.d[k] = v
  end
end

"""
Random Conditional Distribution

``
randdist(X,Y) = (y -> cond(X,Y=y))(Y)
              = \omega -> X \mid Y = Y(\omega)
``
"""
function randdist(x::RandVar{T}, y::RandVar) where T
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

# `randcond`
# `rcd`

