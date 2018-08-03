# Callbacks

Omega has a useful system for passing callbacks to inference algorithms

Callbacks can be used to
- Plot progress of inference algorithms
- Save data to file

Omega callbacks are organized into a graph of functions which take as input named tuples and return named tuples.

To define a callback simply defined a function of this form, e.g. 

```julia
showiter(data) = println("We are at iteration $(data.i)")
```

Then pass this callback with the keyword argument to `cb` to `rand`:

```julia
x = normal(0.0, 1.0)
rand(x, x > 0.0, 5; cb = showiter)
```

Callbacks can return namedtuples

```julia
showscore(data) = data.
```

To make `showscore` be called with otuput of showiter 


```
callbacks(showiter => showscore)
```


## Callback trees

Often we want to have one callback compute some information and other callbacks use that information.
For example we may want to compute the accuracy of a Bayesian classifier on a test set, but then we may want to either log that to file, log it to tensorboard, or maybe even plot a graph using UnicodePlots.
The callback system has a Callback Tree type to support this case.