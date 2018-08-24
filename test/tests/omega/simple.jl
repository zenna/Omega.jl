module TestNamespace

using Base.Test

# FIXME: How to get this package name more stable?
using Main.TestLib.Lens
using Main.TestLib.Omega.Space

#using Omega
using Omega.Index
using Omega.Simple
#using Omega.Space

@testset "Simple.resolve" begin
  ω = SimpleΩ()
  startIdx = Index.base(Vector{Int},0)
  nextIdx = increment

  @test test_resolve_repeatable(ω, startIdx, nextIdx)

  ω = SimpleΩ{Vector{Int}, Bool}()
  @test test_resolve_uniform(ω, startIdx, nextIdx)

  #TODO: Add tests for the other variants of resolve
end

idx(i::Int) = Index.base(Vector{Int}, i)

# LEFT OFF: Trying to figure out how to override == for SimpleΩ so can
# get these tests working
@testset "(Un)linearize" begin
  ωs1 = SimpleΩ(); ωs1[idx(1)] = 0.535; ωs1[idx(2)] = 0.5210; ωs1[idx(3)] = 0.645;
  ωs2 = SimpleΩ(); ωs2[idx(1)] = 0.452; ωs2[idx(2)] = 0.6477; ωs2[idx(3)] = 0.732;
  ωs3 = SimpleΩ(); ωs3[idx(1)] = 0.535; ωs3[idx(2)] = 0.7607; ωs3[idx(3)] = 0.065;

  # unlinearize requires that sω and ωvec are the same length
  test_ωs_len_3   = [ωs1, ωs2, ωs3]
  test_vals_len_3 = [[0.123, 0.5, 0.7], [0.0, 0.0, 0.0], [1.0, 1.0, 1.0]]

  @test test_lens_get_put(linearize, unlinearize, test_ωs_len_3, test_vals_len_3)

  println("Res1: " * string(unlinearize([0.0,0.1,0.2], ωs1)))
  println("Res2: " * string(unlinearize([0.0,0.5,1.0], unlinearize([0.0,0.1,0.2], ωs1))))

  @test test_lens_put_put(linearize, unlinearize, test_ωs_len_3, test_vals_len_3)
  @test test_lens_put_get(linearize, unlinearize, test_ωs_len_3, test_vals_len_3)
end

end