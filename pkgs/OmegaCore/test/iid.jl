using OmegaCore, Test, Distributions

function test()
  function f(ω)
    a = (1 ~ Normal(0, 1))(ω)
    b = (2 ~ Normal(0, 1))(ω)
    a + b
  end

  function g(ω)
    x = 0.0
    for i = 1:100
      x += (i <| f)(ω)
    end
    x
  end

  function h(ω)
    α = 1.0
    for i = 1:10
      α *= (i <| f)(ω)
    end
    α
  end

  i(ω) = (1 <| g)(ω) + (2 <| h)(ω)

  ω = defω()
  i(ω)
  @test length(keys(ω)) == 220
end

function normal_normals_test()
  μ = 1 ~ Normal(0, 1)
  x = 2 ~ Normal(μ, 1)
end

function blr()
  m = 1 ~ Normal(0, 1)
  c = 2 ~ Normal(0, 1)
  n = 100
  data = rand(n)
  f(x, m_, c_) = m_*x + c_
  obs(id, ω) = f(x, m_(ω), c_(ω)) + id ~ Normal(ω, 0, 0.1)
  obs(ω) = [f(x, m_(ω), c_(ω)) + i ~ Normal(ω, 0, 0.1) for i in data]
end

