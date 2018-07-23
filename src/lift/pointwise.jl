Cassette.@context PntCtx

Cassette.@primitive (op::Any)(f::RandVar, g::RandVar) where {__CONTEXT__ <: PntCtx} =
  Omega.mkrv(op, (f, g))
  # RandVar(x -> op(f(x), g(x)))
  
Cassette.@primitive tuple(f::RandVar) where {__CONTEXT__ <: PntCtx} =
  Omega.mkrv(tuple, (f,))

Cassette.@primitive (op::Any)(x::RandVar) where {__CONTEXT__ <: PntCtx} =
  Omega.mkrv(op, (x,))

"""Do `thunk` with pointwise style

```
julia> jump(x::Real, y::Real) = x + y
jump (generic function with 1 method)

julia> x = normal(0.0, 1.0)
Omega.normal(0.0, 1.0)::Float64

julia> q = Omega.pw() do
  jump(x, x)
end
jump(Omega.normal, Omega.normal)::Float64

julia> rand(q)
1.2107319112950392
```
"""
function pw(thunk)
  Cassette.@overdub(PntCtx(), thunk())
end