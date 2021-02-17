# Callbacks

Omega uses [Lenses](https://github.com/zenna/Lens.jl) and Callbacks to support queries such as:

- Time left until the simulation end
- Convergence properties of the Markov Chains
- Periodically saving results to disk

Each inference procedure exports some lenses.
Currently these are of the form `InferenceAlgLoop`.  For example, the inference procedure`SSMH` has `SSMHLoop` lens called after each sample.

## Usage


```julia
using Callbacks, Lens
x = ~ ω -> (sleep(0.001); normal(ω, 0, 1))
@leval Loop => showprogress(10000) rand(x, 10000) 
```

```julia
using Omega.Inference: SSMHLoop
x =~ ω -> (sleep(0.001); normal(ω, 0, 1))
@leval SSMHLoop => plotloss() rand(x, x >ₛ 0.0, 10000; alg = SSMH)
@leval SSMHLoop => default_cbs(10000) rand(x, x >ₛ 0.0, 10000; alg = SSMH)
```
## Default Callbacks

`default_cbs(n)` returns a callback that displays a bunch of information likely to be useful, such as processbar, the likelihood, etc.  It takes as input `n`, the number of samples:

Example usage:

```julia
using Omega
x = ω -> (sleep(0.001); normal(ω, 0, 1))
@leval SSMHLoop => default_cbs(10000) rand(x, x >ₛ 0.0, 10000; alg = SSMH)
```