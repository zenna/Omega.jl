
"KL Divergence between `x` and `y`"
function KLdivergence(x::RandVar{<:Real}, y::RandVar{<:Real})
  10.0
end

KLdivergence(x::AbstractRandVar{T}, y::RandVar{<:Real}) where {T <: RandVar{<:Real}} =
  RandVar{Float64, false}(x -> KLdivergence(x, y), (x,), 0)