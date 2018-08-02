applymany(ω::Ω, x) = map(xi->xi(ω), x)

"RandVar{Vector} from Vector{<:RandVar}"
function randarray(x::Array{<:RandVar{T}, N}) where {T, N}
  RandVar{Array{T, N}, true}(applymany, (x,))
end

function randtuple(x::UTuple{RandVar})
  RandVar{Tuple{elemtype.(x)...}, true}(applymany, (x,))
end