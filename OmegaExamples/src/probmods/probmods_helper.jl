# Helper functions for probmods
using UnicodePlots, Distributions, Omega, FreqTables, PDMats

export viz, pget, Dirichlet, viz_marginals, DiagNormal

"To visualize the generated samples of a random variable"
viz(var::Vector{T} where {T<:Union{String,Char, Symbol}}) =
    barplot(Dict(freqtable(var)))
viz(var::Vector{<:Real}) = histogram(var, symbols = ["■"])
viz(var::Vector{Bool}) = viz(string.(var))
viz(var::Vector{NamedTuple{U, V}}) where {U, V} = 
    barplot(Dict(freqtable(var)))

function viz_marginals(var::Vector{NamedTuple{U, V}}) where {U, V}
    if isa(getfield(var[1], U[1]), Real)
        display((U[1]))
        display(histogram(getfield.(var, U[1]), symbols = ["■"]))
        for name in U[2:end]
            display(name)
            display(histogram(getfield.(var, name), symbols = ["■"]))
        end
        return nothing
    else
        c = barplot(Dict(freqtable(string.(U[1], "_", getfield.(var, U[1])))))
        for name in U[2:end]
            c = barplot!(c, Dict(freqtable(string.(name, "_", getfield.(var, name)))))
        end
        return c
    end
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