using Omega
import ForwardDiff

function testgrad()
  μ = uniform(0.0, 1.0)
  x = normal(μ, 1.0)
  y = x == 1.0
  ω = Omega.SimpleΩ{Int, Float64}()
  y(ω)
  Omega.gradient(y, ω)
end

testgrad()

function testgrad2()
  μ = normal(0.0, 1.0)
  x = normal(μ, 1.0)
  samples = y = x == 3.0

  # Gradient test
  ω = Omega.SimpleΩ{Int, Float64}()
  y(ω)
  unpackcall(xs) = y(Omega.unlinearize(xs, ω)).epsilon
  Omega.gradient(y, ω)
  ForwardDiff.gradient(unpackcall, [.3, .2])
end

testgrad2()