using OmegaCore, OmegaMH
using Test
using Distributions
using Random

function test_bernoulli()
  rng = MersenneTwister(1)
  β = 1 ~ Beta(0.5)
  # bern = 2 ~ Bernoulli(β)
  bern_(id, ω) = Bernoulli(β(ω))(id, ω)
  bern = 3 ~ bern_
  βc = β |ᶜ bern ==ₚ 1.0
  logdensity(ω) = logpdf(ω)
  mh(rng, defΩ(), logdensity, 1000)
end

function test_beta_bernoulli_constraint()
  β = 1 ~ Beta(0.5)
  bern_(id, ω) = Bernoulli(β(ω))(id, ω)
  bern = 3 ~ bern_
  βc = β |ᶜ ((bern ==ₚ 1.0) & (β in 0.2..0.4))
  randsample(βc, 1000; alg = OmegaMH)
end

function test_ss_propose()
  rng = MersenneTwister(0)
  ω = defω()
  x = 1 ~ Normal(0, 1)
  y = 2 ~ Normal(0, 1)
  xy = @joint x y
  xy(ω)
  propose(rng, xy, ω, OmegaMH.SSProposal())
end

@testset "OmegaMH" begin
  test_bernoulli()
  test_beta_bernoulli_constraint()
  test_ss_propose()
end