## Kernels 
## =======

"Real+ -> [0, 1]"
kf1(x, β = 0.0001) = x / (x + β)
kf1β(β) = d -> kf1(d, β)
lift(:kf1β, 1)

"Squared exponential kernel `α = 1/2l^2`, higher α is lower temperature  "
kse(d, α = 10000.0) = α * d
kseα(α) = d -> kse(d, α) 
lift(:kseα, 1)
lift(:logkseα, 1)

"Power law kernel"
kpow(d, α = 1.0, k = 2) = -k * log(d) + log(α)

"Parento Kernel"
kpareto(x, xm = 0, α = 1.0) = log(α) + log(xm) - (α + 1) * log(x)
kpareto2(x, xm = 1.0, α = 11) = log(α) + log(xm)  - log(x+xm^(α + 1))
kpareto3(x, xm = 1.0, α = 3) = log(xm) - log(x+xm^(α + 1))

burr(x, c = 1, k = 40) =  log(c) + log(k) +  (c - 1) * log(x) - (k + 1)*log(1 + x^c)

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
