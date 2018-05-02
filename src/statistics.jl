## Functions of Random Variables
## =============================
"Expectation of `x`"
Base.mean(x::AbstractRandVar{<:Real}, n=10000) = sum((rand(x) for i = 1:n)) / n
Base.mean(x::AbstractRandVar{T}, n=10000) where {T <: RandVar{<:Real}} =
  RandVar{Float64, false}(mean, (x, n), 0)

"Sample variance (using `n` samples)"
function Base.var(x::AbstractRandVar{<:Real}, n=10000)
  var([rand(x) for i = 1:n])
end

"Sample variance (using `n` samples)"
function Base.var(x::AbstractRandVar{T}, n=10000) where {T <: RandVar{<:Real}}
  RandVar{Float64, false}(var, (x, n))
end

const prob = mean