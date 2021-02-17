using OmegaCore, Distributions

# A model where x --causes-> y
function m1()
  x = 1 ~ Normal(0, 1)
  y(ω) = (2 ~ Normal(x(ω), 1))(ω)
  (x = x, y = y)
end

# A model where y --causes-> x
function m2()
  x = 3 ~ Normal(0, 1)
  y(ω) = (4 ~ Normal(x(ω), 1))(ω)
  (x = y, y = x)
end

is_model_1 = 3 ~ Bernoulli(0.5)
model = ifelseₚ(is_model_1, m1(), m2())
mx(ω) = model(ω).x
mxω(ω) = mx(ω)(ω)
my(ω) = model(ω).y

x_ = 1.3
y_ = 2.0

# This won't do what we want!
condition1(ω) = (mxω |ᵈ (my => 100.0))(ω) >= 101.0

condition(ω) = (mxω |ᵈ (my =>ˡ y_))(ω) >= x_

# condition = (mxω |ᵈ (my =>ˡ y_)) >=ₚ x_

prob = mean(randsample(is_model_1 |ᶜ condition, 1000))
println("""The model1 is correct (x causes y), given after forcing y to 2 x,
we observed that x was 1.3 is""", prob)