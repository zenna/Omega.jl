function Base.rand(x::Vector{<:RandVar})
  rand()
end

function whonwos(x)
  ω -> [xi(ω) for xi in x]
end

"RandVar{Vector} from Vector{<:RandVar}"
function randvec(x::Vector{<:RandVar{T}}) where T
  RandVar{Vector{T}}(ω -> [xi(ω) for xi in x], 3)
  RandVar{Vector{T}}(whoknows, x)
end