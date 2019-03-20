using Test

using TestLib.Lens
using TestLib.Omega.Space

using Omega
using Omega.Space

@testset "Simple.memrand" begin
  ω = SimpleΩ()
  startIdx = Omega.Space.base(Vector{Int},0)
  nextIdx = increment

  @test test_resolve_repeatable(ω, startIdx, nextIdx)

  ω = SimpleΩ{Vector{Int}, Bool}()
  @test test_resolve_uniform(ω, startIdx, nextIdx)

  #TODO: Add tests for the other variants of memrand
end

idx(i::Int) = base(Vector{Int}, i)

@testset "(Un)linearize" begin
  ωs1 = SimpleΩ(); ωs1[idx(1)] = 0.535; ωs1[idx(2)] = 0.5210; ωs1[idx(3)] = 0.645;
  ωs2 = SimpleΩ(); ωs2[idx(1)] = 0.452; ωs2[idx(2)] = 0.6477; ωs2[idx(3)] = 0.732;
  ωs3 = SimpleΩ(); ωs3[idx(1)] = 0.535; ωs3[idx(2)] = 0.7607; ωs3[idx(3)] = 0.065;

  # unlinearize requires that sω and ωvec are the same length
  test_ωs_len_3   = [ωs1, ωs2, ωs3]
  test_vals_len_3 = [[0.123, 0.5, 0.7], [0.0, 0.0, 0.0], [1.0, 1.0, 1.0]]

  @test test_lens_put_get(linearize, unlinearize, test_ωs_len_3, test_vals_len_3)

  @test test_lens_put_put(linearize, unlinearize, test_ωs_len_3, test_vals_len_3)
  @test test_lens_get_put(linearize, unlinearize, test_ωs_len_3, test_vals_len_3)
end