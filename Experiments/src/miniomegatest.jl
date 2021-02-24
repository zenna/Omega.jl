
using .MiniOmega

function simpletest()
  a = 1 ~ unif
  b = 2 ~ a
  sample(b)
end

function test()
  uniform(a, b) = ω -> unif(ω) * (b - a) + a

  x = 1 ~ uniform(0, 1)
  y = 2 ~ uniform(0, 1)
  d = 7 ~ y
  z = ω -> (x(ω), x(ω), y(ω), d(ω))
  @show sample(z)
  function a(ω)
    x_ = x(ω)
    d = 3 ~ uniform(0, 4)
    e = 4 ~ uniform(0, 4)
    x_ + d(ω) + e(ω)
  end

  @show sample(rt(x, y, z, a))

  # Conditional Independence
  x = 1 ~ uniform(0, 19)
  measure(ω) = x(ω) + uniform(0, 1)(ω)
  m1 = 3 ~ measure <| (x,)
  m2 = 4 ~ measure <| (x,)
  m3 = 5 ~ measure

  @show sample(rt(m1, m2, m3))

  # Linaer regression 
  α = 1 ~ uniform(0, 1) 
  β = 2 ~ uniform(0, 1)
  f(x, i) = i ~ (ω -> x*α(ω) + β(ω) + uniform(0.0, 1.0)(ω)) <| (α, β)
  y1 = f(0.3, 3)
  y2 = f(0.3, 4)
  @show sample(rt(y1, y2))

  y1b, y2b = pointwise() do
    f2(x, i) = i ~ (x * α + β + uniform(0.0, 1.0)) <| (α, β)
    y1b = f2(0.3, 3)
    y2b = f2(0.3, 4)
    y1b, y2b
  end

  @show sample(rt(y1, y2, y1b, y2b))

  # A bunch of random variables with a shared parents
  pointwise() do
    x = 1 ~ unifQD
    y = x * 100
    function a(ω)
      y(ω) + 5
    end
    function b(ω)
      y(ω) + 10
    end
    c = 2 ~ b <| (y,)
    d = 3 ~ b
    @show sample(rt(y, a, b, c, d))
  end
end