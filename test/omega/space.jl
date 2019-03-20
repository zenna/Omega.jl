module Space

using Omega.Space
using Random
using Test
export test_resolve_repeatable, test_resolve_uniform

const TEST_SEED = 12345

function randvec(ω::Ω{I}, startIdx, nextIdx, n, T::Type) where {I}
  id = startIdx
  vec = []
  for i in 1:n
    push!(vec, memrand(ω, id, T))
    id = nextIdx(id)
  end
  vec
end

function test_resolve_repeatable(ω::Ω{I}, startIdx, nextIdx) where {I}
  Random.seed!(TEST_SEED)
  N = 10000
  vec1 = randvec(ω, startIdx, nextIdx, N, Int)
  vec2 = randvec(ω, startIdx, nextIdx, N, Int)
  vec1 == vec2
end

function close_to(num, targ, sigma)
  abs(num-targ) < 6 * sigma
end

# Extra precondition: ω must be able to take Bool values
function test_resolve_uniform(ω::Ω{I}, startIdx, nextIdx) where {I}
  Random.seed!(TEST_SEED)
  N = 10000
  vec = randvec(ω, startIdx, nextIdx, N, Bool)
  numTrue = length(filter(x -> x, vec))
  bernVariance = sqrt(0.5*(1-0.5))
  close_to(numTrue / N, 0.5, bernVariance / sqrt(N))
end

end