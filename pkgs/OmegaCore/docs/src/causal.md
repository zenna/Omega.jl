# Causal Inference

Omega supports causal inference through the `replace` function.  Causal inference is a topic of much confusion, we recommend this [blog post](https://www.inference.vc/untitled/) for a primer.

## Causal Intervention - the `replace` operator

The `replace` operator models an intervention to a model.
It changes the model.

```@docs
Omega.replace
```

In Omega we use the syntax:

```julia
replace(X, θold => θnew)
```
To mean the random variable `X` where `θold` has been replaced with `θnew`.  For this to be meaningful, `θold` must be a parent of `x`.

Let's look at an example:

```julia
julia> μold = normal(0.0, 1.0)
45:Omega.normal(0.0, 1.0)::Float64

julia> x = normal(μold, 1.0)
46:Omega.normal(Omega.normal, 1.0)::Float64

julia> μnew = 100.0
47:Omega.normal(100.0, 1.0)::Float64

julia> xnew = replace(x, μold => μnew)
julia> rand((x, xnew))
(-2.664230595692529, 96.99998702926271)
```

Observe that the sample from `xnew` is much greater, because it has the mean of the normal distribution has been changed to `100`

### Replace a Random Variable with a Random Variable
Repacing a random variable with a constant is actually a special case of replacing a random variable with another random variable.  The syntax is the same:

```julia
julia> xnewnew = replace(x, μold => normal(200.0, 1.0))
julia> rand((x, xnew, xnewnew))
(-1.2756627673001866, 99.1080578175426, 198.14711316585564)
```

### Changing Multiple Variables

`replace` allow you to change many variables at once  Simply pass in a variable number of pairs, or a dictionary:

```julia
μ1 = normal(0, 1)
μ2 = normal(0, 1)
y = normal(x1 + x2, 1)
xnewmulti = replace(y, μ1 => normal(200.0, 1.0), μ2 => normal(300.0, 1.0))
rand((xnewmulti))
(-1.2756627673001866, 99.1080578175426, 198.14711316585564)
```

# Counterfactuals

The utility of `replace` may not be obvious at first glance.
We can use `replace` and `cond` separately and in combination to ask lots of different kinds of questions.
In this example, we model the relationship betwee the weather outside and teh thermostat reading inside a house.
Broadly, the model says that the weather outside is dictataed by the time of day, while the temperature inside is determined by whether the air conditioning is on, and whether the window is open.

First, setup simple priors over the time of day, and variables to determine whether the air conditioning is on and whether hte iwndow is open:

```julia
timeofday = uniform([:morning, :afternoon, :evening])
is_window_open = bernoulli(0.5)
is_ac_on = bernoulli(0.3)
```

Second, assume that the outside temperature depends on the time of day, being hottest in the afternoon, but cold at night:

```julia
function outside_temp_(rng)
  if timeofday(rng) == :morning
    normal(rng, 20.0, 1.0)
  elseif timeofday(rng) == :afternoon
    normal(rng, 32.0, 1.0)
  else
    normal(rng, 10.0, 1.0)
  end
end
```

Remember, in this style we have to use  `ciid` to convert a function into a `RandVar`

```julia
outside_temp = ciid(outside_temp_, T=Float64)
```

The `inside_temp` before considering the effects of the window is room temperature, unless the ac is on, which makes it colder.

```julia
function inside_temp_(rng)
  if Bool(is_ac_on(rng))
    normal(rng, 20.0, 1.0)
  else
    normal(rng, 25.0, 1.0)
  end
end

inside_temp = ciid(inside_temp_, T=Float64)
```
47:Omega.normal(100.0, 1.0)::Float64

Finally, the thermostat reading is `inside_temp` if the window is closed (we have perfect insulation), otherwise it's just the average of the outside and inside temperature

```julia
function thermostat_(rng)
  if Bool(is_window_open(rng))
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
5-element Array{Any,1}:
 (:afternoon, 0.0, 0.0, 32.349, 26.441, 26.441)   
 (:afternoon, 1.0, 0.0, 30.751, 25.143, 27.947)
 (:morning, 1.0, 0.0, 16.928, 24.146, 20.537)     
 (:afternoon, 1.0, 0.0, 30.521, 25.370, 27.946)
 (:morning, 1.0, 1.0, 16.495, 20.203, 18.349) 
```

### Conditional Inference
- You enter the room and the thermostat reads hot. what does this tell you about the variables?

samples = rand((timeofday, is_window_open, is_ac_on, outside_temp, inside_temp, thermostat),
                thermostat > 30.0, 5, alg = RejectionSample)

```julia

julia> samples = rand((timeofday, is_window_open, is_ac_on, outside_temp, inside_temp, thermostat),
                       thermostat > 30.0, 5, alg = RejectionSample)
5-element Array{Any,1}:
 (:evening, 1.0, 0.0, 33.64609872046609, 26.822449458789542, 30.234274089627817) 
 (:afternoon, 1.0, 0.0, 34.37763909867243, 26.16221853550574, 30.269928817089088)
 (:evening, 1.0, 0.0, 34.32198183192978, 26.6773921624331, 30.499686997181442)   
 (:afternoon, 1.0, 0.0, 34.05126597960254, 26.51833791813246, 30.2848019488675)  
 (:afternoon, 1.0, 0.0, 32.92982568498735, 27.56800059609554, 30.248913140541447)
```

## Counter Factual
- If I were to close the window, and turn on the AC would that make it hotter or colder"

```
thermostatnew = replace(thermostat, is_ac_on => 1.0, is_window_open => 0.0)
diffsamples = rand(thermostatnew - thermostat, 10000, alg = RejectionSample)
julia> mean(diffsamples)
-4.246869797640215
```

So in expectation, that intervention will make the thermostat colder.  But we can look more closely at the distribution:

```
julia> UnicodePlots.histogram([diffsamples...])

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

rand((timeofday, outside_temp, inside_temp, thermostat),
      thermostatnew - thermostat > 0.0, 10, alg = RejectionSample)
