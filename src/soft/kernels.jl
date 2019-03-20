## Kernels 
## =======

"Real+ -> [0, 1]"
kf1(x, β = 0.0001) = x / (x + β)
kf1β(β) = d -> kf1(d, β)

"(Log) Squared exponential kernel `α = 1/2l^2`, higher α is lower temperature  "
kse(d, α = 1000.0) = - α * d
kseα(α) = d -> kse(d, α) 

"γ exponential" 
γe(x, l = 1, γ = 1) = exp(-(x/l)^γ)

"Rational Quadratic"
rquad(x, l = 1, α = 1) = (1 + (x^2)/(2*α*l^2))^(-α)

"Power law kernel"
kpow(d, α = 1.0, k = 2) = -k * log(d) + log(α)

burr(x, c = 1, k = 40) =  log(c) + log(k) +  (c - 1) * log(x) - (k + 1)*log(1 + x^c)

# Temperature Modulation
const GLOBALKERNEL_ = Function[kse]

"Global Kernel"
function globalkernel!(k)
  global GLOBALKERNEL_
  GLOBALKERNEL_[1] = k
end

"Retrieve global kernel"
function globalkernel()
  global GLOBALKERNEL_
  GLOBALKERNEL_[1]
end

"Temporarily set global kernel"
function withkernel(thunk, k)
  globalkernel!(k)
  res = thunk()
  globalkernel!(kse)
  res
end

# (Cassette-based) Temperature Modulation
Cassette.@context AlphaCtx

"""
`f(args)` where temperature controlled with temperature `α`

```julia
x = normal(0.0, 1.0)
atα(10, rand, x ==ₛ 0.3)
```
"""
function atα(α, f, args...)
  ctx = AlphaCtx(metadata = α)
  Cassette.overdub(ctx, f, args...)
end

Cassette.overdub(ctx::AlphaCtx, ::typeof(kse), x, α) = kse(x, ctx.metadata)

"""

```julia
x = normal(0.0, 1.0)
@atα 100 rand(y ==ₛ 0.0)
```
"""
macro atα(a, fexpr)
  @pre fexpr.head == :call
  :(atα($(esc(a)), $(esc.(fexpr.args)...)))
end