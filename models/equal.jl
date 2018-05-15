using Mu
using Plots
using Distributions
import UnicodePlots
import PlotRecipes

"Sample from truncated distribution"
function condequal(x, y, k; kwargs...)
  withkernel(k) do
    rand((x, y), x == y; kwargs...)
  end
end

function sample(αs)
  x = normal(0.0, 1.0)
  y = normal(0.0, 1.0)
  kernels = Mu.kseα.(αs)
  samples = condequal.(x, y, kernels; n = 100000)
end

function subplot(samples, α, plt = Plots.plot())
  x_, y_ = ntranspose(samples)
  PlotRecipes.marginalhist(x_, y_)
end

using ZenUtils

function plotequal(samples, αs)
  # l = @layout [a; b; c; d]
  subplots = subplot.(samples, αs)
  plt = plot(subplots..., layout = (1, length(αs)),
      #  title = "Equality in Distribution",
             fmt = :pdf,
             size = (1000, 200),
             title_location=:left)
  savefig(plt, joinpath(ENV["DATADIR"], "mu", "figures", "equal.pdf"))
  plt
end

function main(;αs = [0.1, 1.0, 10.0, 100.0, 1000.0], samples = sample(αs))
  plotequal(samples, αs)
end

