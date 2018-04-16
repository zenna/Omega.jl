using Mu

function testgrad()
  μ = uniform(0.0, 1.0)
  x = normal(μ, 1.0)
  y = x == 1.0
  ω = Mu.DiffOmega()
  gradient(y, ω)
end