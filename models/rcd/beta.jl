using Omega
using UnicoodePlots
using Distriibutions

etar = 0.75
plotbeta(beta) = lineplot(i->Distributions.pdf(beta, i), 0.0001, 0.999)

function fancyplotbeta(beta)
  Plots.plot(i->Distributions.pdf(beta, i), -0.001, 1.001, label="",
             linewidth = 2,
             xtickfont = font(20),
             ytickfont = font(20),
            #  ylims = (0, 3)
             )
end

α = uniform(0.001, 5.0)
β = uniform(0.001, 5.0)
b = betarv(α, β)
brcd = b ∥ (α, β)

samples = rand((α, β), mean(brcd) == etar, SSMH)
# s = Distributions.Beta(rand(samples)...); plotbeta(s) ; mean(s)
while true
  s = Distributions.Beta(rand(samples)...)
  println(mean(s))
  if abs(mean(s) - etar) < 0.01
    println(plotbeta(s))
    break
  end
end
samples2 = rand((α, β), mean(brcd) == α, SSMH)