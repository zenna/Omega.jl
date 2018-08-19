# "Dirichlet distribution"
# abstract type Dirichlet <: Dist end

# function dirichlet(ω::Ω, α)
#   gammas = [gammarv(ω[@id][i], αi, 1.0) for (i, αi) in enumerate(α)]
#   Σ = sum(gammas)
#   [gamma/Σ for gamma in gammas]
# end
# # FIXME: Type
# dirichlet(α::MaybeRV{T}) where T = RandVar{T, Dirichlet}(dirichlet, (α,))
