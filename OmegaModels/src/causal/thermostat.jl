# Causal Modeling of time of day, ac, window, and thermostat
using Omega

timeofday = uniform([:morning, :afternoon, :evening])
is_window_open = bernoulli(0.5)

"Turn off the a.c. when the window is closed!"
const is_ac_on = ciid(rng -> Bool(is_window_open(rng[@id])) ? false : bernoulli(rng[@id], 0.5))

function is_ac_on_(rng)
  if Bool(is_window_open(rng[@id]))
    false
  else
    bernoulli(rng[@id], 0.5)
  end 
end

function outside_temp_(rng)
  tod = timeofday(rng[@id])
  if tod == :morning
    normal(rng[@id], 20.0, 2.0)
  elseif tod == :afternoon
    normal(rng[@id], 32.0, 2.0)
  else
    normal(rng[@id], 10.0, 2.0)
  end
end

const outside_temp = ciid(outside_temp_, T=Float64)

function inside_temp_(rng)
  if Bool(is_ac_on(rng))
    normal(rng[@id], 20.0, 2.0)
  else
    normal(rng[@id], 25.0, 2.0)
  end
end

const inside_temp = ciid(inside_temp_, T=Float64)

function thermostat_(rng)
  if Bool(is_window_open(rng))
    (outside_temp(rng[@id]) + inside_temp(rng[@id])) / 2.0
  else
    inside_temp(rng[@id])
  end
end

const thermostat = ciid(thermostat_, T=Float64)

## Inference Queries
## =================
using UnicodePlots
using Plots
fontx = Plots.font("Helvetica", 20)
function plothist(samples; bins = 100, xlim = (0.0, 40.0))
  upscale = 8 #8x upscaling in resolution
  Plots.histogram(samples, bins = bins,
                  # bar_edges = true,
                  normalize=true,
                  # aspect_ratio = :equal,
                  size = (800, 600),
                  xlim = xlim,
                  # xticks = [0.0, 0.5, 1.0],
                  yticks = [],
                  xtickfont=fontx,
                  label="")
end

# allvars = (timeofday, is_window_open, is_ac_on, outside_temp, inside_temp, thermostat)

# # Conditioning vs intervening
# priorsamples = rand(outside_temp, 10000, alg = RejectionSample)
# plothist(priorsamples)

# ## Conditional Inference: You enter the room and the thermostat reads hot. what does this tell you about the variables?
# priorsamplescond = rand(outside_temp, thermostat > 30, 10000, alg = RejectionSample)
# plothist(priorsamplescond)

# outside_temp_do = replace(outside_temp, thermostat => 35.0)
# priorsamplesdo = rand(outside_temp_do, 10000, alg = RejectionSample)
# plothist(priorsamplesdo)

# # Prior thermostat reading
# thermopriorsamples = rand(thermostat, 100000, alg = RejectionSample)
# plothist(thermopriorsamples, bins = 100, xlim = (10, 40))
# savefig("priorthermo.svg")

# ## If I were to close the window, and turn on the AC would that make it hotter or colder
# thermostatnew = replace(thermostat, is_ac_on => 1.0, is_window_open => 0.0)
# dosamples = rand(thermostatnew, 100000, alg = RejectionSample)
# plothist(dosamples, bins = 100, xlim = (10, 40))
# savefig("dothermo.svg")


# allsamples = rand((allvars..., thermostatnew - thermostat), 100000, alg = RejectionSample)
# diffsamples = rand(thermostatnew - thermostat, 100000, alg = RejectionSample)
# plothist(diffsamples, bins = 100, xlim = :auto)
# savefig("diffthermo.svg")
# mean(diffsamples)

## In what scenarios would it still be hotter after turning on the AC and closing the window?
rand(timeofday, thermostatnew - thermostat > 0.0, 10, alg = RejectionSample)

julia> rand(timeofday, thermostatnew - thermostat > 0.0, 10, alg = RejectionSample)
10-element Array{Any,1}:
 :evening
 :evening
 :evening
 :morning
 :evening
 :evening
 :evening
 :evening
 :evening
 :evening

## What if we opened the window and turned the AC on (logical inconsistency w.r.t to original model)
thermostat_imposs = replace(thermostat, is_ac_on => 1.0, is_window_open => 1.0)
samples_imposs = rand(thermostat_imposs, 100000, alg = RejectionSample)
plothist(samples_imposs, bins = 100, xlim = (10, 40))
savefig("dothermoimposs.svg")

diffsamples_imposs = rand(thermostat_imposs - thermostat, 10000, alg = RejectionSample)
plothist(diffsamples_imposs, bins = 100, xlim = :auto)
savefig("diffimposs.svg")
mean(diffsamples_imposs)
      
# ## Problematic
# ## If I observe the thermostat to be high, does this make it more likely that it is midday?
# mean(cond(timeofday == :afternoon, thermostat > 29.0)) - mean(timeofday == :afternoon)