# Causal Discovery

Discovery of the causal model itself is possible using Omega.
We havea to (i) define a probabilistic model over models, and (ii) condition that distribution on interventional data -- i.e., the result of performing an experiment.

```julia
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


# Construct a distribution over these models
whichmodel = 3 ~ Bernoulli(0.5)
model = ifelseₚ(whichmodel, m1(), m2())
mx(ω) = model(ω).x
mxω(ω) = mx(ω)(ω)
my(ω) = model(ω).y

# Suppose I have intervention data where by I intervened on x => 100 and saw y and it was 101
# What should I believe about
c
# This won't work!
ondition(ω) = (mxω |ᵈ (my => 100.0))(ω) >= 101.0

# This breaks composition
# I want to be able to say something like:
# The distribution that this
# Is my equal to y,
# type of my is \Omega -> ()
# Or I might want to say, y in m1 or m2
function condition2(ω)
  my_ = my(ω)
  (mxω |ᵈ (my_ => 1.0))(ω) >= 1.3
end

prob = mean(randsample(whichmodel |ᶜ condition2, 1000))
println("The probability that it is model1, i.e., x causes y, given that once we forced y to 2 and then saw that x was 1.3 is ", prob)
```