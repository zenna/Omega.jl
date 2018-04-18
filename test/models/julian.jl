using Mu

n = 30

# Priors 
β0 = normal(0.0, 1.0)
β1 = normal(0.0, 1.0)
c_1 = rand(n) # What's the constant

y = [uniform(0.0, 1.0) for i = 1:n]
x = [uniform(1:7) for i = 1:n]

p = dirichlet([1.0 for i = 1:n])
rand(p, y == β0 .+ β1 .* ((c_1 .* p) ./ (c_1 .* p .+ x)), alg=HMC)