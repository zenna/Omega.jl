using Mu

\theta  = uniform(0, 2\pi)
v = normal(30)
m = 0.145
g = -9.81

# time to reach ground
t_d = 2*v_0*sin(\theta)/g

# distance travelled
d = v^2sin(2\theta)/g