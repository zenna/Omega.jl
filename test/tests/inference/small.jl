"Set of small tests for all inference algorithms"
module TestNamespace

using Omega
using UnicodePlots
using Test
using InteractiveUtils: subtypes

function simple(ALG, op, v = 1.0)
  μ = normal(0.0, 1.0)
  x = normal(μ, 1.0)
  samples = rand(μ, op(x, v), 10; alg = ALG)
end

function testall()
  algs = [ALG() for ALG in subtypes(Omega.Inference.SamplingAlgorithm)]
  for ALG in filter(Omega.isapproximate, algs), op in [<ₛ, >ₛ, ==ₛ]
    println("Testing $ALG on $op")
    simple(ALG, op)
  end
end

testall()

end