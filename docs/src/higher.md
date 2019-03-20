# Distributional Inference

!!! note
    **TLDR**: Omega allows you to turn a distributional property (e.g. `mean`, `var`, `kurtosis`), from a concrete value (e.g. a `Float64`) into a `RandVar`.  These `RandVar`s can then be conditioned.
    
    Use either `rcd`, `rcdₛ` or `rid`.

    ```@docs
    rcd
    rid
    rcdₛ
    ```
    `rid` are `rcd` are equivlaet in some cases.
    `rid` is much more efficient, so use that if possible.
    If they are not equivlanet and you must use `rcd`, it's likely you will want to use the `rcdₛ` which uses soft equality [ref]


Since this is a new concept, it requires some explanation.

# Random Distributional Properties
Distributional properties are fixed (often real) values, but in a sense they are random variables too.
For example, rainfall depends on temperature, the season, the presence of clouds, and so on.
With respect to a model, expected rainfall is a real value, but it changes if we obtain new information.
For example it rises if we observe clouds and falls to zero if we observe their absence.
These two expectations becomes a random variable over expectations -- a conditional expectation -- when we take into account the probabilities of the presence or absence of clouds.
Moreover, for each random variable in the model there is a corresponding conditional expectation.
For instance, with respect to the season, conditional expected rainfall is a random variable over four expectations, one for each season; with respect to temperature it is a continuous distribution.
These conditional expectations capture the uncertainty over expected rainfall that results from other variables in the model, whereas the unconditional expected rainfall averages all the uncertainty away.

Omega has a number of mechanisms to automatically capture the uncertainty over any distributional property.  It is based on a new concept called the random conditional distribution.

## Random Conditional Distribution

```@docs
rcd
```

## Random Interventional Distribution

```@docs
rid
```
## rcd or rid?
In many cases `rcd` and `rid` are equivalent.  In these cases you should prefer `rid`, since it is much more efficient. 
The conditions with which they are equivalent are a bit subtle.