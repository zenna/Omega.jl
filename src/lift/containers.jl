"(x1(ω), x2(ω), ... xn(ω))"
applymany(ω::Ω, xs) = map(xi->xi(ω), xs)

"RandVar{Vector} from Vector{<:RandVar}"
randarray(x::Array{<:RandVar, N}) where N = URandVar(applymany, (x,))

randtuple(x::UTuple{RandVar}) = URandVar(applymany, (x,))

Base.:*(tpl::Tuple, ::Type{ᵣ}) = randtuple(tpl)
Base.:*(tpl::AbstractArray, ::Type{ᵣ}) = randarray(tpl)