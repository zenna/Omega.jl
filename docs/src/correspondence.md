THe `replace` operator in Omega allows us to ask what-if questions.
This raises thorny problems that are both philosophcal and technical.
In particula, when we construct a counter-factual what-if scenario, what should be preserved from the "real" world to the counterfactual world?

Consider the following example:

```julia
coin = bernoulli(0.5, Bool)
function x_(rng)
  coin_ = coin(rng)
  if coin
    @show b = normal(rng, 0, 1)
  else
    @show b = normal(rng, 0, 1)
  end
  (coin = coin_, b = b)
end
x = ciid(x_)
```

Let's draw a sample where y is false
```
rand(x, )
```


In a counterfactual world, we replace force y to be true

```
xnew = replace(x, y => true)
```

```
label(x, nm) = ciid(w -> (println("in $nm"); x(w)))
xsum = label(xnew, "xnew") + label(x, "x")
```