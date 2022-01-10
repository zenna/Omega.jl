using OmegaCore
using Test

@testset "named tuple" begin
  x = (a = 3, b = 4, c = 12)
  x_ = OmegaCore.Util.rmkey(x, Val{:a})
  @test :b ∈ keys(x_)
  @test :c ∈ keys(x_)
  @test :a ∉ keys(x_)
end