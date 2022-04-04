using OmegaCore, Distributions, LinearAlgebra, Test, OmegaTest, OmegaDistributions

function test_mem()
  x = dimsnth(Normal(0, 1), (3, 3))
  h(x) = (println("call!"); svd(x).S)
  y(ω) = h(x(ω))
  y_ = Variable(y)
  vars(ω) = (y_(ω), y_(ω)*10, y_(ω)*20)
  ω = defω()
  memvars = mem(vars)
  ω = defω()
  memvars(ω)
end


function test_mem()
  x = dimsnth(Normal(0, 1), (1000, 1000))
  h(x) = (println("call!"); svd(x).S)
  y(ω) = h(x(ω))
  y_ = Variable(y)
  vars(ω) = (y_(ω), y_(ω)*10, y_(ω)*20)
  ω = defω()
  memvars = mem(vars)
  # @show vars(ω)
  # @show memvars(ω)
  @test vars(ω) == memvars(ω)
  # @test isinferred(vars, ω)
  # @test isinferred(memvars, ω)
  ω = defω()
  _, t1 = @timed vars(ω)
  _, t2 = @timed memvars(ω)
  # @test t1 == t2/3
end

@testset "Mem" begin
  test_mem()
end