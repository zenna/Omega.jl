using Mu
import UnicodePlots

fair_coin = bernoulli(0.5)
thrower_bias = uniform([0.5, 0.0, -0.2])

function coin_(ω)
  true_weight = Bool(fair_coin(ω[@id])) ? 0.5 : 0.3
  modified_weight = thrower_bias(ω[@id]) + true_weight
  bernoulli(ω[@id], modified_weight)
end

coin = iid(coin_, Float64)

coinrcd1 = rcd(coin, fair_coin)
means1 = mean(coinrcd1)
samples1 = [rand(means1) for i = 1:1000]
UnicodePlots.histogram(samples1, bins=50)

coinrcd2 = rcd(coin, thrower_bias)
means2 = mean(coinrcd2)
samples2 = [rand(means2) for i = 1:1000]
UnicodePlots.histogram(samples2, bins=50)

coinrcd3 = rcd(coin, thrower_bias + fair_coin)
means3 = mean(coinrcd3)
samples3 = [rand(means3) for i = 1:1000]
UnicodePlots.histogram(samples3, bins=50)

# histogram([samples1, samples2, samples3], layout=(1,3), nbins=50, xlims=[0.0, 1.0], normalize=true, size=(800,300), label="")