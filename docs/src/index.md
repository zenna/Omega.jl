# Omega.jl

Omega.jl is a small programming language for causal and probabilistic reasoning.
It was developed by Zenna Tavares with help from Javier Burroni, Edgar Minasyan, Xin Zhang, Rajesh Ranganath and Armando Solar Lezama.

## Quick Start

Omega is built in Julia 0.7 but not yet in the official Julia Package repository.  You can still easily install it from a Julia repl with:

```julia
(v0.7) pkg> add https://github.com/zenna/Omega.jl.git
```

Check Omega is working and gives reasonable results with: 

```julia
julia> using Omega

julia> rand(normal(0.0, 1.0))
0.7625637212030862
```

With that, see the [Tutorial](@basictutorial) for a run through of the main features of Omega. 

## Contribute

We want your contributions!

- Probabilistic models
- Contribute an inference procedure


## Citation

If you use Omega, please cite Omega paper.
<!-- If you use the causal inference features, please cite. -->
In addition, if you use the higher-order features, please cite the random conditional distribution paper.

## Acknowledgements

Omega leans heavily on the hard work of many packages and the Julia community as a whole, but in particular `Distributions.jl`, `Flux.jl`, and `Cassette.jl`.

```@contents
```

```@index
```
