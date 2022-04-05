using OmegaCore, Distributions, Test, OmegaTest, OmegaDistributions

a ⟹ b = !a || b

function test_hi()
  μ = 1 ~ Normal(0, 1)
  σ = 2 ~ Uniform(1, 3)
  y = 3 ~ Normal.(μ, σ)
  changeμ = 4 ~ Bernoulli(0.5)
  choice(ω) = ifelse((changeμ)(ω), μ, σ)
  int_dist(ω) = ValueIntervention(choice(ω), 5.0)

  # with a 40% chance, either μ or σ will be intervened to 0.5
  joint = @joint(y, μ, σ, changeμ)
  joint_ = joint |ᵈ hi(int_dist)
  y_, μ_, σ_, changeμ_ = randsample(joint_)
  if changeμ_
    @test μ_ == 5.0
  else
    @test σ_ == 5.0
  end 
end

function test_hi_self()
  # Intervenes one of the variables to the negation of itself
  μ = 1 ~ Poisson(10)
  σ = 2 ~ Uniform(1, 3)
  y = Variable(ω -> (μ(ω), σ(ω)))
  choice(ω) = ifelse((4 ~ Bernoulli(0.5))(ω), μ, σ)
  int_dist(ω) = let x_ = choice(ω)
    Intervention(x_, 0.0 .- x_)
  end

  joint = @joint(y, μ, σ, choice)
  joint_ = joint |ᵈ hi(int_dist)
  y_, μ_, σ_, choice_ = randsample(joint_)
  @test (choice_ == μ) ⟹ μ_ <= 0.0
  @test (choice_ == σ) ⟹ σ_ <= 0.0
  # @test isinferred(randsample, joint_)
end

function test_cd()
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
  model = pw(ifelse, is_model_1, m1(), m2())
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
end

@testset "Higher Intervention" begin
  test_hi()
  test_hi_self()
  test_cd()
end