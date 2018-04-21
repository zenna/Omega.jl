using Mu

# Bayesian Linear Regression
m = normal(0.0, 1.0)
c = normal(0.0, 1.0)

# Generate fake data
f(x) = m * x + c 
ndata = 10
xdata = rand(10) * 10
m_real = 2.5
c_real = 1.7
ydata = m_real .* xdata .+ c_real + randn(ndata)

# Inference
θm = normal(0.0, 2.0)
θc = normal(0.0, 2.0)

# Linear Regressor
linear(x) = θm * x + θc

# Data condition
datacond = randarray([(linear(xdata[i]) + normal(0.0, 2.0)) for i = 1:length(xdata)])

samples = rand(θm, datacond == ydata, OmegaT=Mu.SimpleOmega{Int, Float64}, n = 100000)
