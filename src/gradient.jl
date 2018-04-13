using ForwardDiff

"Flatten `DiffOmega` into Vector"
function tovector(dω::DiffOmega{T}) where T
  vals = T[]
  for i in sort(collect(keys(dω.vals)))
    vals = vcat(vals, dω.vals[i].data)
  end
  vals
end

"Convert Vector to `DiffOmega``"
function todiffomega(xs::Vector, dω1::DiffOmega{T}) where T
  dω = DiffOmega{T}()
  lb = 1
  for i in sort(collect(keys(dω1.vals)))
    ub = lb + length(dω1.vals[i].data) - 1
    dω.vals[i] = CountVec(xs[lb:ub])
    lb = ub + 1
  end
  dω
end

"Gradient "
function gradient(Y, ω::DiffOmega)
  vals = tovector(ω)
  unpackcall(xs) = Y(todiffomega(xs)).epsilon
  ForwardDiff.gradient(unpackcall, ω)
end

function test1()
  a = [1.0, 2.0, 3.0]
  b = [4.0, 5.0, 6.0]
  c1 = CountVec(a)
  c2 = CountVec(b)
  DiffOmega(Dict(1 => c1, 2 => c2))
end

function testa()
  dω = Mu.test1()
  v = Mu.tovector(dω)
end

function test()
  μ = uniform(0.0, 1.0)
  x = normal(μ, 1.0)
  y = x == 1.0
  ω = Mu.DirtyOmega()
  gradient(y, ω)
end