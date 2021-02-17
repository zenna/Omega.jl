using OmegaCore
using Test
using Spec

@testset begin
  x = (a = 3, b = 4, c = 12)
  x_ = OmegaCore.Util.rmkey(x, :a)
  @test :b ∈ x_
  @test :c ∈ x_
  @test :a ∉ x_
end