using Mu
using Base.Test

x = uniform(0.0, 1.0)
y = uniform(x, 1.0)
z = uniform(y, 1.0)
intervention = intervene(y, uniform(-10.0, -9.0))
z_ = intervention(z)
@test mean(z_) < mean(z)