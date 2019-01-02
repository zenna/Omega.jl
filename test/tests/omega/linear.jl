
# function testlinearomega()
#   x = uniform(0.0, 1.0)
#   rand(x; ΩT = LinearΩ)
# end

# function x_(ω)
#   a = rand(ω)
#   b = bernoulli(ω, 0.3, Bool)
#   c = normal(ω, 1.0, 2.0)
#   a + b + c
# end

function testlinear()
  x = normal(0.0, 1.0, (1,2,3))
  w = Omega.LinearΩ()
  x(w)
end  

# x = ciid(x_)
# ω = LinearΩ()
# x(ω)