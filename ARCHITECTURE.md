# Architecture

Omega consists of many subpackages.

- `Omega` - This is a wrapper package that includes and reexports all of the following (and doesn't do much else)
  - `OmegaCore` - Includes:
    - Basic operations to define random variables and condition them
    - Very basic inference through rejection sampling
    - Causal interventions
    - Higher-order operations including the random conditional distribution and random interventional distribution
  - `InferenceBase` - Utilities used by inference methods
  - `OmegaMH` - Metropolis Hastings inference method 
  - `ReplicaExchange` - Replica Exchange inference method
  - `InvolutiveMCMC` - Involutive Markov Chain Monte Carlo