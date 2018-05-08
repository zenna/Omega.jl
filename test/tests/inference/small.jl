# Set of small tests for all inference algorithms
using Mu
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
function simple2(ndim = ALG)
  x = normal(0.0, 1.0, (ndim,))
  samples = rand(x, sum(x) = 1.0, ALG)
end

"Test equality of random variables"
function simpleeq(ALG)
  x = normal(0.0, 1.0)
  y = normal(0.0, 1.0)
  diff = abs(x - y)
  β = kumaraswamy(1.0, 3.0)
  k = Mu.kf1β(β)
  # α = uniform(0.0, 5.0)
  # α = 3.0
  # k = Mu.kseα(α)
  n = 5000000
  OmegaT = SimpleOmega{Int, Float64}
  samples = rand(OmegaT, ≊(x, y, k), ALG;
                 n = n,
                 cb = [Mu.default_cbs(n);
                       throttle(Mu.plotrv(β, "Temperature: β"), 1);
                       throttle(Mu.plotω(x, y), 1);
                       throttle(Mu.plotrv(diff, "||x - y||"), 1)])
end

for ALG in Mu.Algorithm
  println("Testing $ALG")
  simple1(ALG)
end

function showkernel()
  x = y = linspace(-5, 5, 40)
  zs = zeros(0,40)
  n = 100
  f(x,y) = Mu.f1(Mu.d(x, y), 0.0001)
  p = plot(x, y, f, st = [:surface, :contourf])
end
