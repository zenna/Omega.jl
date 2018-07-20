using Omega
using Base: Test

function test1()
  a = [1.0, 2.0, 3.0]
  b = [4.0, 5.0, 6.0]
  c1 = Omega.CountVec(a)
  c2 = Omega.CountVec(b)
  Omega.DiffΩ(Dict(1 => c1, 2 => c2))
end

test1()

function test2()
  dω = test1()
  v = Omega.linearize(dω)
end

test2()