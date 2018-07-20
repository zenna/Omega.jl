using Omega 
using Plots

faircoin = bernoulli(0.5)
headsbiased = bernoulli(0.5)
function coin_(ω)
  weight = if Bool(faircoin(ω))
    0.5
  elseif Bool(headsbiased(ω))
    0.6
  else
    0.4
  end
  Bool(bernoulli(ω, weight))
end

coin = iid(coin_)
coinrcd = coin ∥ (faircoin, headsbiased)
probdist = prob(coinrcd, 100000)
nsamples = 100
probsamples = [rand(probdist) for i = 1:nsamples]

fig = histogram(probsamples, nbins=100, xlims=[0.0, 1.0], normalize=true, size=(400, 300), label="")
savefig(fig, "coindist.png")
