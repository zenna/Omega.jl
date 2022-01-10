# Omega.jl

Omega.jl is a programming language for causal and probabilistic reasoning.
It was developed by [Zenna Tavares](http://zenna.org) with help from Javier Burroni, Edgar Minasyan, [Xin Zhang](http://people.csail.mit.edu/xzhang/), [Rajesh Ranganath](https://cims.nyu.edu/~rajeshr/) and [Armando Solar Lezama](https://people.csail.mit.edu/asolar/).

## Quick Start

Omega is built in Julia 1.0.  You can easily install it from a Julia repl with:

```julia
(v1.0) pkg> add Omega
```

Check Omega is working and gives reasonable results with: 

```julia
julia> using Omega

julia> rand(normal(0.0, 1.0))
0.7625637212030862
```

With that, see the [Tutorial](basictutorial.md) for a run through of the main features of Omega. 

## Contribute

We want your contributions!

- Probabilistic models
Please add probabilistic models and model families to https://github.com/zenna/OmegaModels.jl

- Inference procedures


## Citation

If you use Omega, please cite Omega papers:

[The Random Conditional Distribution for Uncertain Distributional Properties](http://www.zenna.org/publications/rcd.pdf)

```
@article{tavares2019rcd,
  title={The Random Conditional Distribution for Uncertain Distributional Properties},
  author={Tavares, Zenna and Burroni, Javier and Minaysan, Edgar and Ranganath, Rajesh and Lezama, Armando Solar},
  journal={arXiv},
  year={2019}
}
```

[Predicate exchange: Inference with declarative knowledge](http://www.zenna.org/publications/icmlsoft.pdf)

```
@inproceedings{tavares2019predicate,
  title={Predicate exchange: Inference with declarative knowledge},
  author={Tavares, Zenna and Burroni, Javier and Minasyan, Edgar and Solar-Lezama, Armando and Ranganath, Rajesh},
  booktitle={International Conference on Machine Learning},
  pages={6186--6195},
  year={2019},
  organization={PMLR}
}

```

If you use the causal inference features (`replace`), please cite:

[A Language for Counterfactual Generative Models](http://www.zenna.org/publications/causal.pdf)

```
@misc{tavares2019language,
  title={A language for counterfactual generative models},
  author={Tavares, Zenna and Koppel, James and Zhang, Xin and Solar-Lezama, Armando},
  year={2019}
}
```

## Acknowledgements

Omega leans heavily on the hard work of many packages and the Julia community as a whole, but in particular `Distributions.jl`, `Flux.jl`, and `Cassette.jl`.

## Index

```@contents
```

```@index
```
