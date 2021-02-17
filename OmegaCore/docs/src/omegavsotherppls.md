# Omega vs other Probabilistic Programming Languages

There are many probabilistic programming languages and libraries.
The objective of Omega is to increase the expressiveness of probabilistic programming languages.  There are models and inference queries that are either impossible or very difficult to express in other PPLs.  In particular:

- In Omega you condition on predicates
- Omega supports likelihood free inference
- Omega supports causal inference
- Omega is fast (and type stable)

# Omega vs ...
- __Turing__: Omega does not yet suport likelihood based inference, although it is planned, so use Turing if that is the case.  Turing currently has more infernece procedures implemented. Omega is more flexible, likely faster, and supports causal and distributional inference.
- __Stan__: Use Stan if you model is expressible in stan, i.e.,  differentiable and of finite dimension.  Otherwise, consider Omega.
- __Pyro, TensorFlow Probability__: Omega does not yet support variational inference (contributions welcome!), so use those frameworks if that is required.

