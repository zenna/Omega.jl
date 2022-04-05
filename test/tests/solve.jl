using Omega
using Distributions
import Omega: solve, isconditioned
using Random: MersenneTwister

struct ϵType end
const ϵ = ϵType()

rng = MersenneTwister(0);
N = 3;
xs = rand(rng, N)
m = 0.8
c = 1.2
linear_model(x, m, c) = m * x + c
obs_model(x) = linear_model(x, m, c) + randn(rng) * 0.1;
ys = obs_model.(xs);

M = @~ Normal(0, 1);
C = @~ Normal(0, 1);

## Simpler model
x = 0.3
ϵ_ = ϵ ~ Normal(0, 1)
y = M .* x .+ C .+ ϵ_
y_ = 21.0

y_ = m * x + c + randn()


e3 = (y .== y_)
ypost = M |ᶜ e3

# y_ = mx + c + ϵ

solve(::typeof(ϵ_), ω) = @show y_ - M(ω) * x - C(ω) 
solve(::Member{StdNormal{Float64},ϵType}, ω) = @assert false

test() = complete(ypost)
# ##



# Y_class(i, ω) = linear_model(xs[i], M(ω), C(ω)) + (ϵ ∘ i ~ Normal(0, 0.1))(ω);

# EID = ComposedFunction{Type{ϵ}, Int64}
# Y⃗ = Mv(1:N, Y_class)
# evidence = Y⃗ ==ₚ ys
# joint_posterior = @joint(M, C) |ᶜ evidence

# solve(::StdNormal, i, ω) = (ϵ ∘ i ~ Normal(0, 0.1))(ω) / 0.1 # -
# solve(::typeof(Y_class), i, ω) = Y⃗(ω)[i] # -
# solve(::Normal, i::EID, ω) = Y_class(i, ω) - M(ω) - C(ω) # -
# solve(::typeof(Y⃗), ω) = ys # -
# solve(::typeof(evidence), ω) = true # 

# ## Transform into conditioend model
# transform(::StdNormal, i, ω) = (ϵ ∘ i ~ Normal(0, 0.1))(ω) / 0.1 # -
# solve(::Normal, i::EID, ω) = Y_class(i, ω) - M(ω) - C(ω) # 

# ## Problem is that we're doing all this work, really we just needed to evaluate StdNormal
# # 

# isconditioned(::StdNormal) = true
# isconditioned(x) = false
# isconditioned(::Normal) = true

# # Propagation model
# # In this model, we define propagation functions which define which values of varaiables in the model conditioend on evidence
# function propagate(::typeof(evidence), x)
#   if x
#     Y⃗ => ys
#   else
#     nothing
#   end
# end
