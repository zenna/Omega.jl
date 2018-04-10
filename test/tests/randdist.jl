using Mu
using UnicodePlots

function test()
  μ1 = bernoulli(0.5)
  μ2 = bernoulli(0.5)
  μ = μ1 + μ2

  c1 = randdist(normal(μ, 1.0), μ1)
  means1 = [rand(mean(c1)) for i = 1:1000]
  println(UnicodePlots.histogram(means1))
  
  c2 = randdist(normal(μ, 1.0), μ2)
  means2 = [rand(mean(c2)) for i = 1:1000]
  println(UnicodePlots.histogram(means2))
  
  c3 = randdist(normal(μ, 1.0), μ)
  means3 = [rand(mean(c3)) for i = 1:1000]
  println(UnicodePlots.histogram(means3))
end

test()