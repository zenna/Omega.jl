## Sampling and Inference
## ======================
"Unconditional Sample from `x`"
Base.rand(x::UTuple{RandVar}) = x(DictOmega())

"Unconditional Sample from `x`"
Base.rand(x::RandVar) = x(DirtyOmega())