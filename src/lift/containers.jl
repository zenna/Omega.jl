"(x1(ω), x2(ω), ... xn(ω))"
applymany(ω::Ω, xs) = map(xi->xi(ω), xs)

"RandVar{Vector} from Vector{<:RandVar}"
randarray(x::Array{<:RandVar, N}) where N = URandVar(applymany, (x,))
# zt: FIXME AbstractArray?

randtuple(x::UTuple{RandVar}) = URandVar(applymany, (x,))

# Lift GetIndex
Base.getindex(x::RandVar, i) = lift(getindex)(x, i)
Base.getindex(x::RandVar, i, is...) = lift(getindex)(x, i, is...)

Base.:*(tpl::Tuple, ::Type{ᵣ}) = randtuple(tpl)
Base.:*(tpl::AbstractArray, ::Type{ᵣ}) = randarray(tpl)

