using Omega

function testw()
  w = Omega.SimpleΩ{Vector{Int}, Array{Float64, 3}}()
  x = logistic(2.0, 2.0, (1, 2, 3))
  x(w)
  w = Omega.SimpleΩ{Vector{Int}, Array{Float64, 1}}()
  x = Omega.logistic(rand(2), rand(2))
  x(w)
end

testw()

function testlogistic()
  x = logistic(0.0, 1.0)
  rand(x)
  x = logistic(0.0, 1.0, (1, 2))
  rand(x)
  x = logistic(logistic(0.0, 1.0), logistic(0.0, 1.0))
  rand(x)
  x = logistic(logistic(0.0, 1.0), 1.0)
  rand(x)
  x = logistic(1.0, logistic(0.0, 1.0))
  rand(x)
  x = logistic(0.0, 1.0, (1,2,3))
  rand(x)
  x = logistic(logistic(0.0, 1.0, (1,2,3)), logistic(0.0, 1.0, (1,2,3)))
  rand(x)
  x = logistic(logistic(0.0, 1.0, (1,2,3)), 1.0)
  rand(x)
  x = logistic(1.0, logistic(0.0, 1.0, (1,2,3)))
  rand(x)
  x = logistic(logistic(0.0, 1.0, (1,2,3)), logistic(0.0, 1.0))
  rand(x)
  x = logistic(0, 1)
  rand(x)
end

testlogistic()