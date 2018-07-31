# Set of small tests for all inference algorithms
using Omega
using UnicodePlots
using Test

"Test extremnity of conditionining set"
function simple(ALG, op, v = 1.0)
  μ = normal(0.0, 1.0)
  x = normal(μ, 1.0)
  samples = rand(μ, op(x, v), 10; alg = ALG)
end

function testall()
  algs = [HMC, SSMH, MI, HMCFAST] # FIXME: subtypes(Omega.Algorithm))
  for ALG in filter(Omega.isapproximate, algs), op in [⪅, ⪆, ≊]
    println("Testing $ALG on $op")
    simple(ALG, op)
  end
end

testall()