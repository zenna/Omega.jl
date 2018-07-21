using Omega
using Test

θ  = uniform(0.0, 2π)
v = normal(30.0, 1.0)
m = 0.145
g = -9.81

# time to reach ground
t_d = 2 * v * sin(θ)/g

# distance travelled
d = v^2 * sin(2θ)/g