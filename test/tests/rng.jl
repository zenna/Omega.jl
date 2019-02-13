using Random, Omega, Test

function testrng()
  x = normal(0, 1)
  rng = Random.MersenneTwister(345679)
  s1 = rand(rng, x, x > 0, alg = RejectionSample)
  rng = Random.MersenneTwister(345679)
  s2 = rand(rng, x, x > 0, alg = RejectionSample)
  @test s1 == s2
end

testrng()