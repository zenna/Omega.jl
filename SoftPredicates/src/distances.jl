"Distance between two values"
function d end

@inline d(x::Real, y::Real) = (xy = (x - y); xy * xy)
# @inline d(x::Vector{<:Real}, y::Vector{<:Real}) = norm(x - y)
@inline d(x::AbstractVector{<:Real}, y::AbstractVector{<:Real}) = sum(d.(x,y))
@inline d(x::NTuple{N, <: Real}, y::NTuple{N, <:Real}) where N = sum(d.(x,y))
@inline d(x::AbstractArray{<:Real}, y::AbstractArray{<:Real}) = norm(x[:] - y[:])

"Distance from x to [a, b]"
function bound_loss(x, a, b)
  # @pre b >= a
  if x < a
    a - x
  elseif x > b
    x - b
  else
    zero(x)
  end
end