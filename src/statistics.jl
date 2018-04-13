## Functions of Random Variables
## =============================
"Expectation of `x`"
Base.mean(x::AbstractRandVar{<:Real}, n=1000) = sum((rand(x) for i = 1:n)) / n
Base.mean(x::AbstractRandVar{T}, n=1000) where {T <: RandVar{<:Real}} =
  RandVar{T, false}(mean, (x, n), 0)