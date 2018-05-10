using Mu
using Flux
using UnicodePlots
using DataFrames
using CSV

data = CSV.read(joinpath(ENV["DATADIR"], "mu", "glucosedata.csv"))
## Model
## =====
Mu.defaultomega() = SimpleOmega{Int, Array}

npatients = 5
F_(ω, i) = Flux.Dense(ω[@id][i], 1, 1, Flux.elu)

# Create one network per person
fs = [iid(F_, i) for i = 1:npatients]

"Recurrent Neural Network"
function rnn_(ω, f, nsteps) 
  x = 0.0 # What should this be?
  xs = Float64[]
  for i = 1:nsteps
    x = f(x)[1]
    push!(xs, x)
  end
  xs
end

# Create one simulation RandVar for each patient
nsteps = 10
sims = [iid(rnn_, f, nsteps) for f in fs]

# Take average over time
meansims = mean.(sims)

# Constraint
δ = 0.1
d(x, y) = (x - y)^2
Mu.lift(:d, 2)

## Without RCD
ties = [d(meansims[i], meansims[j]) < δ for i = 1:npatients, j = 1:npatients if i != j]
simulations = rand((sims...), (&)(ties...); OmegaT = Mu.defaultomega())

# # Make Plots
"n simulations, n + 1 simulations, with mean tied"
function plot1()
  plot(Plots.fakedata(50,5), w=3,
       title = "Time vs Glucose Level",
       xaxis = "Time",
       yaxis = "Glucose Level")
end


# ## With RCD
# # Construct random conditional distributions meansims[i] ∥ fs[i]
# means = map(mean ∘ rcd, meansims, fs)

# # Tie expectations
# ties = [d(means[i], means[j]) < δ for i = 1:npatients, j = 1:npatients if i != j]

# # Logical AND of all all the ties
# tie = (&)(tie...)

# # Sample
# rand(sims, tie; OmegaT=Mu.SimpleOmega{Vector{Int}, Array})
