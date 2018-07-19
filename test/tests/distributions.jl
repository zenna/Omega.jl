
function testw()
  w = Omega.SimpleΩ{Vector{Int}, Array{Float64, 3}}()
  x = logistic(2.0, 2.0, (1, 2, 3))
  x(w)
  w = Omega.SimpleΩ{Vector{Int}, Array{Float64, 1}}()
  x = Omega.logistic(rand(2), rand(2))
  x(w)
end

testw()