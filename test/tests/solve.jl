using Omega
using Distributions
import Omega: solve, isconditioned
using Random: MersenneTwister

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

struct ϵ end

Y_class(i, ω) =  linear_model(xs[i], M(ω), C(ω)) + (ϵ ∘ i ~ Normal(0, 0.1))(ω);

EID = ComposedFunction{Type{ϵ}, Int64}
Y⃗ = Mv(1:N, Y_class)
evidence = Y⃗ ==ₚ ys
joint_posterior = @joint(M, C) |ᶜ evidence

solve(::StdNormal, i, ω) = (ϵ ∘ i ~ Normal(0, 0.1))(ω) / 0.1 # -
solve(::typeof(Y_class), i, ω) = Y⃗(ω)[i] # -
function solve(m::Member{<:Normal, T}, ω) where T <: EID
  i = m.id.inner 
  ys[i] - M(ω) * xs[i] - C(ω) #Y_class(i, ω) - M(ω) - C(ω) # -
end
# solve(::typeof(Y⃗), ω) = @show ys # -
# solve(::typeof(evidence), ω) = @show true # 

function test()
  ω = defω()
  @show complete(Y⃗, ω)
  ω
end

function solve(::typeof(Y_class), i, ω, v)
  # This is what we'd customize
end

function solve(::typeof(Y⃗), ω, y⃗)
  (y,_class, i, ω) = y⃗
end

function solve(::PwVar{Tuple{RT, CT}, typeof(==)}, istrue) where {RT, CT}
  if istrue
    (Y⃗, ys)
  else
    nothing#
  end
end

function solve(xy::Conditional, f, ω)
  (Y, true)
  # solve(::typeof(x.y), ω) = true
end

# What is a 

# isconditioned(::StdNormal) = true
# isconditioned(x) = false
# isconditioned(::Normal) = true