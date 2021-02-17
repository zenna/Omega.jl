module OmegaCoreTestModels

function test_model()
  # Normally distributed random variable with id 1
  x = 1 ~ Normal(0, 1)
  
  # Normally distributed random variable with id 2 and x as mean
  y = 2 ~ Uniform(x, pw(+, x, 1))
  x_ = 0.1
  y_ = 0.3

  # An omega object -- like a trace
  ω = SimpleΩ(Dict((1,) => x_, (2,) => y_))

  # model -- tuple-valued random variable ω -> (x(ω), y(ω)), becase we want joint pdf
  m = (x, y)ₚ
  (x, y, m)
end


end