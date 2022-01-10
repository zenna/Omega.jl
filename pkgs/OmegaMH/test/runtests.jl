import Pkg
Pkg.develop(path = joinpath(pwd(), "..", "..", "connectors", "OmegaDistributions"))

using OmegaCore, OmegaMH, OmegaDistributions
using Test
using Distributions
using Random

# function test_bernoulli()
#   rng = MersenneTwister(1)
#   β = 1 ~ Beta(0.5)
#   # bern = 2 ~ Bernoulli(β)
#   bern_(id, ω) = Bernoulli(β(ω))(id, ω)
#   bern = 3 ~ bern_
#   βc = β |ᶜ bern ==ₚ 1.0
#   logdensity(ω) = logpdf(ω)
#   mh(rng, defΩ(), logdensity, 1000)
# end  # stdnormalpdf(x) = logpdf(Normal(0, 1), x)


# function test_beta_bernoulli_constraint()
#   β = 1 ~ Beta(0.5)
#   bern_(id, ω) = Bernoulli(β(ω))(id, ω)
#   bern = 3 ~ bern_
#   βc = β |ᶜ ((bern ==ₚ 1.0) & (β in 0.2..0.4))
#   randsample(βc, 1000; alg = OmegaMH)
# end

# function test_ss_propose(rng = MersenneTwister(0))
#   ω = defω()
#   x = 1 ~ Normal(0, 1)
#   y = 2 ~ Normal(0, 1)
#   xy = @joint x y
#   xy(ω)
#   propose(rng, xy, ω, OmegaMH.SSProposal())
# end

function auto_logenergy(rng = MersenneTwister(0))
  μ = 1 ~ Normal(0, 1)
  x = 2 ~ Normal(μ, 1)
  x_ = 3.1234
  μᵪ = μ |ᶜ x ==ₚ x_

  function prop(rng, ω)
    ω = update(ω, μ, rand(rng, Normal(ω[μ], 1)))
    (ω, 0.0)
  end
  ωinit = defω()
  ωinit[μ] = 0.3
  samples = mh(rng, ω -> logenergy(μᵪ, ω), 1000, ωinit, prop)
end

function test_manual_proposal(rng = MersenneTwister(0))
  μ = 1 ~ Normal(0, 1)
  x = 2 ~ Normal(μ, 1)
  x_ = 3.234
  μᵪ = μ |ᶜ x ==ₚ x_

  function prop(rng, ω)
    ω = update(ω, μ, rand(rng, Normal(ω[μ], 1)))
    (ω, 0.0)
  end
  ωinit = defω()
  ωinit[μ] = 0.3
  logenergy(ω) = logpdf(Normal(0, 1), ω[μ]) + logpdf(Normal(ω[μ], 1), x_)
  samples = mh(rng, logenergy, 1000, ωinit, prop)
end

function test_custom_proposal(rng = MersenneTwister(0))
  x = 1 ~ Normal(0, 1)
  ϵ = 2 ~ Normal(0, 1)
  y(ω) = x(ω) + ϵ(ω)
  function prop(rng, ω)
    q = Normal(0, 1)
    θ = rand(rng, q)
    y_ = ω.y
    xn_, ϵn_ = y_ - θ, θ
    # qlogpdf = logpdf(q, θ)
    ωn = (x = xn_, ϵ = ϵn_, y = y_)
    (ωn, 1)
  end
  ωinit = (x = 2.0, ϵ = 1.0, y = 3.0)
  stdnormalpdf(x) = logpdf(Normal(0, 1), x)
  logenergy(ω) = stdnormalpdf(ω.x) + stdnormalpdf(ω.ϵ)
  samples = mh(rng, logenergy, 10000, ωinit, prop)
end

# TODO
# 1. Convince myself that this is correct
# 2. Reduce / remove dependence of Mh on omega
# 3. Need more flexible interface to create LazyΩ
# 4. Fix allocations
# 5. Automatic proposals

@testset "OmegaMH" begin
  # test_bernoulli()
  # test_beta_bernoulli_constraint()
  # test_ss_propose()
  test_manual_proposal()
  test_custom_proposal()
end