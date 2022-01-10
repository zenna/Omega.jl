## FAQ

- How to sample from a joint distribution (more than one random variable at a time)?
Pass a tuple of random variables, e.g: `rand((x, y, z))`.  This is __not__ the same as sampling from one variable at a time -- e.g. `x_ = rand(x); y_ = rand(y)`, since these samples have lost dependency information.

- How do I apply a transformation `f` to a random variable 
Some are already defined, e.g. `sqrt(uniform(0, 1))`, for everything else use `lift`, e.g. `lift(f(x))`

- What's the difference between Omega and Probabilistic Programming Language X
In contrast to most PPLs,  Omega takes both random variables and the sample space objects to be first class probabilistic constructs.  This makes it easier to implement conditioning on predicates, causal inference and higher-order inference.  See also: [Omega vs Other PPLS](omegavsotherppls.md). 