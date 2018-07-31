using Omega

# x is the distribution to approximate
x = normal(0.0, 1.0) 

# y is the approximating family
α = uniform(0.001, 5.0)
β = uniform(0.001, 5.0)
y = betarv(α, β)

# Divergence between x and y 
δxy = KLdivergence(y ∥ (α, β), x)

# Threshold
δ = 0.5

# Draw conditional samples
αβ_ = rand((α, β), δxy < δ)