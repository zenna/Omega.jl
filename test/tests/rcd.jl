using Omega
using Omega: samplemeanᵣ
using UnicodePlots
using Distributions

function test()
  μ1 = bernoulli(0.5)
  μ2 = bernoulli(0.5)
  μ = μ1 + μ2

  c1 = rcd(normal(μ, 1.0), μ1)
  nsamples = 100
  means1 = [rand(samplemeanᵣ(c1, nsamples)) for i = 1:1000]
  println(UnicodePlots.histogram(means1))
  
  c2 = rcd(normal(μ, 1.0), μ2)
  means2 = [rand(samplemeanᵣ(c2, nsamples)) for i = 1:1000]
  println(UnicodePlots.histogram(means2))
  
  c3 = rcd(normal(μ, 1.0), μ)
  means3 = [rand(samplemeanᵣ(c3, nsamples)) for i = 1:1000]
  println(UnicodePlots.histogram(means3))
end

test()

# function testbeta()
#   plotbeta(beta) = lineplot(i->Distributions.pdf(beta, i), 0.0001, 0.999)
#   α = uniform(0.001, 5.0)
#   β = uniform(0.001, 5.0)
#   b = betarv(α, β)
#   brcd = b ∥ₛ (α, β)
#   samples = rand((α, β), samplemeanᵣ(brcd) ==ₛ 0.5, SSMH; n = 100)
#   s = Distributions.Beta(rand(samples)...); plotbeta(s)
#   s = Distributions.Beta(rand(samples)...); plotbeta(s)
#   samples2 = rand((α, β), mean(brcd) ==ₛ α, SSMH; n = 100)  
# end

# testbeta()

# # RCD here is not correct
# function testbad()
#   α = rademacher(0.5)
#   β = rademacher(0.5) * α
#   γ = rademacher(0.5) + α + β
#   samples = [rand(mean(γ ∥ (α, β))) for i = 1:1000]
# end

# testbad()