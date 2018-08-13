module TestNamespace

using Base.Test

using Omega.Index

@testset "Increment" begin
  x = [1,2,3]
  increment!(x)
  @test x == [1,2,4]

  @test increment(x) == [1,2,5]
  @test x == [1,2,4]
end

end