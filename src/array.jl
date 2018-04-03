applymany(x, ω::Omega) = map(xi->xi(ω), x)

"RandVar{Vector} from Vector{<:RandVar}"
function randarray(x::Array{<:RandVar{T}, N}) where {T, N}
  RandVar{Array{T, N}, true}(applymany, (x,))
end

# function randtuple(x::Tuple{<:RandVar})
#   RandVar{Tuple{}}(applymany, (x,))
# end