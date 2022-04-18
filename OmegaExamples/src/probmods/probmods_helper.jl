# Helper functions for probmods
using UnicodePlots, Distributions, Omega, FreqTables

export viz

"To visualize the generated samples of a random variable"
viz(var::Vector{T} where {T<:Union{String,Char, Symbol}}) =
    barplot(Dict(freqtable(var)))
viz(var::Vector{<:Real}) = histogram(var, symbols = ["■"])
viz(var::Vector{Bool}) = viz(string.(var))
viz(var::Vector{NamedTuple{U, V}}) where {U, V} = 
    barplot(Dict(freqtable(var)), ylabel = string(U[1], ", ", U[2]), xlabel = "Frequency")