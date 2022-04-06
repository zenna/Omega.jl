# Causal Inference

Omega supports causal inference through the `intervene` function.  Causal inference is a topic of much confusion, we recommend this [blog post](https://www.inference.vc/untitled/) for a primer.

## Causal Intervention - the `intervene` operator

The `intervene` operator models an intervention to a model.
It changes the model.

```@docs
Omega.intervene
```

In Omega we use the syntax:

```julia
intervene(X, θold => θnew)
```
To mean the random variable `X` where `θold` has been replaced with `θnew`.  For this to be a worthwhile thing to do, `X` should causally depend on`θold` in the sense that the computation of `X` requires the computation of `θold`.

Let's look at an example:

```julia
julia> μold = @~ Normal(0.0, 1.0)

julia> x = @~ Normal.(μold, 1.0)

julia> μnew = 100.0

julia> xnew = intervene(x, μold => μnew)
julia> randsample((x, xnew))
(-2.664230595692529, 96.99998702926271)
```

Observe that the sample from `xnew` is much greater, because it has the mean of `100`

### Replace a Random Variable with a Random Variable
Repacing a random variable with a constant is actually a special case of replacing a random variable with another random variable.  The syntax is the same:

```julia
julia> xnewnew = intervene(x, μold => @~ Normal(200.0, 1.0))
julia> randsample((x, xnew, xnewnew))
(-1.2756627673001866, 99.1080578175426, 198.14711316585564)
```

### Changing Multiple Variables

`intervene` allow you to change many variables at once -- simply pass in a tuple of pairs:

```julia
μ1 = @~ Normal(0, 1)
μ2 = @~ Normal(0, 1)
y = @~ Normal.(μ1 .+ μ2, 1)
xnewmulti = intervene(y, (μ1 => (@~ Normal(200.0, 1.0)), μ2 => (@~ Normal(300.0, 1.0))))
randsample((xnewmulti))
(-1.2756627673001866, 99.1080578175426, 198.14711316585564)
```

# Counterfactuals

The utility of `intervene` may not be obvious at first glance.
We can use `intervene` and `cnd` separately and in combination to ask lots of different kinds of questions.

In this example, we model the relationship betwee the weather outside and the thermometer reading inside a house.
Broadly, the model says that the weather outside is dictataed by the time of day, while the temperature inside is determined by whether the air conditioning is on, and whether the window is open.

First, setup simple priors over the time of day, and variables to determine whether the air conditioning is on and whether the iwndow is open:

```julia
timeofday = @~ UniformDraw([:morning, :afternoon, :evening])
is_window_open = @~ Bernoulli(0.5)
is_ac_on = @~ Bernoulli(0.3)
```

Second, assume that the outside temperature depends on the time of day, being hottest in the afternoon, but cold at night:

```julia
function outside_temp(ω)
  if timeofday(ω) == :morning
    @~ Normal(ω, 20.0, 1.0)
  elseif timeofday(ω) == :afternoon
    @~ Normal(ω, 32.0, 1.0)
  else
    @~ Normal(ω, 10.0, 1.0)
  end
end
```

The `inside_temp` before considering the effects of the window is room temperature, unless the ac is on, which makes it colder.

```julia
function inside_temp_(rng)
  if is_ac_on(rng)
    normal(rng, 20.0, 1.0)
  else
    normal(rng, 25.0, 1.0)
  end
end

inside_temp = ciid(inside_temp_, T=Float64)
```

Finally, the thermostat reading is `inside_temp` if the window is closed (we have perfect insulation), otherwise it's just the average of the outside and inside temperature

```julia
function thermostat_(rng)
  if is_window_open(rng)
    (outside_temp(rng) + inside_temp(rng)) / 2.0
  else
    inside_temp(rng)
  end
end

thermostat = ciid(thermostat_, T=Float64)
```
Now with the model built, we can ask some questions:

### Samples from the prior
The simplest task is to sample from the prior:

```julia
julia> rand((timeofday, is_window_open, is_ac_on, outside_temp, inside_temp, thermostat), 5, alg = RejectionSample)
5-element Array{Tuple{Symbol,Bool,Bool,Float64,Float64,Float64},1}:
 (:evening, true, false, 10.310689624432637, 26.144122188682584, 18.22740590655761)
 (:afternoon, false, false, 32.30806450465544, 22.861739827796345, 22.861739827796345)
 (:morning, false, false, 20.161172183596964, 25.128141190979573, 25.128141190979573)
 (:evening, true, false, 10.239806337680982, 26.81486040128365, 18.527333369482314)
 (:morning, true, false, 20.56559745560037, 27.380632072360157, 23.973114763980263)
```

### Conditional Inference
- You enter the room and the thermostat reads hot. what does this tell you about the variables?

```julia

julia> samples = rand((timeofday, is_window_open, is_ac_on, outside_temp, inside_temp, thermostat),
                       thermostat > 30.0, 5, alg = RejectionSample)
5-element Array{Tuple{Symbol,Bool,Bool,Float64,Float64,Float64},1}:
 (:afternoon, true, false, 32.66172359406305, 28.459719413318684, 30.560721503690864)
 (:afternoon, true, false, 33.411018400286764, 26.638821969105173, 30.02492018469597)
 (:afternoon, true, false, 32.92666992107552, 27.87634864444088, 30.4015092827582)
 (:afternoon, true, false, 34.941029761615916, 25.66825864439438, 30.304644203005147)
 (:afternoon, true, false, 33.82296040117437, 26.237305008998273, 30.030132705086324)
```

## Counter Factual
- If I were to close the window, and turn on the AC would that make it hotter or colder"

```
thermostatnew = intervene(thermostat, is_ac_on => true, is_window_open => false)
diffsamples = rand(thermostatnew - thermostat, 10000, alg = RejectionSample)
julia> mean(diffsamples)
-4.246869797640215
```

So in expectation, that intervention will make the thermostat colder.  But we can look more closely at the distribution:

```
julia> UnicodePlots.histogram(diffsamples)

                 ┌────────────────────────────────────────┐ 
   (-11.0,-10.0] │ 37                                     │ 
    (-10.0,-9.0] │▇▇▇▇ 502                                │ 
     (-9.0,-8.0] │▇▇▇▇▇▇▇▇▇▇▇ 1269                        │ 
     (-8.0,-7.0] │▇▇▇▇▇ 581                               │ 
     (-7.0,-6.0] │▇▇▇▇ 497                                │ 
     (-6.0,-5.0] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 3926 │ 
     (-5.0,-4.0] │▇ 65                                    │ 
     (-4.0,-3.0] │ 5                                      │ 
     (-3.0,-2.0] │ 3                                      │ 
     (-2.0,-1.0] │▇ 97                                    │ 
      (-1.0,0.0] │▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 1960                  │ 
       (0.0,1.0] │▇▇▇▇ 494                                │ 
       (1.0,2.0] │▇▇ 197                                  │ 
       (2.0,3.0] │▇▇ 237                                  │ 
       (3.0,4.0] │▇ 118                                   │ 
       (4.0,5.0] │ 12                                     │ 
                 └────────────────────────────────────────┘ 
```

- In what scenarios would it still be hotter after turning on the AC and closing the window?

```
julia> rand((timeofday, outside_temp, inside_temp, thermostat), thermostatnew - thermostat > 0.0, 5, alg = RejectionSample)
5-element Array{Tuple{Symbol,Float64,Float64,Float64},1}:
 (:evening, 8.99858009405822, 26.42261048649467, 17.710595290276444)
 (:evening, 11.016416633842283, 24.852317088939945, 17.934366861391112)
 (:evening, 9.744613418296744, 25.556084959799456, 17.6503491890481)
 (:evening, 9.381925134669295, 25.6283276833937, 17.505126409031497)
 (:evening, 9.121300508670375, 25.182478479511474, 17.151889494090923)
```
# Causal Patterns