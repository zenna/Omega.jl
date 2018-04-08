using Mu

k = uniform(1:4)

function components(ω)
  [normal(ω, 0.0, 1.0) for i = 1:k(ω)]
end

# components = @mu [normal(0.0, 1.0) for i = 1:k]

c = RandVar{Vector{Float64}}(components) #FIXME: Infer type
rand((k, components), sum(components) == 1.0)