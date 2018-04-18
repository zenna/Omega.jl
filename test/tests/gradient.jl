using Mu
import ForwardDiff

function testgrad()
  μ = uniform(0.0, 1.0)
  x = normal(μ, 1.0)
  y = x == 1.0
  ω = Mu.DiffOmega()
  gradient(y, ω)
end

function testgrad2()
  μ = normal(0.0, 1.0)
  x = normal(μ, 1.0)
  samples = y = x == 3.0

  # Gradient test
  ω = Mu.DefaultOmega()
  unpackcall(xs) = y(Mu.unlinearize(xs, ω)).epsilon
  gradient(y, ω)
  ForwardDiff.gradient(unpackcall, [.3, .2])
end

testgrad2()