using OmegaGrad
using OmegaCore
using Zygote

function test_zygote_1()
  x = 1 ~ Normal(0, 1)
  ω = defω()
  ω = x(ω)
  grad(x, ω, ZygoteGrad)

  # Complete this test
  # @test ...
end

function test_zygote_2()
  x = 1 ~ Normal(0, 1)
  ω = defω()
  ω = x(ω)
  grad(x, ω, ZygoteGrad)

  # Complete this test
  # @test ...
end

@testset "ZygoteGrad" begin
  test_zygote_1()
  test_zygote_2()
end