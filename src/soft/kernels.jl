# Kernels 

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