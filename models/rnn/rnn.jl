using Mu
using Flux
using UnicodePlots
using DataFrames
using CSV

data = CSV.read(joinpath(ENV["DATADIR"], "mu", "glucosedata.csv"))
## Model
## =====
Mu.defaultomega() = SimpleOmega{Vector{Int}, Array}

# Constraint
δ = 0.1
d(x, y) = (x - y)^2
Mu.lift(:d, 2)

npatients = 5
F_(ω, i) = Flux.Dense(ω[@id][i], 5, 1, Flux.elu)

# Create one network per person
fs = [iid(F_, i) for i = 1:npatients]

"Recurrent Neural Network"
function rnn_(ω, f, nsteps) 
  x = 0.0 # What should this be?
  xs = []
  for i = 1:nsteps
    x = f(x)[1]
    push!(xs, x)
  end
  [xs...]
end

# Create one simulation RandVar for each patient
nsteps = 20
sims = [iid(rnn_, f, nsteps) for f in fs]

# Take average over time
meansims = mean.(sims)

## Without RCD
ties = [d(meansims[i], meansims[j]) < δ for i = 1:npatients, j = 1:npatients if i != j]
simulations = rand((sims...), (&)(ties...); OmegaT = Mu.defaultomega())

function traces(data, i, measure = 807)
  people = groupby(data, :Id)
  p1 = people[i]
  p2 = filter(row -> row[:Measure] == measure, p1)
  sort(p2, :Time)
end

"wow!"
function datacond(data, sim, personid)
  exampledata = traces(data, personid)
  rng = 1:min(nsteps, nrow(exampledata))
  obvglucose = normalize(Float64.(exampledata[:Value])[rng])
  datacond = sim[rng] == obvglucose
  datacond, obvglucose
end

d1, obvglucose = datacond2(data, sims[1], 3)
simsω = rand(Mu.defaultomega, d1, HMC, n=1000000);

## Plots
## ====
using Plots
"n simulations, n + 1 simulations, with mean tied"
function plot1(sims, dpi = 80)
  p = Plots.plot(sims, w=3,
                 title = "Time vs Glucose Level",
                 xaxis = "Time",
                 yaxis = "Glucose Level",
                 fmt = :pdf,
                 size = (Int(5.5*dpi), 2*dpi),
                 dpi = dpi)
  savefig(p, joinpath(ENV["DATADIR"], "mu", "figures", "test.pdf"))
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

traces(data, 3)[:Value]
plot1([sims[1](simsω[end]), obvglucose])