module TestNamespace

using Base.Test

# FIXME: How to get this package name more stable?
using Main.TestLib.Omega.Space

using Omega
using Omega.Index
# using Omega.Simple
using Omega.Space

@testset "Simple.resolve" begin
  ω = SimpleΩ()
  startIdx = Index.base(Vector{Int},0)
  nextIdx = increment

  @test test_resolve_repeatable(ω, startIdx, nextIdx)

  ω = SimpleΩ{Vector{Int}, Bool}()
  @test test_resolve_uniform(ω, startIdx, nextIdx)
end

end