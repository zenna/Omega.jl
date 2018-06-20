using Mu
using Plots
using Distributions
import UnicodePlots
import StatPlots

"Sample from truncated distribution"
function truncate(x, lb, ub, k; kwargs...)
  withkernel(k) do
    rand(x, (lb < x) & (x < ub); kwargs...)
  end
end

function sample()
  x = normal(0.0, 1.0)
  αs = [0.1, 1.0, 10.0, 100.0]
  kernels = Omega.kseα.(αs)
  samples = truncate.(x, 0.0, 1.0, kernels; n = 100000)
end

function subplot(samples, α, plt = Plots.plot())
  StatPlots.density!(samples, label = "a = $α",
                    #  m=(0.001,:auto),
                     style = :auto,
                     w = 2.0)
end

function plot(samples)
  plt = Plots.plot(title = "Truncated Normal through Conditioning")
  αs = [0.1, 1.0, 10.0, 100.0]
  subplot.(samples, αs, plt)
  plt
  savefig(plt, joinpath(ENV["DATADIR"], "mu", "figures", "truncated.pdf"))
  plt
end

function main()
  plot(sample())
end

