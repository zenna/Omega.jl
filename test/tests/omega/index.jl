using Test
using Omega.Space

@testset "Increment" begin
  x = [1,2,3]

  @test increment(x) == [1,2,4]
end

# Vector indices should be a free semigroup
#
# Properties:
# combine(a, combine(b, c)) === combine(combine(a, b), c)
# (combine(a, b) == combine(a, c)) => b == c
# (combine(a, c) == combine(b, c)) => a == b
# append(a, b) === combine(a, base(b))
@testset "combine" begin
  test_elts = [ [1,2], [3], [3, 4]
              , [5, 6], [7], [1,2,3]
              ]
  test_indivs = collect(1:10)

  triples = [(a,b,c) for a in test_elts, b in test_elts, c in test_elts]

  for (a,b,c) in triples
    @test combine(a, combine(b, c)) == combine(combine(a, b), c)
    if combine(a, b) == combine(a, c)
      @test b == c
    end
    if combine(a, c) == combine(b, c)
      @test a == b
    end
  end

  for elt in test_elts
    for x in test_indivs
      @test append(elt, x) == combine(elt, Space.base(Vector{Int}, x))
    end
  end

end