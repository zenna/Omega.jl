module IdGenTests

using Test
using Omega.Space

@testset "id" begin
  vec1 = []
  for i in 0:10
    push!(vec1, uid())
  end

  vec2 = [@id, @id, @id, @id,
          @id, @id, @id, @id,
          @id, @id, @id]

  @assert length(vec1) == length(vec2)

  # Test sequential
  for i in 2:length(vec1)
    @test vec1[i] == vec1[i-1] + 1
    @test vec2[i] == vec2[i-1] + 1
  end

  # Test different ID generators are disjoint
  @test isempty(intersect(vec1, vec2))
end

end