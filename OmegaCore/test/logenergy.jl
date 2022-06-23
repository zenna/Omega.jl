using OmegaCore
using OmegaTest
using Distributions
using Test
using Random
using Distributions

import OmegaCore: propagate!

function test_logenergy_sum()
  n = 1_000_000
  z = 1.0
  pinvert(θ, z) = z - θ, θ
  x = 1 ~ StdNormal{Float64}()
  y = 2 ~ StdNormal{Float64}()
  z = x .+ y
  z_ = 1.0
  evidence = z .== z_
  model = @joint(x, y) |ᶜ evidence

  function propagate!(ω, f::typeof(z), z_)
    θ = StdNormal{Float64}()(@uid(), ω)
    x_, y_ = pinvert(θ, z_)
    propagate!(ω, x, x_)
    propagate!(ω, y, y_)
  end
  ω = complete(model, defω())
end

function test_logpdf_cond()
  μ = 1 ~ Normal(0, 1)
  x = 2 ~ Normal.(μ, 1)
  μ_ = 0.1234
  x_ = -0.54321
  μc = μ |ᶜ (x .== x_)
  manual_ℓ = logpdf(Normal(0, 1), μ_) + logpdf(Normal(μ_, 1), x_)
  ω = complete(μc, μ => μ_)
  auto_ℓ = logenergy(μc)
  @test manual_ℓ == auto_ℓ 
end