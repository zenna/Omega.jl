# Set of small tests for all inference algorithms
using Omega
using UnicodePlots
using Test

"Test extremnity of conditionining set"
function simple1(ALG, v = 1.0)
  μ = normal(0.0, 1.0)
  x = normal(μ, 1.0)
  samples = rand(μ, x = v, ALG)
end

"Test extremnity of conditionining set with inequalities"
function simple1(ALG, v = 1.0)
  μ = normal(0.0, 1.0)
  x = normal(μ, 1.0)
  samples = rand(μ, x > v, ALG)
end

"Test extremnity of conditionining set with inequalities"
function simple1(ALG, v = 1.0)
  μ = normal(0.0, 1.0)
  x = normal(μ, 1.0)
  samples = rand(μ, x < v, ALG)
end

"Test scaling to number of dimensiosn"
function simple2(ndim, ALG)
  x = normal(0.0, 1.0, (ndim,))
  samples = rand(x, sum(x) == 1.0, ALG)
end

function testall()
  for ALG in subtypes(Omega.Algorithm)
    println("Testing $ALG")
    simple1(ALG)
  end
end