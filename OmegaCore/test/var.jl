using OmegaCore
using Test

function testvar()
  n = 1 ~ Choice(1:10)
  μ = [(2, i) ~ Normal(0, 1) for i = 1:n]
  s = sum(μ)
end

function testmaxmean()
  x = 1 ~ Normal(0, 1)
  y = 2 ~ Bounded(-4.0, 1.0)
  z(ω) = x(ω) + y(ω)

  # Find y which maximises mean of x
  argmax(y, mean(z))
end

function test_polynomial()
  function polynomial(ω)
    n = finite(ω, 1:10)
    function (x)
      y = 0.0
      for i = 1:n
        y += ~ normal(ω, 0, 1) * x^i
      end
      y
    end
  end
end

@testset "free-variables" begin
  testvar()
  testmaxmean()
  test_polynomial()
end