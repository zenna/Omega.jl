# Helper functions for probmods

"To visualize the generated samples of a random variable"
viz(var::Vector{T} where T<:Union{String, Char}) = 	
		barplot(Dict(freqtable(var)))
viz(var::Vector{<:Real}) = histogram(var, symbols = ["■"])
viz(var::Vector{Bool}) = viz(string.(var))

# Required aditional distributions -
struct UniformDraw{T}
	elem::T
end
(u::UniformDraw)(i, ω) = 
	u.elem[(i ~ DiscreteUniform(1, length(u.elem)))(ω)]
	
struct Dirichlet{T}
	α::T
end
Dirichlet(k::Int64, a::Real) = Dirichlet(a.*ones(k))

function (d::Dirichlet)(i, ω)
	gammas = [((i..., j) ~ Gamma(αj))(ω) for (j, αj) in enumerate(d.α)]
	Σ = sum(gammas)
	[gamma/Σ for gamma in gammas]
end

# Other utility functions
pget(x) = i -> x[i]
ifelseₚ(cond, x, y) = pw(ifelse, cond, x, y)