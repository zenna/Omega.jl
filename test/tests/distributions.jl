
function testw()
  w = Mu.SimpleOmega{Vector{Int}, Array{Float64, 3}}()
  x = logistic(2.0, 2.0, (1, 2, 3))
  x(w)
  w = Mu.SimpleOmega{Vector{Int}, Array{Float64, 1}}()
  x = Mu.logistic(rand(2), rand(2))
  x(w)
end

testw()