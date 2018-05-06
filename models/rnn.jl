using Mu
using Flux

npatients = 5
W_(ω, i) = Flux.Dense(ω[@id][i], 1, 1, Flux.elu)
# Create one network per person
fs = [iid(W_, i) for i  = 1:npatients]

"Recurrent Neural Network"
function rnn_(ω, f, nsteps = 4) 
  f = f(ω)
  x = 0.0 # What should this be?
  xs = Float64[]
  for i = 1:nsteps
    x = f(x)[1]
    push!(xs, x)
  end
  xs
end

# Run one simulation for each patient
nsteps = 50
sims = [iid(rnn_, f, nsteps) for f in fs]

# Take average over time
meansims = mean.(sims)

# Construct random conditional distributions meansims[i] ∥ fs[i]
means = map(mean ∘ rcd, meansims, fs)

# Tie expectations
δ = 0.1
d(x, y) = (x - y)^2
Mu.lift(:d, 2)
ties = [d(means[i], means[j]) < δ for i = 1:npatients, j = 1:npatients if i != j]

# Logical AND of all all the ties
tie = (&)(tie...)

# Sample
rand(sims, tie; OmegaT=Mu.SimpleOmega{Vector{Int}, Array})
