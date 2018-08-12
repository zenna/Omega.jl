"(x1(ω), x2(ω), ... xn(ω))"
applymany(ω::Ω, xs) = map(xi->xi(ω), xs)

"RandVar{Vector} from Vector{<:RandVar}"
function randarray(x::Array{<:RandVar{T}, N}) where {T, N}
  RandVar{Array{T, N}, true}(applymany, (x,))
end

randtuple(x::UTuple{RandVar}) = URandVar{Tuple{elemtype.(x)...}}(applymany, (x,))