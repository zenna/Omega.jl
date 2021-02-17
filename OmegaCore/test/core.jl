using OmegaCore
using Distributions

x = 1 ~ Normal(0, 1)
y = 2 ~ Normal(0, 3)

function f(id, ω)
  a = ([id; 3] ~ Normal(0, 1))(ω)
  for i = 1:10
    a += ([id; i] ~ Normal(0, 1))(ω)
  end
  a + x(ω) + y(ω)
end

f1 = 3 ~ f
f2 = 4 ~ f

# Need to make sure that all ids are globally unique
# Need to compose id with everything


