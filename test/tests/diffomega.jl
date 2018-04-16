using Mu

function test1()
  a = [1.0, 2.0, 3.0]
  b = [4.0, 5.0, 6.0]
  c1 = Mu.CountVec(a)
  c2 = Mu.CountVec(b)
  DiffOmega(Dict(1 => c1, 2 => c2))
end

function test2()
  dω = Mu.test1()
  v = Mu.tovector(dω)
end


test1()
test2()