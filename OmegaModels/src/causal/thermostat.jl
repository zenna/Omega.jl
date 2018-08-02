# Causal Model
using Omega

timeofday = uniform([:morning, :afternoon, :evening])
is_window_open = bernoulli(0.5)
is_ac_on = bernoulli(0.3)

function outside_temp_(rng)
  if timeofday(rng) == :morning
    normal(rng, 20.0, 1.0)
  elseif timeofday(rng) == :afternoon
    normal(rng, 32.0, 1.0)
  else
    normal(rng, 10.0, 1.0)
  end
end

outside_temp = ciid(outside_temp_, T=Float64)

function inside_temp_(rng)
  if Bool(is_ac_on(rng))
    normal(rng, 20.0, 1.0)
  else
    normal(rng, 25.0, 1.0)
  end
end

inside_temp = ciid(inside_temp_, T=Float64)

function thermostat_(rng)
  if Bool(is_window_open(rng))
    (outside_temp(rng) + inside_temp(rng)) / 2.0
  else
    inside_temp(rng)
  end
end

thermostat = ciid(thermostat_, T=Float64)

# Samples from the prior
rand((timeofday, is_window_open, is_ac_on, outside_temp, inside_temp, thermostat), 5, alg = RejectionSample)

## Conditional Inference: You enter the room and the thermostat reads hot. what does this tell you about the variables?
samples = rand((timeofday, is_window_open, is_ac_on, outside_temp, inside_temp, thermostat),
                thermostat > 30.0, 100, alg = RejectionSample)

## If I were to close the window, and turn on the AC would that make it hotter or colder
thermostatnew = replace(thermostat, is_ac_on => 1.0, is_window_open => 0.0)
diffsamples = rand(thermostatnew - thermostat, 10000, alg = RejectionSample)
UnicodePlots.histogram([diffsamples...])
mean(diffsamples)

## In what scenarios would it still be hotter after turning on the AC and closing the window?
rand((timeofday, outside_temp, inside_temp, thermostat),
      thermostatnew - thermostat > 0.0, 10, alg = RejectionSample)

## Problematic
## If I observe the thermostat to be high, does this make it more likely that it is midday?
mean(cond(timeofday == :afternoon, thermostat > 29.0)) - mean(timeofday == :afternoon)