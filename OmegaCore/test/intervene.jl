using Test
using OmegaCore
using Distributions
using OmegaTest
using OmegaCore.Interventions

function test_mergetags()
  x = 1 ~ Normal(0.0, 1.0)
  y(ω) = x(ω) + 10.0
  c1 = (ω -> 100.0)
  c2 = (ω -> 200.0)
  yi = intervene(y, x => c1)
  yii = intervene(yi, x => c2)
  yiii = intervene(yi, (x => c1, x => c2))
  yiii2 = intervene(yi, (x => c2, x => c1))

  nt1 = (intervene = yi.i,)
  nt2 = (intervene = yii.i,)
  ntmerged = mergetags(nt1, nt2)
  @test isinferred(mergetags, nt1, nt2)

  # Only one of these should be true
  # @test ntmerged.intervene == yiii.i
  @test ntmerged.intervene == yiii2.i
end

function test_changed_rettype_merge()
  xx = 1 ~ Categorical([0.5, 0.5])
  y(ω) = xx(ω) + 1 # int 
  yi = intervene(y, xx => (ω -> 200.0)) # float
  @test randsample(yi) == 201
  ω = defω()
  @test Base.return_types(yi, Base.typesof(ω))[1] == Union{Int64, Float64}
end

function test_merge_1()
  xx = 1 ~ Normal(0, 1)
  y(ω) = xx(ω) + 10
  yi = intervene(y, xx => (ω -> 200.0))
  yi2 = intervene(yi, xx => (ω -> 300.0))
  @test randsample(yi2) == 210
  # yi2(ω)
  @test isinferred(randsample, yi2)
end

function test_merge_2()
  xx = 1 ~ Normal(0, 1)
  y(ω) = xx(ω) + 10
  xr = 2 ~ Normal(30, 1)
  yi = intervene(y, xx => xr) 
  yi2 = intervene(yi, xr => (ω -> 300.0))
  @test randsample(yi2) == 310
  @test isinferred(randsample, yi2)
end

function test_merge_3()
  xx = 1 ~ Normal(0, 1)
  y(ω) = xx(ω) + 10
  yi = intervene(y, (xx => (ω -> 200.0), xx => (ω -> 300.0)))
  yi3 = intervene(yi, xx => (ω -> 400.0))
  @test randsample(yi3) == 210
  @test isinferred(randsample, yi3)
end

function test_merge_4()
  xx = 1 ~ Normal(0, 1)
  y(ω) = xx(ω) + 10
  xr = 2 ~ Normal(30, 1)
  xrr(ω) = xr(ω) * xr(ω)
  yi = intervene(y, xx => xrr) 
  yi2 = intervene(yi, xr => (ω -> 30.0))
  @test randsample(yi2) == 910.0
  @test isinferred(randsample, yi2)
end

function test_merge_more_than_5_interventions()
  xx = 1 ~ Normal(0, 1)
  y(ω) = xx(ω) + 10
  yi = intervene(y, xx => (ω -> 200.0))
  yi2 = intervene(yi, xx => (ω -> 300.0))
  yi3 = intervene(yi2, xx => (ω -> 400.0))
  yi4 = intervene(yi3, xx => (ω -> 500.0))
  yi5 = intervene(yi4, xx => (ω -> 600.0))
  yi6 = intervene(yi5, xx => (ω -> 700.0))
  @test randsample(yi6) == 210
  # isinferred fails
end


function minimal_example()
  xx = 1 ~ Normal(0, 1)
  y(ω) = xx(ω) + 10
  yi = intervene(y, xx => (ω -> 200.0)) 
  yi2 = intervene(yi, xx => (ω -> 300.0))
  @test randsample(yi2) == 200
end

function minimal_example()
  xx = 1 ~ Normal(0, 1)
  y(ω) = xx(ω) + 10
  xr = 2 ~ Normal(30, 1)
  yi = intervene(y, xx => xr) 
  yi2 = intervene(yi, xr => (ω -> 300.0))
  @test randsample(yi2) == 310
end


function test_model()
  # Normally distributed random variable with id 1
  x = 1 ~ Normal(0, 1)
    
    # Normally distributed random variable with id 2 and x as mean
    function y(ω)
      xt = x(ω)
      u = Uniform(xt, xt + 1)
      u((2,), ω)
    end
    x_ = 0.1
    y_ = 0.3

    # An omega object -- like a trace
    ω = SimpleΩ(Dict((1,) => x_, (2,) => y_))

    # model -- tuple-valued random variable ω -> (x(ω), y(ω)), becase we want joint pdf
    m(ω) = (x(ω), y(ω))
    (x, y, m)
end

function samplemodel()
  x,y,z = test_model()
  ω = defω()
  y(ω)
end

function test_intervention()
  x, y, m = test_model()
  yⁱ = y |ᵈ (x => (ω -> 100.0))
  @test 100.0 <= randsample(yⁱ) <= 101.0
  @test isinferred(randsample, yⁱ)
end

function test_intervene_diff_parents()
  x = 1 ~ Normal(0, 1)
  function y(ω)
    x_ = x(ω)
    (2 ~ Normal(x_, 1))(ω)
  end
  x2 = 3 ~ Normal(0, 1)
  yi = y |ᵈ (x => ω -> 100.0)
  yi2 = y |ᵈ (x2 => ω -> 100.0)
  yi_, yi2_ = randsample((yi, yi2))
  @test yi_ != yi2_
end

function test_two_interventions()
  x = 1 ~ Normal(0, 1)
  y = 2 ~ Uniform(10.0, 20.0)
  z(ω) = Normal(x(ω), y(ω))((3,), ω)
  (x, y, z)
  zi = z |ᵈ (x => (ω -> 100.0), y => (ω -> 0.1))
  @test 99 <= randsample(zi) <= 101
  @test isinferred(randsample, zi)
end

function test_three_interventions()
  x = 1 ~ Normal(0, 1)
  y = 2 ~ Uniform(10.0, 20.0)
  c = 3 ~ Uniform(2.0, 3.0)
  z(ω) = Normal(x(ω)*c(ω), y(ω))((3,), ω)
  (x, y, z)
  zi = z |ᵈ (x => (ω -> 100.0), y => (ω -> 0.1), c => (w -> 1.0))
  @test 99 <= randsample(zi) <= 101
end

function test_intervention_logpdf()
  # Log density of model wrt ω
  l = logpdf(m, ω)

  # Check it is what it should be
  @test l == logpdf(Normal(0, 1), x_) + logpdf(Normal(x_, 1), y_)

  # Intervened model
  v_ = 100.0

  # y had x been v_
  yⁱ = y | had(x => v_)

  # new model with Intervened variables
  mⁱ = rt(x, yⁱ)

  # log pdf of interved model on same ω
  lⁱ = logpdf(mⁱ, ω)
  logpdf(x, ω)

  
  @test lⁱ == logpdf(Normal(0, 1), x_) + logpdf(Normal(v_, 1), y_)
  @test lⁱ < l
end

function test_self_intervene()
  p = 0.7
  q = 0.3
  E = ~ 1 ~ Bernoulli(p)     # Execution order
  C = ~ 2 ~ Uniform(0, 1)    # Calmness
  N = C <ₚ q                  # Nerves
  A = E |ₚ N                 # A shoots
  B = E                      # B shoots on order
  D = A |ₚ B                 # Prisoner Dies
  cf = (D |ᵈ (A => 0)) |ᶜ D
  # randsample(cf)
  
  na1 = D |ᵈ (B => (C <ₚ q))
  @test isinferred(randsample, na1)
  na2 = D |ᵈ (C => C *ₚ 1.2)
  @test isinferred(randsample, na2)
  s = 0.4
  na3 = D |ᵈ (A => ifelseₚ(3 ~ Bernoulli(s), 0, A))
  @test isinferred(randsample, na3)
  r = 0.8
  na4 = D |ᵈ (A => 0, B => ifelseₚ(3 ~ Bernoulli(r), 0, B))
  # ω = def\
  @test isinferred(randsample, na4)
end

@testset "intervene" begin
  test_intervention()
  test_intervene_diff_parents()
  test_two_interventions()
  test_three_interventions()
  # test_intervention_logpdf()
  test_mergetags()
  test_merge_1()
  test_merge_2()
  test_merge_3()
  test_merge_4()
  test_changed_rettype_merge()
  test_merge_more_than_5_interventions()
  test_self_intervene()
end 