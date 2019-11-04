# Autorand

"`autorand(x::RandVar)` Single sample from `x`.  Inference `alg` and hyperparams, chosen automatically"
autorand(x::RandVar) = rand(x, 1000; alg = SSMH)[end]
Base.getindex(x::RandVar) = autorand(x)