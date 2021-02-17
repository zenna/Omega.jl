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

struct CustomProp{T}
  f::T
end

OmegaCore.propose_and_logratio(rng, ω, f, c::CustomProp) = 
  c.f(rng, ω, f)

# A proposal should be some type that supports
## Evaluation
## q(ω, x)

function custom_proposal()
  rng = MersenneTwister(0)
  x = 1 ~ Normal(0, 1)
  ϵ = 2 ~ Normal(0, 1)
  y(ω) = x(ω) + ϵ(ω)
  function prop(rng, ω, f)
    q = Normal(0, 1)
    θ = rand(rng, q)
    y_ = ω.y
    xn_, ϵn_ = y_ - θ, θ
    # ωn = (x = xn_, ϵ = ϵn_)
    qlogpdf = logpdf(q, θ)
    ωn = (x = xn_, ϵ = ϵn_, y = y_)
    (ωn, qlogpdf)
  end
  ωinit = (y = 3.0, x = 2.0, ϵ = 1.0)
  logenergy(x, vi) = logpdf(Normal(0, 1), vi)
  logenergy(ω) = logenergy(ω.x)
  # logenergy(ω) = sum((logenergy(ωi, ω[ωi]) for ωi in keys(ω)))
  @show logenergy(ωinit)


  samples = mh(rng, typeof(ωinit), logenergy, y, 10000; proposal = CustomProp(prop), ωinit = ωinit)
  xs = [ω[x] for ω in samples]
  ϵs = [ω[ϵ] for ω in samples]
  xs, ϵs
end

# TODO
# 1. Convince myself that this is correct
# 2. Reduce / remove dependence of Mh on omega
# 3. Need more flexible interface to create LazyΩ
# 4. Fix allocations
# 5. Automatic proposals
# @testset "OmegaMH" begin
#   test_bernoulli()
#   test_beta_bernoulli_constraint()
#   test_ss_propose()
#   test_custom_proposal()
# end