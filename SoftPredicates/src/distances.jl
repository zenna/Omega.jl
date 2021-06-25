"Distance between two values"
function dist end

# zt: these choices seem a little adhoc.  Should I specialise by type

@inline dist(x::Real, y::Real) = (xy = (x - y); xy * xy)
# @inline dist(x::Vector{<:Real}, y::Vector{<:Real}) = norm(x - y)
@inline dist(x::AbstractVector{<:Real}, y::AbstractVector{<:Real}) = sum(dist.(x, y))
@inline dist(x::NTuple{N,<: Real}, y::NTuple{N,<:Real}) where N = sum(dist.(x, y))
@inline dist(x::AbstractArray{<:Real}, y::AbstractArray{<:Real}) = norm(x[:] - y[:])

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