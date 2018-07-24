omegatype(::Type{ΩProj{O, I}}) where {O, I} = O

rcd(x, y) = ω -> cond(x, y == y(ω))

"""
Random Conditional Distribution of `X` given `Y`

``
rcd(X, Y) = ω -> X | Y = Y(ω)
``
"""
function rcd(x::RandVar{T}, y::Union{RandVar, UTuple{RandVar}}) where T
  function g(ω_s::T2) where {T2 <: Ω}
    # @show T2
    o = omegatype(T2)
    ω_p = o()
    y(ω_p)
    projintersect!(ω_p, ω_s.ω)
    # @grab ω_
    # @grab ω1
    # @assert false
    function h(ω2::Ω)
      merge!(ω2.ω, ω_p)
      x(ω2)
    end
    RandVar{T}(h)
  end
  RandVar{RandVar{T}}(g)
end

"`rcd`, x ∥ y"
x ∥ y = rcd(x, y)