using Mu

k = uniform(1:4)

function components(ω)
  a = [(normal(ω[@id], 0.0, 1.0)) for i = 1:k(ω)]
  b = [(normal(ω[@id], 0.0, 1.0)) for i = 1:k(ω)]
  vcat(a, b)
end

# components = @mu [normal(0.0, 1.0) for i = 1:k]

c = Mu.RandVar{Vector{Float64}}(components) #FIXME: Infer type
rand(c, sum(c) == 1.0)