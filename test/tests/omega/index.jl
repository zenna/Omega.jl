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

@testset "combine" begin
  seen = Set()
  vals = 0:10
  for i in vals
    for j in vals
      p = pair(i, j)
      @test !(p in seen)
      push!(seen, p)
    end
  end

  #TODO: What is the property needed in general for this function?
  #The property tested here for the int version is too strong and does not hold.
end

# I still don't understand a spec for base outside of the definitions -- jkoppel
# No tests for Paired/pair, because they should not be exported

end