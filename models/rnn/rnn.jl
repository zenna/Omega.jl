using Mu
using Flux
using UnicodePlots
using DataFrames
using CSV

Mu.defaultomega() = SimpleOmega{Vector{Int}, Array}

δ = 0.1
d(x, y) = (x - y)^2
Mu.lift(:d, 2)

"Recurrent Neural Network"
function rnn_(ω, f, nsteps, h1_size) 
  h = zeros(h1_size) # What should this be?
  xs = []
  input = vcat(0, h)
  for i = 1:nsteps
    input = f(input)
    x = input[1]
    push!(xs, x)
  end
  [xs...]
end

# function rnn_(ω, f, nsteps) 
#   xs = []
#   for i = 1:nsteps
#     x = f(i)[1]
#     push!(xs, x)
#   end
#   [xs...]
# end

function model(nsteps, h1_size=10, h2_size=30)
  npatients = 5
  function F_(ω, i)
    other = Chain(
              Flux.Dense(ω[@id][i][2], h1_size, h2_size, Flux.relu),
              Flux.Dense(ω[@id][i][3], h2_size, 1, Flux.sigmoid))
    Chain(
      Flux.Dense(ω[@id][i][1], 1 + h1_size, h1_size, Flux.relu),
      h -> vcat(other(h), h))
  end

  # Create one network per person
  fs = [iid(F_, i) for i = 1:npatients]

  # Create one simulation RandVar for each patient
  sims = [iid(rnn_, f, nsteps, h1_size) for f in fs]

  # Take average over time
  meansims = mean.(sims)
  sims, meansims
end

# function ok()
#   ties = [d(meansims[i], meansims[j]) < δ for i = 1:npatients, j = 1:npatients if i != j]
#   simulations = rand((sims...), (&)(ties...); OmegaT = Mu.defaultomega())

#   d1, obvglucose = datacond2(data, sims[1], 3)
#   simsω = rand(Mu.defaultomega, d1, HMC, n=1000000);
# end

function traces(data, i, measure = 807)
  people = groupby(data, :Id)
  p1 = people[i]
  p2 = filter(row -> row[:Measure] == measure, p1)
  sort(p2, cols = [:Time,])
end

"Data condition, returns (sim == peronid.data, peronid.data)"
function datacond(data, sim, personid, nsteps)
  exampledata = traces(data, personid)
  range = 1:min(nsteps, nrow(exampledata))
  obvglucose = normalize(Float64.(exampledata[:Value])[range])
  datacond = sim[range] == obvglucose
  datacond, obvglucose
end

"Load the data"
loaddata() = CSV.read(joinpath(ENV["DATADIR"], "mu", "glucosedata.csv"))

"Data, model, condition"
function infer(nsteps = 20;n=1000, h1 = 10)
  y, obvglucose, sims = conditioned_model(nsteps)
  # @assert false
  simsω = rand(SimpleOmega{Vector{Int}, Flux.TrackedArray}, y, HMCFAST, n=n, stepsize = 0.01)
  # simsω = rand(SimpleOmega{Vector{Int}, Flux.Array}, y, HMC, n=10000)
  simsω, obvglucose, sims
end

function conditioned_model(nsteps = 20; h1 = 10, h2=30)
  data = loaddata()
  sims, meansims = model(nsteps, h1_size = h1, h2_size = h2)
  personid = 3
  y, obvglucose = datacond(data, sims[1], personid, nsteps)
  y, obvglucose, sims
end

## Plots
## ====
using Plots
"n simulations, n + 1 simulations, with mean tied"
function plot1(sims, dpi = 80, save = false)
  p = Plots.plot(sims, w=3,
                 title = "Time vs Glucose Level",
                 xaxis = "Time",
                 yaxis = "Glucose Level",
                 fmt = :pdf,
                 size = (Int(5.5*dpi), 2*dpi),
                 dpi = dpi)
  save && savefig(p, joinpath(ENV["DATADIR"], "mu", "figures", "test.pdf"))
  p
end

nipssize() = ()

function setupplots()
  upscale = 1 #8x upscaling in resolution
  fntsm = Plots.font("sans-serif", 10.0*upscale)
  fntlg = Plots.font("sans-serif", 14.0*upscale)
  default(titlefont = fntlg, guidefont=fntlg, tickfont=fntsm, legendfont=fntsm)
  default(size = (500*upscale, 300*upscale)) #Plot canvas size
  default(dpi = 300) #Only for PyPlot - presently broken
end

function main(n=1000)
  simsω, obvglucose, sims = infer(n=n)
  plot1([Flux.data.(sims[1](simsω[end])), obvglucose])end

function plot_idx(idx, simsω, sims, obvglucose)
  plot1([Flux.data.(sims[1](simsω[idx])), obvglucose])
end

function mindistance(simsω, sims, obvglucose, norm_=2)
  k = length(obvglucose)
  sim = sims[1]
  norms = map(enumerate(simsω)) do idx, ω 
    norm(Flux.data.(ω |> sim)[1:k] - obvglucose, norm_) 
  end
  p, id_ = findmin(norms)
end

function plot_minimum(simsω, sims, obvglucose, norm_=2)
  @show p, id_ = mindistance(simsω, sims, obvglucose, norm_=norm_)
  plot_idx(id_, simsω, sims, obvglucose)
end
