using OmegaCore
# using OmegaTest
using Distributions
using Test
using Random
using Distributions

import OmegaCore: propagate!

# function test_logenergy_sum()
#   n = 1_000_000
#   z = 1.0
#   pinvert(θ, z) = z - θ, θ
#   x = 1 ~ StdNormal{Float64}()
#   y = 2 ~ StdNormal{Float64}()
#   z = x .+ y
#   z_ = 1.0
#   evidence = z .== z_
#   model = @joint(x, y) |ᶜ evidence

#   function propagate!(ω, f::typeof(z), z_)
#     θ = StdNormal{Float64}()(@uid(), ω)
#     x_, y_ = pinvert(θ, z_)
#     propagate!(ω, x, x_)
#     propagate!(ω, y, y_)
#   end
#   ω = complete!(model, defω())
# end

# function test_ble()
#   rng = MersenneTwister(0);
#   N = 100;
#   xs = rand(rng, N)
#   m = 0.8
#   c = 1.2
#   linear_model(x, m, c) = m * x + c
#   obs_model(x) = linear_model(x, m, c) + randn(rng) * 0.1;
#   ys = obs_model.(xs);
#   M = 1 ~ Normal(0, 1);
#   C = 2 ~ Normal(0, 1);

#   # FIXME: Can't define struct here
#   # Alt? 
#   struct ϵ end

#   Y_class(i, ω) = linear_model(xs[i], M(ω), C(ω)) + (ϵ ∘ i ~ Normal(0, 0.1))(ω);

#   Y⃗ = Mv(1:N, Y_class)
#   evidence = pw(==, Y⃗, ys)
#   joint_posterior = @joint(M, C) |ᶜ evidence

#   function propagate!(ω, ::typeof(Y⃗), Y⃗_)
#     for y_ in Y⃗_
#       propagate!(ω, Y_class, i, y_) # FIXME: no i defined and unclear how we'd get it
#     end
#   end
#   function propagate!(ω, ::typeof(Y_class), i, y_)
#     ϵ_ =  y_ -linear_model(xs[i], M(ω), C(ω))
#     # FIXME: still need to propagate
#   end

#   complete!(joint_posterior, defω())
# end

function test_logpdf_cond()
  μ = 1 ~ Normal(0, 1)
  x = 2 ~ Normal.(μ, 1)
  μ_ = 0.1234
  x_ = -0.54321
  μc = μ |ᶜ (x .== x_)
  manual_ℓ = logpdf(Normal(0, 1), μ_) + logpdf(Normal(μ_, 1), x_)
  ω = complete!(μc, μ => μ_)
  auto_ℓ = logenergy(μc)
  @test manual_ℓ == auto_ℓ 
end