using Mu
using Base.Test

x = uniform(0.0, 1.0)
y = uniform(x, 1.0)
z = uniform(y, 1.0)
intervention = intervene(y, uniform(-10.0, -9.0))
z_ = intervention(z)
@test mean(z_) < mean(z)

x = uniform(0.0, 1.0)
z = uniform(0.0, 1.0)
y = x + z
intervention = intervene(x, 3.0)
samples = rand(intervention(y), y == 2.0, n=10000)
@test samples

x = uniform(0.0, 1.0)
z = uniform(0.0, 1.0)
y = x + z
y_ = intervene(x, 3.0, y)
rand(y_, y == 2.0, n=10000)