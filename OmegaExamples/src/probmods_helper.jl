# Helper functions for probmods
using UnicodePlots, Distributions, Omega, FreqTables

export viz, UniformDraw, pget, Dirichlet, viz_marginals

"To visualize the generated samples of a random variable"
viz(var::Vector{T} where {T<:Union{String,Char}}) =
    barplot(Dict(freqtable(var)))
viz(var::Vector{<:Real}) = histogram(var, symbols = ["■"])
viz(var::Vector{Bool}) = viz(string.(var))
viz(var::Vector{NamedTuple{U, V}}) where {U, V} = barplot(Dict(freqtable(var)), ylabel = string(U[1], ", ", U[2]), xlabel = "Frequency")
function viz_marginals(var::Vector{NamedTuple{U, V}}) where {U, V}
	begin
		for i in 1:length(U)
			viz(map(x -> x[U[i]], var))
		end
	end
end

# Required aditional distributions -
struct UniformDraw{T}
    elem::T
end
(u::UniformDraw)(i, ω) =
    u.elem[(i ~ DiscreteUniform(1, length(u.elem)))(ω)]

struct Dirichlet{V}
    α::V
end
Dirichlet(k::Int64, a::Real) = Dirichlet(a .* ones(k))

function (d::Dirichlet)(i, ω)
    gammas = [((i..., j) ~ Gamma(αj))(ω) for (j, αj) in enumerate(d.α)]
    Σ = sum(gammas)
    [gamma / Σ for gamma in gammas]
end

# Other utility functions
pget(x) = i -> x[i]