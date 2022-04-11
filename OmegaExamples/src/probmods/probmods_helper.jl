# Helper functions for probmods
using UnicodePlots, Distributions, Omega, FreqTables, PDMats

export viz, pget, Dirichlet, viz_marginals, DiagNormal

"To visualize the generated samples of a random variable"
viz(var::Vector{T} where {T<:Union{String,Char, Symbol}}) =
    barplot(Dict(freqtable(var)))
viz(var::Vector{<:Real}) = histogram(var, symbols = ["■"])
viz(var::Vector{Bool}) = viz(string.(var))
viz(var::Vector{NamedTuple{U, V}}) where {U, V} = 
    barplot(Dict(freqtable(var)), ylabel = string(U[1], ", ", U[2]), xlabel = "Frequency")

function viz_marginals(var::Vector{NamedTuple{U, V}}) where {U, V}
    c = barplot(Dict(freqtable(string.(U[1], "_", map(x -> x[U[1]], var)))))
    for i in 2:length(U)
        barplot!(c, Dict(freqtable(string.(U[i], "_", map(x -> x[U[i]], var)))))
    end
    c
end

# Required aditional distributions -
struct Dirichlet{V}
    α::V
end
Dirichlet(k::Int64, a::Real) = Dirichlet(a .* ones(k))

function (d::Dirichlet)(i, ω)
    gammas = [((i..., j) ~ Gamma(αj))(ω) for (j, αj) in enumerate(d.α)]
    Σ = sum(gammas)
    [gamma / Σ for gamma in gammas]
end

struct DiagNormal{U, V}
    μ::U
    Σ::V
end

function (mv::DiagNormal)(i, ω)
    x = map(k -> ((i..., k)~ StdNormal{Float64}())(ω), 1:length(mv.μ))
    unwhiten!(PDiagMat(mv.Σ), x)
    x .+= mv.μ
    return x
end

# Other utility functions
pget(x) = i -> x[i]