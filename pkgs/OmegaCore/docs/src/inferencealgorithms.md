# Built-in Inference Algorithms

Omega comes with a number of built in inference algorithms.
You can of course develop your own.

## Choosing a Sampling Algorithm

The appropriate sampling algorithm depends on the kind of model.

- If your model is not conditioned, or the conditions are not very restricting, use `RejectionSample`
- If your model is finite dimensional, continuous and unimodal use `NUTS`
- If your model is finite dimensional, continuous and multimodal use `Replica` with `NUTS`
- If your model is a mixture of discrete and continuous, or not of finite dimension, use `SSMH` or `Replica` with `SSMH`

## Conditional Sampling

Conditional sampling is done with `rand` and the algorithm are selected 

```@docs
RejectionSample
SSMH
NUTS
HMCFAST
```