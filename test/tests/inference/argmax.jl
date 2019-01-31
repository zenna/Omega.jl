using Omega
using Test

function testargmax()
  ## Model
  x = normal(0.0, 1.0)
  y = normal(0.0, 10.0)
  xisy = x ==ₛ y 
  # loss = ω -> Omega.logerr(xisy(ω))   # Extract logerror
  loss = logerr(xisy)
  ω = argmax(loss)
  @test isapprox(x(ω), y(ω); atol = 0.01)
end

testargmax()