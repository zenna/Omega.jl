## Functions of Random Variables
## =============================
"Expectation of `x`"
Base.mean(x::AbstractRandVar{Real}, n=1000) = sum((rand(x) for i = 1:n)) / n
Base.mean(x::AbstractRandVar{RandVar{Real}}, n=1000) =
  RandVar{Real}(ω -> mean(x(ω), n), ωids(x))