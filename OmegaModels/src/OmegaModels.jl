module OmegaModels

using Omega

models = ["mnistnobatching.jl"]
t = include("mnistnobatching.jl")
@show t

end