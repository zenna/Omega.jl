using Mu

function test1()
  a = [1.0, 2.0, 3.0]
  b = [4.0, 5.0, 6.0]
  c1 = Mu.CountVec(a)
  c2 = Mu.CountVec(b)
  Mu.DiffOmega(Dict(1 => c1, 2 => c2))
end

test1()

function test2()
  dω = test1()
  v = Mu.tovector(dω)
end

test2()

function test3()
  ω = DiffOmega()
  x = normal(0.0, 1.0)
  x_ = x(ω)
  @test x(ω) == x_
end

test3()