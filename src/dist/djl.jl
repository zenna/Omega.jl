djldist(::T, params...) where {T <: RandVar} = djltype(T)(params...)

djltype(::Type{<:Prim.Uniform}) = Djl.Uniform
djltype(::Type{<:Prim.Normal}) = Djl.Normal
djltype(::Type{<:Prim.Beta}) = Djl.Beta
djltype(::Type{<:Prim.Bernoulli}) = Djl.Bernoulli
djltype(::Type{<:ReplaceRandVar{Prim}}) where Prim = djltype(Prim)

mayberand(x::RandVar) = rand(x)
mayberand(c) = c

"Convert `rv` into a Distributions.jl `Distribution``"
function distributionsjl(rv::RandVar) 
  θs = Prim.params(rv)
  θisconst = Prim.isconstant.(θs)
  @pre all(θisconst) "All params must be constant to convert to Distributions"
  θsc = mayberand.(θs)
  djldist(rv, θsc...)
end


# distribution(f::F, args) where F = djltype(F)(args...)
# djltype(::typeof(normal)) = Distributions.Normal
# djltype(::typeof(betarv)) = Distributions.Beta
# djltype(::typeof(uniform)) = Distributions.Uniform
