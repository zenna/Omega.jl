export logenergy, ℓ

"""
`logenergy(ω)`

Unnormalized joint log density
"""
function logenergy(ω::AbstractΩ)
  reduce(ω.data; init = 0.0) do logpdf_, (id, (dist, val))
    logpdf_ + logpdf(dist, val)
  end
end

const ℓ = logenergy