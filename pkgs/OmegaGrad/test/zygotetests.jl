using OmegaCore, OmegaGrad, Distributions, Test

function zygotetest_1()
  x = 1 ~ Normal(0, 1)
  y = 2 ~ Normal(0, 1)
  z(ω) = x(ω) + y(ω)
  ω = defω()
  x_ = x(ω)
  y_ = y(ω)
  @test grad(z, ω, ZygoteGrad) = (1.0, 1.0)
end

function zygotetest_2()
  x = [i ~ Normal(0, 1) for i = 1:5]
  y(ω) = sum(x(ω))
  ω = defω()
  y_ = y(ω)
  @test grad(y, ω, ZygoteGrad) = (1.0,1.0,1.0,1.0,1.0)
end

function zygotetest_3()
  x = 1 ~ Normal(0, 1)
  y = 2 ~ Normal(0, 1)
  z(ω) = x(ω) * y(ω)
  ω = defω()
  x_ = x(ω)
  y_ = y(ω)
  @test grad(z, ω, ZygoteGrad) = (ω.data[[2]][2], ω.data[[1]][2])
end

function zygotetest_4()
  x = 1 ~ Normal(0, 1)
  z(ω) = x(ω) * x(ω) * x(ω)
  ω = defω()
  x_ = x(ω)
  @test grad(z, ω, ZygoteGrad) = (3.0 * (ω.data[[1]][2] ^ 2),)
end

function zygotetest_5()
  x = 1 ~ Normal(0, 1)
  z(ω) = sin(x(ω))
  ω = defω()
  x_ = x(ω)
  @test grad(z, ω, ZygoteGrad) = (cos(ω.data[[1]][2]),)
end

@testset "Gradients" begin
  zygotetest_1()
  zygotetest_2()
  zygotetest_3()
  zygotetest_4()
  zygotetest_5()
end